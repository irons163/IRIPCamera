//
//  Sound.m
//  testOpenAL
//
//  Created by sniApp on 12/9/27.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "Sound.h"

int iChannel = 0;
@implementation Sound
@synthesize mContext;
@synthesize mDevice;
@synthesize mCaptureDevice;
@synthesize m_blnPlay;
@synthesize m_timer,m_Chanel;

-(void)initOpenAL
{
    
//    mCaptureDevice = alcCaptureOpenDevice("abc", 8000, AL_FORMAT_STEREO16, 128);
    self.mDevice=alcOpenDevice([[NSString stringWithFormat:@"%d",self.m_Chanel] UTF8String]);
    ALenum err ;
    err = alGetError();
    
    if(err)
    {
        NSLog(@"open device fail =%d",err);
    }
    if (self.mDevice) {
        self.mContext=alcCreateContext(self.mDevice, &iChannel);
        NSLog(@"%d ------ channel" ,iChannel);
        alcMakeContextCurrent(self.mContext);

        alGenSources(1, &outSourceID);
        alSpeedOfSound(1.0);
        alDopplerVelocity(1.0);
        alDopplerFactor(1.0);
        alSourcef(outSourceID, AL_PITCH, 1.0f);
        //alSourcef(outSourceID, AL_GAIN, 1.0f);
        alSourcef(outSourceID, AL_GAIN, 0.1f);
        alSourcei(outSourceID, AL_LOOPING, AL_FALSE);
        alSourcef(outSourceID, AL_SOURCE_TYPE, AL_STREAMING);
        alSourcef(outSourceID, AL_BYTE_OFFSET, 16.0f);
//        alBufferi(outSourceID, AL_FREQUENCY, 8000);
                NSLog(@"*******output id=%d",outSourceID);
        self.m_blnPlay = YES;
    }
    else
    {
        NSLog(@"init open al device fail");
    }
    

    
//    self.m_timer = [NSTimer scheduledTimerWithTimeInterval: 1.0f/1000.0f
//                                     target:self
//                                   selector:@selector(updataQueueBuffer)
//                                   userInfo: nil
//                                    repeats:NO];
    
    m_SampleRate = 44100;
    m_playType = AL_FORMAT_STEREO16;

    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(stopOpenAL:)
     name:@"stopOpenAL"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(resumeOpenAL:)
     name:@"resumeOpenAL"
     object:nil];
}


-(void)stopOpenAL
{
        
    if(self.m_blnPlay == YES)
    {
//        NSLog(@"stopOpenAL channel = %d ,%d",pass ,self.m_Chanel);

        ALuint bufferID = 0;
        alDeleteBuffers(outSourceID ,&bufferID);
        // set the current context to NULL will 'shutdown' openAL
        alcMakeContextCurrent(NULL);
        
        // now suspend your context to 'pause' your sound world
        alcSuspendContext(self.mContext);

        self.m_blnPlay = NO;
    }
}


-(void)resumeOpenAL
{
    if(self.m_blnPlay == NO)
    {

        
        // Restore open al context
        alcMakeContextCurrent(self.mContext);
        // 'unpause' my context
        alcProcessContext(self.mContext);
        
        self.m_blnPlay = YES;
    }
}

-(void) setPlaySoundInfoWithSampleRate:(ALuint) sampleRate channels:(ALuint) channels
{
    if(!self.mDevice)
        [self initOpenAL];
    m_channels = channels;
    m_SampleRate = sampleRate;
    
    switch (m_channels) {
        case 1:
            m_playType = AL_FORMAT_MONO16;
            break;
        case 2:
            m_playType = AL_FORMAT_STEREO8;
        default:
            m_playType = AL_FORMAT_STEREO16;
            break;
    }
}


- (void) openAudioFromQueue:(unsigned char*)data dataSize:(UInt32)dataSize
{
    
    if(self.m_blnPlay == NO)
        return;
    
    NSLog(@"audio length=%d",(unsigned int)dataSize);
    
    @autoreleasepool {
        NSCondition* ticketCondition= [[NSCondition alloc] init];
        [ticketCondition lock];
        ALenum err ;
        ALuint bufferID = 0;
        alGenBuffers(1, &bufferID);
        
        err = alGetError();
        
        if(err)
        {
            NSLog(@"alGenBuffers error id = %d",err);
        }
        
        NSData * tmpData = [NSData dataWithBytes:data length:dataSize];
        //    NSLog(@"decode size=%lu sampleRate = %d type=%X",dataSize ,m_SampleRate ,m_playType);
        //    alBufferData(bufferID, AL_FORMAT_MONO16, (char*)[tmpData bytes], dataSize, 8000);
        alBufferData(bufferID, m_playType, (char*)[tmpData bytes], dataSize, m_SampleRate);
        err = alGetError();
        
        if(err)
        {
            //        [self cleanUpOpenAL];
            //        [self initOpenAL];
        }
        alSourceQueueBuffers(outSourceID, 1, &bufferID);
        err = alGetError();
        
        if(err)
        {
            //        NSLog(@"alSourceQueueBuffers error id = %d",err);
            //        [self cleanUpOpenAL];
            //        [self initOpenAL];
        }
        
        if (self.m_blnPlay)
            [self updataQueueBuffer];
        
        
        ALint stateVaue;
        alGetSourcei(outSourceID, AL_SOURCE_STATE, &stateVaue);
        
        err = alGetError();
        
        if(err)
        {
            NSLog(@"alGetSourcei error id = %d",err);
        }
        
        [ticketCondition unlock];
        ticketCondition = nil;
    }
    
}

-(void)playSound
{
    alSourcePlay(outSourceID);
    ALenum err = alGetError();
    if(err){NSLog(@"playSound errr= %d",err);}
}

-(void)stopSound
{
    alSourceStop(outSourceID);
}

-(void)cleanUpOpenALID{}
-(void)cleanUpOpenAL
{
    self.m_blnPlay = NO;

    if(self.mDevice)
        alcCloseDevice(self.mDevice);
    self.mDevice = NULL;
    
    alcDestroyContext(self.mContext);
    ALenum err ;
    err = alGetError();
    if(err)
    {
        NSLog(@"cleanUpOpenAL alGetSourcei AL_SOURCE_STATE= %d",err);
    }
}

- (BOOL) updataQueueBuffer
{
    ALint stateVaue;
    int processed, queued;
    ALenum err = alGetError();
    
    
    alGetSourcei(outSourceID, AL_SOURCE_STATE, &stateVaue);
    err = alGetError();
    if(err){NSLog(@"alGetSourcei AL_SOURCE_STATE= %d",err);}
    
    if (stateVaue == AL_STOPPED ||
        stateVaue == AL_PAUSED ||
        stateVaue == AL_INITIAL)
    {
        [self playSound];
        return NO;
    }

    
    alGetSourcei(outSourceID, AL_BUFFERS_PROCESSED, &processed);
    err = alGetError();
    if(err){NSLog(@"alGetSourcei AL_BUFFERS_PROCESSED= %d",err);}
    alGetSourcei(outSourceID, AL_BUFFERS_QUEUED, &queued);
    err = alGetError();
    if(err){NSLog(@"alGetSourcei AL_BUFFERS_QUEUED= %d",err);}
    
//    NSLog(@"Processed = %d\n", processed);
//    NSLog(@"Queued = %d\n", queued);
    
    while(processed-- && !err)
    {
        ALuint buff;
        alSourceUnqueueBuffers(outSourceID, 1, &buff);
        err = alGetError();
//        if(err){NSLog(@"alSourceUnqueueBuffers = %d",err);}
        alDeleteBuffers(1, &buff);
        
        if (!self.m_blnPlay || processed > 10000) {
            break;
        }
    }
    
    if(!err)
        return YES;
    else
        return NO;
}

@end
