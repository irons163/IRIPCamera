//
//  streamConnector.h
//  PJTunnel
//
//  Created by Robert on 2014/5/12.
//  Copyright (c) 2014年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "addressConnector.h"

typedef enum _connectorState
{
    CHECK_ONLINE_CONNECTOR,
    LOGIN_CONNECTOR
}connectorState;

typedef enum _prefType
{
    UNKNOWN_TYPE,
    ADDRESS_TYPE,
    DDNS_TYPE
}prefType;

@protocol deviceConnectorDelegate <NSObject>

@optional
-(void) didfailedConnectToDevice;
-(void) didfinishLoginActionByResultType:(NSInteger) _resultCode deviceInfo:(NSDictionary *) _deviceInfo errorDesc :(NSString *) _strErrorDesc address:(NSString *) _strAddress port:(MultiPort) _commandPort;
-(void) didGetRTSPResponse:(NSInteger)_resultCode msg:(NSString *)_msg;
-(void) didGetRTSPUrlResult:(NSInteger) _resultCode msg:(NSString *) _msg ch:(NSInteger) _ch url:(NSString *) _rtspURL ipRatio:(NSInteger) _IPRatio;
-(void) didGetTwoWayAudioResponse:(NSInteger) _resultCode msg:(NSString *) _msg;
-(void) didGetTwoWayAudioResult:(NSInteger) _resultCode url:(NSString *) _url type:(NSString *) _audioType sampleRate:(NSInteger) _sampleRate bps:(NSInteger) _bps;
-(void) didReportFileDownloadPort:(NSInteger)_resultCode msg:(NSString *)_msg port:(NSInteger)_mappedPort;
@end

@interface deviceConnector : NSObject<HttpAPICommanderDelegate>
{
    HttpAPICommander *m_CommandConnector;
    addressConnector *m_AddressConnector;
    addressConnector *m_DDNSConnector;
    HttpAPICommander *m_DeviceConnector;
    BOOL m_blnGetRtspInfo;
    BOOL m_blnCheckPrevious;
    BOOL m_blnIgnoreLoginCache;
    __weak id<deviceConnectorDelegate> delegate;
    NSInteger m_ConnectorType;
    BOOL m_blnHasReported;
    NSString* tmpMesage;
    NSInteger m_ConnectionFailCounter;
    
    NSInteger m_ConnectorCounter;
    
    NSString* m_originalScheme;
    
    id m_deviceInfo;
    
    
    connectorState m_currentState;
    prefType m_currentConnectorType;
    
    deviceConnector* m_Http_DeviceConnector;
}
@property (nonatomic, weak) id<deviceConnectorDelegate> delegate;
@property (nonatomic) NSInteger m_ConnectorType;
@property (nonatomic) BOOL m_blnHasReported;
@property (nonatomic) BOOL m_blnCheckStatus; //is do check status
@property (nonatomic) BOOL conectSignalFailed;
@property (nonatomic) NSInteger m_ConnectionFailCounter;
@property (nonatomic, retain) HttpAPICommander *m_CommandConnector;
@property (nonatomic, retain) addressConnector *m_AddressConnector;
@property (nonatomic, retain) addressConnector *m_DDNSConnector;
@property (nonatomic, retain) HttpAPICommander *m_DeviceConnector;
@property (nonatomic, retain) id m_deviceInfo;

-(id) deviceConnectorWithAddress:(GroupAddress) _address
                            port:(GroupPort) _commandPort
                            user:(NSString*) _usr
                             pwd:(NSString*) _pwd
                        delegate:(id) _delegate
                      deviceInfo:(id) _deviceInfo
                           state:(connectorState) _state
                            type:(deviceType) _type
                          scheme:(NSString*)_scheme
                   ConnectorType:(prefType)_connectorType;
-(void) loginToDeviceWithGetRTSPInfo:(BOOL) _blnGetRtspInfo checkPrevious:(BOOL) _blnCheckPrevious ignoreLoginCache:(BOOL)_blnIgnoreLoginCache;

-(void) getVideoStreamURLByChannel:(NSInteger) _channel;
-(void) getTwoWayAudioInfo;
-(NSInteger) getStreamsCodecInfo:(NSMutableArray * __strong *) _aryStreamCodecInfo;
-(void) stopConnectionAction;
-(void) updateUserName:(NSString*) _strUserName pwd:(NSString *)_strPwd;

-(void) startCheckOnlineStatus;

@end
