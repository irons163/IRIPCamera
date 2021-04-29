//
//  Receiver.h
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDecoder.h"
#import "AudioDecoder.h"
//#import "FisheyeParameter.h"

@protocol ReceiverDelegate <NSObject>

- (void)videoLoss:(id) _sender ErrorCode:(int)_code msg:(NSString *)_strmsg;
- (void)connectSuccess:(id) _sender;
- (void)recordingSuccessWithStatusCode : (NSInteger) _statusCode clientData:(id) _sender;
- (void)recordingFailWithStatusCode :(NSInteger) _statusCode err:(NSError *) _err clientData:(id) _sender;
- (void)onResolutionChange;

@end

@interface Receiver : NSObject <VideoDecoderDelegate> {
    NSString    *m_strUserName;
    NSString    *m_strPassword;
    NSString    *m_strDeviceIP;
    
    NSInteger   m_intPortNumber;
    NSUInteger  m_uintConnectStatus;
    NSInteger m_VideoWidth;
    NSInteger m_VideoHeight;
    NSInteger m_FPS;
    
    BOOL        m_blnReceiving;
    BOOL        m_blnPlayingAudio;
    BOOL        m_blnRTSPStopFinish;
    BOOL        m_blnIsRecording;
    BOOL        m_blnReceiveFirstIFrame;
    BOOL        m_blnReceiveFrameFinish;
    BOOL        m_blnPlaySuccess;
    u_int8_t m_aryH264StartCode[4];
    
    VideoDecoder *m_VideoDecoder;
    AudioDecoder *m_audioDecoder;
    UIInterfaceOrientation m_currentOrientation;
    
    NSInteger m_Channel;
    NSInteger m_SampleRate;
    NSString *m_AudioCodecName;
    NSString *m_VideoCodec;
    NSString *m_AudioCodec;
    
    __weak id<ReceiverDelegate> eventDelegate;
}

@property (nonatomic ,retain) NSString *m_AudioCodecName;
@property (nonatomic) NSInteger m_Channel;
@property (nonatomic) NSInteger m_SampleRate;
@property (nonatomic) NSInteger m_FPS;

@property (nonatomic ,retain) NSString *m_strUserName;
@property (nonatomic ,retain) NSString *m_strPassword;
@property (nonatomic ,retain) NSString *m_strDeviceIP;
@property (nonatomic ,retain) NSString *m_VideoCodec;
@property (nonatomic ,retain) NSString *m_AudioCodec;

@property (nonatomic ,retain) VideoDecoder *m_VideoDecoder;
@property (nonatomic ,retain) AudioDecoder *m_audioDecoder;
@property (nonatomic) UIInterfaceOrientation m_currentOrientation;
@property (weak) id<ReceiverDelegate> eventDelegate;
@property (nonatomic) BOOL m_blnIsRecording;

@property NSInteger     m_intPortNumber;
@property NSUInteger    m_uintConnectStatus;
@property NSInteger     m_VideoWidth;
@property NSInteger    m_VideoHeight;
@property BOOL          m_blnReceiving;
@property BOOL          m_blnPlayingAudio;
@property BOOL          m_blnUseTCP;
@property BOOL          m_blnRTSPStopFinish;
@property BOOL          m_blnReceiveFirstIFrame;
@property BOOL        m_blnReceiveFrameFinish;
@property BOOL        m_blnPlaySuccess;

- (id) initDeviceWithUserName:(NSString *)strUserName password:(NSString *)strPassword IP:(NSString *)strIPAddress port:(NSInteger)port useTCP:(BOOL) _useTCP FPS:(NSInteger) _ipratio;

- (void) setDeviceWithUserName:(NSString *)strUserName password:(NSString *)strPassword IP:(NSString *)strIPAddress port:(NSInteger)port;
- (void) setDisplayUIImageView:(IRFFVideoInput *)tmpView;
- (NSUInteger) startConnection;
- (BOOL) stopConnection:(BOOL) _blnForever;
- (void) setCurrentOrientation:(UIInterfaceOrientation)currentOrientation;
- (void) setVideoCodecWithCodecString:(NSString*) strCodec;
- (void) setAudioCodecWithCodecString:(NSString*) strCodec;
- (void) setExtraData:(NSInteger) _iLen extraData:(uint8_t *) _extraData;
- (void) setPlayAudio:(BOOL) _blnPlay;
- (void) setChannel :(NSInteger) _ch;

@end
