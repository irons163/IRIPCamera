#import "AudioInput.h"

static void CASoundAQInputCallback(	
								 void *									inUserData,
								 AudioQueueRef							inAQ,
								 AudioQueueBufferRef					inBuffer,
								 const AudioTimeStamp *					inStartTime,
								 UInt32									inNumPackets,
								 const AudioStreamPacketDescription*	inPacketDesc);


@implementation AudioInput
@synthesize delegate;
@synthesize myHandle;
int packcount = 0;
- (id)initWithSampleRate:(int)srate bps:(int)bps balign:(int)balign fsize:(int)fsize audioType:(NSString *)_audioType
{
	
	if (!(self=[super init])) return nil;
    
    // Describe format
//	audioDesc.mSampleRate			= 8000.0;
    audioDesc.mSampleRate			= (Float64)srate;
    
    if([_audioType isEqualToString:@"PCM"])
        audioDesc.mFormatID			= kAudioFormatLinearPCM;
    else
        audioDesc.mFormatID			= kAudioFormatULaw;
    
//	audioDesc.mFormatFlags		= kAudioFormatFlagIsPacked;
//	audioDesc.mFramesPerPacket	= 1;
//	audioDesc.mChannelsPerFrame	= 1;
////	audioDesc.mBitsPerChanxnel		= 8;
//	audioDesc.mBitsPerChannel		= bps;
//	audioDesc.mBytesPerPacket		= bps / 8;
//	audioDesc.mBytesPerFrame		= bps / 8;
    
    audioDesc.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    audioDesc.mBitsPerChannel = bps;
    audioDesc.mChannelsPerFrame = 1;
    audioDesc.mBytesPerPacket = audioDesc.mBytesPerFrame = (audioDesc.mBitsPerChannel / 8) * audioDesc.mChannelsPerFrame;
    audioDesc.mFramesPerPacket = 1;
    
//    if(packcount == 0)
//    {
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask, YES);
//    NSString* documentsDirectory = [paths objectAtIndex:0];
//    NSString* leafname = [@"audio" stringByAppendingFormat: @".PCM" ];
//    filenameStr = [NSString stringWithFormat:@"%@",[documentsDirectory
//                                                    stringByAppendingPathComponent:leafname]];
//    tmpfilename = (char *)malloc([filenameStr length]-1);
//    memcpy(tmpfilename, [filenameStr UTF8String], [filenameStr length]-1);
////    filenameStr = ;
//
//    [[NSFileManager defaultManager] createFileAtPath:filenameStr contents:nil attributes:nil];
//    NSLog(@"filePath=%@",filenameStr);
//    self.myHandle = [NSFileHandle fileHandleForWritingAtPath:filenameStr];
////    [myHandle seekToEndOfFile];
//    }
	return self;
}

- (BOOL)start {
	
	if (queue!=nil) return YES;
	AudioQueueSetParameter(queue, kAudioQueueParam_Volume, 1.0f);
    
    self.audioSession = [AVAudioSession sharedInstance];
    
    CGFloat gain = 1.0;
    NSError* err;
    if (self.audioSession.isInputGainSettable) {
        BOOL success = [self.audioSession setInputGain:gain
                                                 error:&err];
        if (!success){
            NSLog(@"set input gain failed %@",err);
        } //error handling
    } else {
        NSLog(@"cannot set input gain");
    }
    
    NSLog(@"audiosession gain: %.2f ",self.audioSession.inputGain);
    
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [self.audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    [self.audioSession setActive:YES error:nil];
    
	// open AQ
	OSStatus error;
	error = AudioQueueNewInput( &audioDesc, CASoundAQInputCallback, (__bridge void *)(self), NULL, NULL ,0 , &queue);
    
	if (error) {
		NSLog(@"AudioQueueNewInput: OS error %zd\n", error);
		return NO;
	}
	
	// alloc AQ buffer
	for (UInt32 i = 0; i < AQ_BUFFER_NUMBER; ++i) {
		
		error = AudioQueueAllocateBuffer(queue, AQ_BUFFER_SIZE, aqbuf+i);

		if (error) {
			NSLog(@"AudioQueueAllocateBuffer: OS error %zd\n", error);
			[self stop];
			return NO;
		}
		
		CASoundAQInputCallback((__bridge void *)(self), queue, aqbuf[i], NULL, 0, NULL);
	}
    
	// start AQ
	error = AudioQueueStart(queue, NULL);
	if (error) {
		NSLog(@"AudioQueueStart: OS error %zd\n", error);
		[self stop];
		return NO;
	}
	
	NSLog(@"Audio input start.");
	return YES;
}

- (void)stop {
	
	if (queue==nil) return;
	
//	// stop AQ
	OSStatus error = AudioQueueStop(queue, true);
	if (error) {
		NSLog(@"AudioQueueStop: OS error %zd\n", error);
	}
	
	// dispose AQ
	AudioQueueDispose(queue, true);
	queue = nil;
	
	NSLog(@"Audio input stop.");
}

- (void)dealloc {
	
	[self stop];
    [self.audioSession setActive:NO error:nil];
}

@end

static void CASoundAQInputCallback(	
								   void *								inUserData,
								   AudioQueueRef						inAQ,
								   AudioQueueBufferRef					inBuffer,
								   const AudioTimeStamp *				inStartTime,
								   UInt32								inNumPackets,
								   const AudioStreamPacketDescription*	inPacketDesc)
{
	//NSLog(@"Input bytes: %d", inBuffer->mAudioDataByteSize);
    
	AudioInput* audioInput = (__bridge AudioInput*)inUserData;
    
//    if(packcount < 5000)
//    {
//        NSData *tmpdata = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
//        [audioInput.myHandle seekToEndOfFile];
//        [audioInput.myHandle writeData:tmpdata];
//        [tmpdata release];
//        packcount++;
//
//        if(packcount == 5000)
//        {
//            [audioInput.myHandle closeFile];
//        }
//    }
	
	if (inBuffer->mAudioDataByteSize)
    {	
        [audioInput.delegate putAudio:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
	}
		
	// re-enqueue the buffe so that it gets filled again
	AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}
