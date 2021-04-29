//
//  RTSPClient.h
//  RTSPClient
//
//  Copyright 2010 Dropcam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RTSPCLIENT_VERBOSITY_LEVEL 0

@protocol RTSPSubsessionDelegate;
@class RTSPReceiver;
@class RTSPSubsession;

@protocol RTSPClientSessionDelegate

- (void)didReceiveFrame:(const uint8_t *)frameData
        frameDataLength:(int)frameDataLength
       presentationTime:(struct timeval)presentationTime
 durationInMicroseconds:(unsigned)duration
              codecName:(NSString *)_codecName;
- (void)videoCallbackByCodec:(NSString *)_codec extraData:(NSData *)_extra;
- (void)audioCallbackByCodec:(NSString *)_codec sampleRate:(int)_sampleRate ch:(int)_ch extraData:(NSData *)_extra;
- (void)startPlayCallback;
- (void)tearDownCallback;
- (void)rtspFailCallbackByErrorCode:(int)_code msg:(NSString *)_strmsg;

@end

@interface RTSPClientSession : NSObject {
    struct RTSPClientSessionContext *context;
    NSURL *url;
    NSString *username;
    NSString *password;
    
    NSString *sdp;
    BOOL m_blnUseTCP;
    
    Byte* SPSData;
    Byte* PPSData;
    u_int8_t m_aryH264StartCode[4];
    
    __unsafe_unretained id <RTSPClientSessionDelegate> delegate;
    char eventLoopWatchVariable;
    
@private
    BOOL m_blnDescribeDone;
    BOOL m_blnSetupDone;
    BOOL m_blnPlayDone;
}

@property (retain, nonatomic) NSURL *url;
@property (assign) id<RTSPClientSessionDelegate> delegate;
@property BOOL m_blnUseTCP;

- (id)initWithURL:(NSURL*)url delegate:(id) _delegate;
- (id)initWithURL:(NSURL*)url username:(NSString *)username password:(NSString *)password;
- (BOOL)setupWithTCP:(BOOL) _blnUseTCP;
- (NSArray *)getSubsessions;
- (BOOL)shutdownStream;
- (NSString *)getLastErrorString;
- (NSString *)getSDP;
- (int)getSocket;
- (NSData *)getBase64DecodeString :(NSString *) strEncoded;

@end

@interface RTSPSubsession : NSObject {
    struct RTSPSubsessionContext *context;
    __unsafe_unretained id <RTSPSubsessionDelegate> delegate;
    NSString *m_url;
    RTSPReceiver *m_RTSPReceiver;
}

- (NSString *)getSessionId;
- (NSString *)getMediumName;
- (NSString *)getProtocolName;
- (NSString *)getCodecName;
- (NSUInteger)getAudioChannel;
- (NSUInteger)getAudioSmapleRate;
- (NSUInteger)getServerPortNum;
- (NSString *)getSDP_spropparametersets;
- (NSString *)getSDP_config;
- (NSUInteger)getSDP_VideoWidth;
- (NSUInteger)getSDP_VideoHeight;
- (NSUInteger)getClientPortNum;
- (int)getSocket;
- (void)increaseReceiveBufferTo:(NSUInteger)size;
- (void)setPacketReorderingThresholdTime:(NSUInteger)uSeconds;
- (BOOL)timeIsSynchronized;
- (int)getExtraData:(unsigned int *)i_extra extradata:(uint8_t **)p_extra;
- (void)setReceiver:(RTSPReceiver *)_RTSPReceiver;

@property (assign, nonatomic) id <RTSPSubsessionDelegate> delegate;

@end

@protocol RTSPSubsessionDelegate

- (void)didReceiveFrame:(const uint8_t *)frameData
        frameDataLength:(int)frameDataLength
       presentationTime:(struct timeval)presentationTime
 durationInMicroseconds:(unsigned)duration
             subsession:(RTSPSubsession *)subsession
                channel:(int)_channelID;

@end





