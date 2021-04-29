//
//  AudioDecoder.h
//  live555Client
//
//  Created by sniApp on 12/9/24.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#include<AudioToolbox/AudioToolbox.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import "AudioPlayer.h"
#import <IRPlayer/IRPlayer.h>
#import <IRPlayer/IRFFTools.h>
#import <libswresample/swresample.h>

@protocol AudioDecoderDelegate

- (void)playAudio:(unsigned char *)data dataSize:(UInt32)dataSize;

@end

@interface AudioDecoder : NSObject {
    ALCdevice   *openALDevice;
    ALCcontext  *openALContext;
    ALuint      outputSource;
    ALuint      outputBuffer;
    NSFileHandle *myHandle;
    NSString* filenameStr;
    AudioPlayer *mPlayer;
    AVCodecContext *context;
    SwrContext       *pSwrCtx;
    
    NSInteger m_SampleRate;
    NSInteger m_Channels;
    NSInteger m_channelNO;
    BOOL m_blnStopDecode;
    id <AudioDecoderDelegate> delegate;
}

@property (nonatomic) NSInteger m_channelNO;
@property (nonatomic ,retain) id <AudioDecoderDelegate> delegate;

-(id) initAudioDecode;
-(NSUInteger) setCodecWithCodecString:(NSString*) strCodec;
-(void) setAudioDecodeSampleRate:(NSInteger)sampleRate channels:(NSInteger) channels;
-(void) decodeAudioFromSource:(const uint8_t *) audioData length:(int)length;
-(void) setExtraData:(NSInteger) _iLen extraData:(uint8_t *) _extradata;
-(void) stopDecode;
-(void) startDecode;

@end
