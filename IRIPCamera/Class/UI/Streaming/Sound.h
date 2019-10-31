//
//  Sound.h
//  testOpenAL
//
//  Created by sniApp on 12/9/27.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface Sound : NSObject
{
    ALCcontext *mContext;
    ALCdevice *mDevice;
    ALCdevice *mCaptureDevice;
    ALuint outSourceID;
    
    ALuint m_SampleRate;
    ALuint m_channels;
    ALuint m_playType;
    NSTimer *m_timer;
    
    BOOL m_blnPlay;
    NSInteger m_Channel;
}

@property (nonatomic) NSInteger m_Chanel;
@property (nonatomic) ALCcontext *mContext;
@property (nonatomic) ALCdevice *mDevice;
@property (nonatomic) ALCdevice *mCaptureDevice;
@property (nonatomic) BOOL m_blnPlay;
@property (nonatomic ,retain) NSTimer *m_timer;

-(void) setPlaySoundInfoWithSampleRate:(ALuint) sampleRate channels:(ALuint) channels;
-(void)initOpenAL;
- (void) openAudioFromQueue:(unsigned char*)data dataSize:(UInt32)dataSize;

-(void)playSound;
-(void)stopSound;
-(void)cleanUpOpenALID;
-(void)cleanUpOpenAL;
-(void)stopOpenAL;
-(void)resumeOpenAL;
@end
