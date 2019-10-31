//
//  AudioOutput.h
//  MobileFocus
//
//  Created by Nobel on 2011/3/4.
//  Copyright 2011 EverFocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

#define AQ_BUFFER_NUMBER	4    // dont set too large, or it would dealy too long time
#define AQ_BUFFER_SIZE		512


@interface AudioOutput : NSObject
{
    // buffer
	void*	readPos;
	void*	writePos;
	void*	dataBuffer;
	int		lpcmBufSize;
	int		dalayLength;
	int		readFlag;
	int		writeFlag;

	
	// player
	AudioStreamBasicDescription		audioDesc;
	AudioQueueRef					queue;
	AudioQueueBufferRef				aqbuf[AQ_BUFFER_NUMBER];
	
	BOOL	isDecoding;
	BOOL	isStop;
    
    NSMutableArray *m_AudioData;
}

@property (nonatomic ,retain) NSMutableArray *m_AudioData;

// codec
- (id)initWithCodecId:(int)cid srate:(int)srate bps:(int)bps balign:(int)balign fsize:(int)fsize;
- (void)playAudio:(Byte *)pInAudio length:(int)length;
- (BOOL)start;
- (void)stop;

// player
- (void)mute;
- (void)play;
@property(nonatomic,readonly) int		codecId;

@end