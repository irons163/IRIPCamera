//
//  deviceConnector.h
//  PJTunnel
//
//  Created by Robert on 2014/5/12.
//  Copyright (c) 2014年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "StaticHttpRequest.h"
#import "DataDefine.h"

/* MultiPort */
struct MultiPort{
    NSInteger httpPort;
    NSInteger httpsPort;
    NSInteger videoPort;
    NSInteger audioPort;
    NSInteger normalPort;
    NSInteger downloadPort;
};
typedef struct MultiPort MultiPort;

CG_EXTERN bool MultiPortEqualToPort(MultiPort port1, MultiPort port2);

CG_INLINE MultiPort
MultiPortInitial()
{
    MultiPort multiPort;
    multiPort.httpPort     = HTTP_APP_COMMAND_PORT;
    multiPort.httpsPort    = HTTPS_APP_COMMAND_PORT;
    multiPort.videoPort    = VIDEO_PORT;
    multiPort.audioPort    = AUDIO_PORT;
    multiPort.normalPort   = NORMAL_PORT;
    multiPort.downloadPort = DOWNLOAD_PORT;
    return multiPort;
}

CG_INLINE MultiPort
MultiPortZero()
{
    MultiPort multiPort;
    multiPort.httpPort     = 0;
    multiPort.httpsPort    = 0;
    multiPort.videoPort    = 0;
    multiPort.audioPort    = 0;
    multiPort.normalPort   = 0;
    multiPort.downloadPort = 0;
    return multiPort;
}

CG_INLINE bool
__MultiPortEqualToPort(MultiPort port1, MultiPort port2)
{
    return port1.httpPort == port2.httpPort
    && port1.httpsPort == port2.httpsPort
    && port1.videoPort == port2.videoPort
    && port1.audioPort == port2.audioPort
    && port1.normalPort == port2.normalPort
    && port1.downloadPort == port2.downloadPort;
}
#define MultiPortEqualToPort __MultiPortEqualToPort

/* End MultiPort */

/* GroupPort */
struct GroupPort{
    MultiPort dataMultiPort;
    MultiPort commandMultiPort;
};
typedef struct GroupPort GroupPort;

CG_INLINE GroupPort GroupPortMake(MultiPort dataPort, MultiPort commandPort);

CG_INLINE GroupPort
GroupPortMake(MultiPort dataPort, MultiPort commandPort)
{
    GroupPort groupPort;
    groupPort.dataMultiPort = dataPort;
    groupPort.commandMultiPort = commandPort;
    return groupPort;
}
/* End GroupPort*/

/* GroupAddress*/
struct GroupAddress{
    __unsafe_unretained NSString* dataAddress;
    __unsafe_unretained NSString* commandAddress;
};
typedef struct GroupAddress GroupAddress;

CG_INLINE GroupAddress GroupAddressMake(NSString* dataAddress, NSString* commandAddress);

CG_INLINE
GroupAddress GroupAddressMake(NSString* dataAddress, NSString* commandAddress)
{
    GroupAddress groupAddress;
    groupAddress.dataAddress = dataAddress;
    groupAddress.commandAddress = commandAddress;
    return groupAddress;
}
/* End GroupAddress*/

typedef enum {
    DoDeviceLogin
    ,GetVideoInfo
    ,GetTwoWayAudioInfo
    
} deviceConnectorCommandStatus;

typedef enum
{
    HTTP_API_ADDRESS=0
    ,HTTP_API_DDNS=1
    ,HTTP_API_COMMAND=3
} HttpAPICommanderType;

typedef enum {
    AuthorizationError
    ,ConnectionTimeOut
    ,NotSupported
} ConnectorErrorType;

@class HttpAPICommander;

@interface deviceStreamInfo : NSObject
@property (nonatomic, retain) NSMutableArray *m_aryIPRatio;

@end

@protocol HttpAPICommanderDelegate <NSObject>

@optional
-(void) failedAfterRetry:(HttpAPICommander *) _caller;
-(void) didLoginResult:(NSInteger) _resultCode msg:(NSString *) _resultMsg caller:(HttpAPICommander *) _caller info:(NSDictionary *) _LoginInfo address:(NSString *) _strAddress port:(MultiPort) _commandPort;
-(void) didGetRTSPResponse:(NSInteger) _resultCode msg:(NSString *) _msg;
-(void) didGetRtspURLByChannel:(NSInteger) _resultCode msg:(NSString *) _msg ch:(NSInteger) _ch url:(NSString *) _rtspURL ipRatio:(NSInteger) _IPRatio;
-(void) didGetTwoWayAudioResponse:(NSInteger) _resultCode msg:(NSString *) _msg;
-(void) didGetTwoWayAudioResult:(NSInteger) _resultCode url:(NSString *) _url type:(NSString *) _audioType sampleRate:(NSInteger) _sampleRate bps:(NSInteger) _bps;
-(void) didReportFileDownloadPort:(NSInteger) _resultCode msg:(NSString*) _msg port:(NSInteger) _mappedPort;
-(void) didinTheSameLAN:(NSString *) _strDeviceAddress port:(MultiPort) _commandPort;
@end

@interface HttpAPICommander : NSObject
{
    id<HttpAPICommanderDelegate> delegage;
    NSInteger tag;
    NSInteger iErrorCount;
    NSString *errorMsg;
    ConnectorErrorType m_CurrentErrorType;
    
    BOOL m_blnIsAPPAndDUTUnderTheSameLAN;
@private
    MultiPort m_CommandPort;
    
    NSString *m_strUserName;
    NSString *m_strPassword;
    NSString *m_strUID;
    NSString *m_strAddress;
    NSString *m_strToken;
    NSString *m_strPrivilige;
    NSString* m_scheme;
    BOOL m_blnStopConnection;
    BOOL m_blnGetRTSPInfo;
    BOOL m_blnGetAudioInfo;
    BOOL m_blnStopCommandTunnel;
    BOOL m_blnIgnoreLoginCache;
    
    NSDictionary *m_VideoStreamInfo;
    NSDictionary *m_loginInfo;
    NSDictionary *m_audioInfo;
    
    NSInteger m_RetryTime;
    StaticHttpRequest *m_ASIHTTPSender;
    
    deviceType m_deviceType;
}
@property (nonatomic ,retain) id<HttpAPICommanderDelegate> delegage;
@property (nonatomic) BOOL m_blnStopConnection;
@property (nonatomic) BOOL m_blnGetRTSPInfo;
@property (nonatomic) BOOL m_blnGetAudioInfo;
@property (nonatomic) BOOL m_blnStopCommandTunnel;
@property (nonatomic) BOOL m_blnIgnoreLoginCache;
@property (nonatomic ,retain) NSString *m_strAddress;
@property (nonatomic ,retain) NSString *m_strUserName;
@property (nonatomic ,retain) NSString *m_strPassword;
@property (nonatomic ,retain) NSString *m_strUID;
@property (nonatomic ,retain) NSString *m_strToken;
@property (nonatomic ,retain) NSString *m_strPrivilige;
@property (nonatomic ,retain) NSString *m_scheme;
@property (nonatomic ,retain) NSDictionary *m_VideoStreamInfo;
@property (nonatomic ,retain) NSDictionary *m_loginInfo;
@property (nonatomic ,retain) NSDictionary *m_audioInfo;
@property (nonatomic) MultiPort m_CommandPort;
@property (nonatomic) NSInteger m_RetryTime;
@property (nonatomic) NSInteger tag;
@property (nonatomic) ConnectorErrorType m_CurrentErrorType;
@property (nonatomic) BOOL m_blnIsAPPAndDUTUnderTheSameLAN;

@property (nonatomic, retain) StaticHttpRequest *m_ASIHTTPSender;

@property (nonatomic) deviceType m_deviceType;
// port means command port
-(id) initWithAddress:(NSString *) _strIP port:(MultiPort) _port user:(NSString *) _user pwd :(NSString *) _pwd scheme:(NSString*)_scheme;
-(void) updateUserName:(NSString*) _strUserName pwd:(NSString*) _strPwd;
-(void) startLoginToDeviceWithGetStringInfo:(BOOL) _blnGetStreamInfo IgnoreLoginCache:(BOOL)_blnIgnoreLoginCache;
-(void) cancelLoginToDevice;
-(void) getVideoStreamURLByChannel:(NSInteger) _channel;
-(void) getTwoWayAudioInfo;
-(void) closeTwoWayAudio;
-(NSInteger) getStreamsCodecInfo:(NSMutableArray *__strong*) _aryStreamCodecInfo;
-(void) checkDeviceOnline;

@end



