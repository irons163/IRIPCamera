//
//  AudioQueuePlayer.h
//  IRIPCamera
//
//  Created by sniApp on 13/1/9.
//  Copyright (c) 2013年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#define NUM_BUFFER 3

@interface AudioQueuePlayer : NSObject
{
    AudioStreamBasicDescription m_sourceDataDesc;
    AudioQueueRef   m_AudioQueue;
    SInt64 packetIndex;
    UInt32 numPacketsToRead;
    UInt32  bufferByteSize;
    AudioStreamPacketDescription *m_packetDesc;
    AudioQueueBufferRef buffers[NUM_BUFFER];
    NSMutableArray *m_arySourceData;
}

@property AudioQueueRef m_AudioQueue;
@property (nonatomic ,retain)NSMutableArray *m_arySourceData;

-(void) audioQueueOutputWriteQueue:(AudioQueueRef) audioQueue queueBuffer:(AudioQueueBufferRef) audioQueueBufer;

static void BufferCallback(void *inUserData ,AudioQueueRef inAudioQueue ,AudioQueueBufferRef buffer);

-(void) pushAudioToBuffer:(NSData *) _audioData;
@end
