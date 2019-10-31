//
//  AudioQueuePlayer.m
//  IRIPCamera
//
//  Created by sniApp on 13/1/9.
//  Copyright (c) 2013年 sniApp. All rights reserved.
//

#import "AudioQueuePlayer.h"

static UInt32 gBufferSizeBytes=0X10000;

@implementation AudioQueuePlayer
@synthesize m_AudioQueue;
@synthesize m_arySourceData;

-(id) init
{
    if(!(self=[super init])) return nil;
    
    self.m_arySourceData = [[NSMutableArray alloc] init];


    
    // player
	m_sourceDataDesc.mSampleRate		= 8000;//+20;
	m_sourceDataDesc.mFormatID			= kAudioFormatLinearPCM;
	m_sourceDataDesc.mFormatFlags		= kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
	m_sourceDataDesc.mBytesPerPacket	= 2;
	m_sourceDataDesc.mFramesPerPacket	= 1;
	m_sourceDataDesc.mBytesPerFrame     = 2;
	m_sourceDataDesc.mChannelsPerFrame	= 1;
	m_sourceDataDesc.mBitsPerChannel	= 16;
	m_sourceDataDesc.mReserved			= 0;
    
    OSStatus errorCode = AudioQueueNewOutput(&m_sourceDataDesc, BufferCallback, (__bridge void *)(self), nil, nil, 0, &m_AudioQueue);
    
    for (UInt32 i = 0; i < NUM_BUFFER ; ++i) {
		
		errorCode = AudioQueueAllocateBuffer(m_AudioQueue, gBufferSizeBytes, &buffers[i]);
		if (errorCode)
		{
			NSLog(@"AudioQueueAllocateBuffer: OS error %li\n", errorCode);
			return NO;
		}
		
	}
    
    AudioQueueSetParameter(m_AudioQueue, kAudioQueueParam_Volume, 1.0f);
    errorCode = AudioQueueStart(m_AudioQueue, NULL);
    if (errorCode)
    {
        NSLog(@"AudioQueueStart: OS error %li\n", errorCode);
        
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                             code:errorCode
                                         userInfo:nil];
        NSLog(@"Error: %@", [error description]);

        return nil;
    }
		

    
    return self;
}

-(void) pushAudioToBuffer:(NSData *) _audioData
{
    [self.m_arySourceData addObject:_audioData];
}

static void BufferCallback(void *inUserData ,AudioQueueRef inAudioQueue ,AudioQueueBufferRef buffer)
{
    AudioQueuePlayer *player = (__bridge AudioQueuePlayer*)inUserData;
    [player audioQueueOutputWriteQueue:inAudioQueue queueBuffer:buffer];
}

-(void) audioQueueOutputWriteQueue:(AudioQueueRef)audioQueue queueBuffer:(AudioQueueBufferRef)audioQueueBufer
{
    //if (isStop) return;
	
//	UInt32 bytesToFill = audioQueueBufer->mAudioDataBytesCapacity;

    if([self.m_arySourceData count] > 0)
    {
	UInt32 bytesFilled = [[self.m_arySourceData objectAtIndex:0] length];
	
	memcpy(audioQueueBufer->mAudioData,(__bridge const void *)([self.m_arySourceData objectAtIndex:0]), bytesFilled);
	audioQueueBufer->mAudioDataByteSize = bytesFilled;
    
    [self.m_arySourceData removeObjectAtIndex:0];
	
	//if (bytesFilled) {
    AudioQueueEnqueueBuffer(audioQueue, audioQueueBufer, 0, NULL);
	//}
	}
	//NSLog(@"Audio queue need: %d get: %d", bytesToFill, bytesFilled);
    
    
}


@end
