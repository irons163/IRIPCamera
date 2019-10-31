//
//  Receiver.m
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "Receiver.h"

@interface Receiver(Private)
-(void) showWaitingMask;
-(void) closeWaitingMask;
@end

@implementation Receiver

@synthesize m_intPortNumber ,m_strDeviceIP ,m_strPassword ,m_strUserName ,m_blnReceiving ,m_blnPlayingAudio;
@synthesize m_VideoDecoder;
@synthesize m_audioDecoder;
@synthesize m_currentOrientation;
@synthesize eventDelegate;
@synthesize m_SampleRate;
@synthesize m_AudioCodecName;
@synthesize m_Channel;
@synthesize m_blnUseTCP;
@synthesize m_blnRTSPStopFinish;
@synthesize m_uintConnectStatus;
@synthesize m_blnIsRecording;
@synthesize m_AudioCodec;
@synthesize m_VideoCodec;
@synthesize m_blnReceiveFirstIFrame;
@synthesize m_blnReceiveFrameFinish;
@synthesize m_VideoHeight;
@synthesize m_VideoWidth;
@synthesize m_FPS;
@synthesize m_blnPlaySuccess;

-(id)initDeviceWithUserName:(NSString *)strUserName password:(NSString *)strPassword IP:(NSString *)strIPAddress port:(NSInteger)port useTCP:(BOOL)_useTCP FPS:(NSInteger)_ipratio
{
    m_aryH264StartCode[0] = 0X00;
    m_aryH264StartCode[1] = 0X00;
    m_aryH264StartCode[2] = 0X00;
    m_aryH264StartCode[3] = 0X01;
    
    [self setDeviceWithUserName:strUserName password:strPassword IP:strIPAddress port:port];
    self.m_blnUseTCP = _useTCP;
    
    m_FPS = _ipratio;
    signal(SIGPIPE, SIG_IGN);
    return self;
}

-(void) setDeviceWithUserName:(NSString *)strUserName password:(NSString *)strPassword IP:(NSString *)strIPAddress port:(NSInteger)port
{
    self.m_strUserName      = strUserName ;
    self.m_strPassword      = strPassword;
    self.m_strDeviceIP      = strIPAddress;
    self.m_intPortNumber    = port;
    self.m_blnReceiving     = NO;
    self.m_blnReceiveFrameFinish = YES;
    self.m_blnPlaySuccess   = NO;
    self.m_VideoCodec       = nil;
    self.m_AudioCodec       = nil;
    self.m_VideoWidth       =   0;
    self.m_VideoHeight      =   0;
    
    if(m_audioDecoder)
    {
        m_audioDecoder = nil;
    }
    
    if(self.m_VideoDecoder )
    {
        self.m_VideoCodec = nil;
        m_VideoCodec = nil;
    }
    
    if(!self.m_audioDecoder)
        self.m_audioDecoder = [[AudioDecoder alloc] initAudioDecode];
    
    if(!self.m_VideoDecoder)
    {
        self.m_VideoDecoder = [[VideoDecoder alloc] initDecoder];
        [self.m_VideoDecoder setDelegate:self];
    }
}

-(NSUInteger) startConnection
{
    return 0;
}

-(BOOL) stopConnection:(BOOL) _blnForever
{
    
    //    if(self.m_VideoDecoder && [self.m_VideoDecoder respondsToSelector:@selector(stopDecode)])
    if(self.m_VideoDecoder)
    {
        [m_VideoDecoder stopDecode];
        self. m_VideoDecoder = nil;
    }
    else
    {
        NSLog(@"m_VideoDecoder error");
    }
    //    if(self.m_audioDecoder && [self.m_audioDecoder respondsToSelector:@selector(stopDecode)])
    if(self.m_audioDecoder)
    {
        [m_audioDecoder stopDecode];
        self.m_audioDecoder = nil;
    }
    else
    {
        NSLog(@"m_audioDecoder error");
    }
    return YES;
}

//-(void) setDisplayUIImageView:(UIImageView *)tmpView
-(void) setDisplayUIImageView:(IRFFVideoInput *)tmpView activityLoading:(UIActivityIndicatorView *)_loading
{
    [self.m_VideoDecoder setDisplayUIView:tmpView];
    m_loadingActivity = _loading;
    _loading = nil;
    tmpView = nil;
}
-(void) setCurrentOrientation:(UIInterfaceOrientation)currentOrientation
{
    self.m_currentOrientation = currentOrientation;
    
    if(m_blnReceiving)
        [self.m_VideoDecoder setM_blnChangeOrientation:YES];
}

-(void) setVideoCodecWithCodecString:(NSString*) strCodec
{
    if(self.m_VideoDecoder)
        [self.m_VideoDecoder setCodecWithCodecString:strCodec];
}
-(void) setAudioCodecWithCodecString:(NSString*) strCodec
{
    [self.m_audioDecoder setCodecWithCodecString:strCodec];
    [self.m_audioDecoder setAudioDecodeSampleRate:8000 channels:1];
    
}

-(void) setExtraData:(NSInteger) _iLen extraData:(uint8_t *) _extraData
{
    
    [self.m_VideoDecoder setExtraData:_iLen extraData:_extraData];
    //    -(void) setExtraData:(NSInteger) _iLen extraData:(uint8_t *) _extradata
}

-(void) setRunLoad:(BOOL) _blnRun
{
    if (_blnRun) {
        [m_loadingActivity startAnimating];
    }
    else
    {
        [m_loadingActivity stopAnimating];
        //        NSLog(@"ch [%d] connect success",m_Channel);
    }
}

-(void) setPlayAudio:(BOOL) _blnPlay
{
    self.m_blnPlayingAudio = _blnPlay;
    
    if(self.m_audioDecoder)
    {
        if([self.m_audioDecoder respondsToSelector:@selector(stopDecode)])
        {
            if(!_blnPlay)
                [self.m_audioDecoder stopDecode];
            else
                [self.m_audioDecoder startDecode];
        }
    }
}

-(void) setChannel :(NSInteger) _ch
{
    m_Channel = _ch;
    [self.m_VideoDecoder setChannel:m_Channel];
    [self.m_audioDecoder setM_channelNO:m_Channel];
}

-(NSInteger) getChannel
{
    return m_Channel;
}

//-(void) startFisheyeRecordWithParameter:(FisheyeParameter*)parameter
//{
//    
//    if(!m_blnIsRecording)
//    {
//        NSLog(@"m_blnIsRecording=%d",m_blnIsRecording);
//        [m_Recorder startFisheyeRecordWithAudio:m_AudioCodec ? YES : NO up:parameter.up rx:parameter.rx ry:parameter.ry cx:parameter.cx cy:parameter.cy latmax:parameter.latmax];
//        m_blnIsRecording = YES;
//    }
//}


-(void) stopRecord
{
    if(m_blnIsRecording)
    {
        m_blnIsRecording = NO;
        [NSThread detachNewThreadSelector:@selector(doStropRecording) toTarget:self withObject:nil];
    }
}


#pragma videoDecoderDelegate
-(void) videoChangeWidth:(NSInteger)_width height:(NSInteger)_height
{
    self.m_VideoWidth = _width;
    self.m_VideoHeight = _height;
    [self.eventDelegate onResolutionChange];
}
@end


@implementation Receiver(Private)

-(void) showWaitingMask
{
    
}

-(void) closeWaitingMask
{
    
}

@end
