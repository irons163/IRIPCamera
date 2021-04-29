//
//  AudioPlayer.m
//  IRIPCamera
//
//

#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>

static void AudioQueueCallback(void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueS,
                                       const void                *inPropertyValue
                                       );

@interface AudioPlayer (privateMethod)

// player
- (BOOL)initAudioQueue;
- (void)fillAudioToBuffer: (AudioQueueRef)inAQ buffer: (AudioQueueBufferRef)inBuffer;

@end

@implementation AudioPlayer

- (id)initWithSampleRate:(int)_sampleRate {
	if (!(self=[super init])) return nil;

	// player
	audioDesc.mSampleRate		= 12000;
	audioDesc.mFormatID			= kAudioFormatLinearPCM;
	audioDesc.mFormatFlags		= kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
	audioDesc.mBytesPerPacket	= 2;
	audioDesc.mFramesPerPacket	= 1;
	audioDesc.mBytesPerFrame	= 2;
	audioDesc.mChannelsPerFrame	= 1;
	audioDesc.mBitsPerChannel	= 16;
	audioDesc.mReserved			= 0;
    
	m_AudioQueue = nil;
    
	m_AudioData = [[NSMutableArray alloc] init];
    m_emptyData = (Byte*)malloc(AQ_BUFFER_SIZE);
    memset(m_emptyData, 0, AQ_BUFFER_SIZE);
    
	return self;
}

- (BOOL)start {
    OSStatus error = 0;
    
	if (m_AudioQueue != nil) {
        return YES;
    }
    
	// create audio queue
	if ([self initAudioQueue]) {
		AudioQueueSetParameter(m_AudioQueue, kAudioQueueParam_Volume, 1.0f);
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput, sizeof(category), &category);
        
        UInt32 audioRouteOverride = [self hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,
                                         audioRouteChangeListenerCallback,
                                         (__bridge void *)(self));
        
        error = AudioQueueStart(m_AudioQueue, NULL);
        
		if (error) {
			NSLog(@"AudioQueueStart failed %ld", error);
			
			[self stop];
			return NO;
		}
			
		return YES;
	} else {
		[self stop];
		return NO;
	}
}

- (void)playAudio:(float *)pInAudio length:(int)length {
    NSData *tmpAudio = [[NSData alloc] initWithBytes:pInAudio length:length];
    [m_AudioData addObject:tmpAudio];
    tmpAudio = nil;
}

- (void)stop {
    signal(SIGPIPE, SIG_IGN);
	
    if (m_AudioQueue==nil) return;
    
    [m_AudioData removeAllObjects];
    AudioQueueSetParameter(m_AudioQueue, kAudioQueueParam_Volume, 0.0f);
    AudioQueueReset(m_AudioQueue);
	AudioQueueStop(m_AudioQueue, true);
	AudioQueueDispose(m_AudioQueue, true);	// dispose audio queue
	m_AudioQueue = nil;
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, (__bridge void *)(self));
}

- (void)dealloc {
	[self stop];
    
    m_AudioData = nil;
    free(m_emptyData);
    m_emptyData = NULL;
}

- (BOOL)initAudioQueue {
	OSStatus error;
	
	// create a new audio queue output
	error = AudioQueueNewOutput(&audioDesc, AudioQueueCallback, (__bridge void *)(self), NULL, NULL, 0, &m_AudioQueue);
	if (error) {
		NSLog(@"AudioQueueNewOutput failed %ld", error);
		return NO;
	}
    
    UInt32 bufferByteSize = AQ_BUFFER_SIZE;
    
	for (UInt32 i = 0; i < AQ_BUFFER_NUMBER; i++) {
        error = AudioQueueAllocateBuffer(m_AudioQueue, bufferByteSize, &m_AudioBuffer[i]);
		if (error)
		{
			NSLog(@"AudioQueueAllocateBuffer failed %ld", error);
			return NO;
		}
        memset(m_AudioBuffer[i]->mAudioData, 0, bufferByteSize);
        m_AudioBuffer[i]->mAudioDataByteSize = bufferByteSize;
		
		AudioQueueCallback((__bridge void *)(self), m_AudioQueue, m_AudioBuffer[i]);
	}
	
	return YES;
}

- (void)fillAudioToBuffer:(AudioQueueRef)_audioQueue buffer:(AudioQueueBufferRef)_audioBuffer {
	UInt32 bytesToFill = _audioBuffer->mAudioDataBytesCapacity;
	UInt8* fillPtr = (UInt8*)_audioBuffer->mAudioData;
    
    if ([m_AudioData count] > 0) {
        NSData *tmpAudio = [m_AudioData objectAtIndex:0];

        float scale = (float)INT16_MAX;
        NSUInteger numElements = [tmpAudio length] / sizeof(float);
        vDSP_vsmul([tmpAudio bytes], 1, &scale, [tmpAudio bytes], 1, numElements);
        
        vDSP_vfix16([tmpAudio bytes],
        1,
        (SInt16 *)_audioBuffer->mAudioData,
        1,
        numElements / 1);
        
        _audioBuffer->mAudioDataByteSize = [tmpAudio length]/2;
        AudioQueueEnqueueBuffer(_audioQueue, _audioBuffer, 0, NULL);
        tmpAudio = nil;
        [m_AudioData removeObjectAtIndex:0];
    } else { // if no audio data fill white noise to audio queue
        memcpy(fillPtr, m_emptyData, bytesToFill);
        _audioBuffer->mAudioDataByteSize = bytesToFill/2;
        AudioQueueEnqueueBuffer(_audioQueue, _audioBuffer, 0, NULL);
    }
}

- (void)mute {
	AudioQueueSetParameter(m_AudioQueue, kAudioQueueParam_Volume, 0.0f);
}

- (void)play {
	AudioQueueSetParameter(m_AudioQueue, kAudioQueueParam_Volume, 1.0f);
}

- (BOOL)hasHeadset {
#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: audio session code works only on a device
    return NO;
#else
    
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
#endif
    
}
@end

static void AudioQueueCallback(void *caller, AudioQueueRef _audioQueue, AudioQueueBufferRef _audioBufferBuffer) {
	AudioPlayer* player = (__bridge AudioPlayer*)caller;
	[player fillAudioToBuffer:_audioQueue buffer:_audioBufferBuffer];
}

void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueS,
                                       const void                *inPropertyValue
                                       ) {
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    // Determines the reason for the route change, to ensure that it is not
    //        because of a category change.
    
    CFDictionaryRef    routeChangeDictionary = inPropertyValue;
    CFNumberRef routeChangeReasonRef =
    CFDictionaryGetValue (routeChangeDictionary,
                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    NSLog(@" ======================= RouteChangeReason : %d", (int)routeChangeReason);
    AudioPlayer *_self = (__bridge AudioPlayer *) inUserData;
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
        if ([_self start]) {
            [_self stop];
            [_self start];
        }
    }
}
