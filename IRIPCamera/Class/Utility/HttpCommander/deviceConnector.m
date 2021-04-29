//
//  streamConnector.m
//  PJTunnel
//
//  Created by Robert on 2014/5/12.
//  Copyright (c) 2014年 Daniel. All rights reserved.
//

#import "deviceConnector.h"
#import "DeviceClass.h"

@interface deviceConnector(Private)
-(void) startLoginToDevice;
-(void) startReLoginToDevice;
-(void) startCheckStatus;
-(void) stopOthersConnectorByConnecedId:(NSInteger) _connectedID;
@end

@implementation deviceConnector
@synthesize delegate;
@synthesize m_ConnectorType;
@synthesize m_blnHasReported;
@synthesize m_blnCheckStatus;
//@synthesize conectSignalFailed;
@synthesize m_ConnectionFailCounter;
@synthesize m_DDNSConnector;
@synthesize m_CommandConnector ,m_AddressConnector, m_DeviceConnector;
@synthesize m_deviceInfo;

-(id) deviceConnectorWithAddress:(GroupAddress) _address port:(GroupPort) _commandPort user:(NSString*) _usr pwd:(NSString*) _pwd delegate:(id) _delegate deviceInfo:(id)_deviceInfo state:(connectorState) _state type:(deviceType)_type scheme:(NSString *)_scheme ConnectorType:(prefType)_connectorType
{
    if(![super init])
        return nil;
    //Support HTTP Only
    if (![_scheme isEqualToString:@"http"]) {
        _scheme = @"http";
        NSLog(@"Change Scheme");
    }
    
    m_ConnectorCounter = 0;
    self.delegate = _delegate;
    m_currentState = _state;
    m_currentConnectorType = _connectorType;
    m_originalScheme = [[NSString alloc] initWithString:_scheme];
    tmpMesage = nil;
    
    switch (_state) {
        case CHECK_ONLINE_CONNECTOR:
        {
            if (_address.commandAddress.length > 0) {
                self.m_CommandConnector = [[addressConnector alloc] initWithAddress:_address.commandAddress port:_commandPort.commandMultiPort
                                                                               user:_usr pwd:_pwd scheme:_scheme];
                self.m_CommandConnector.tag = HTTP_API_COMMAND;
                self.m_CommandConnector.delegage = self;
                m_ConnectorCounter++;
            }
            if (_address.dataAddress.length > 0 && ![_address.dataAddress isEqualToString:_address.commandAddress]) {
                self.m_AddressConnector = [[addressConnector alloc] initWithAddress:_address.dataAddress port:_commandPort.dataMultiPort
                                                                               user:_usr pwd:_pwd scheme:_scheme];
                
                self.m_AddressConnector.tag = HTTP_API_ADDRESS;
                self.m_AddressConnector.delegage = self;
                m_ConnectorCounter++;
            }
        }
            break;
        case LOGIN_CONNECTOR:
        {
            if (_address.commandAddress.length > 0) {
                self.m_CommandConnector = [[addressConnector alloc] initWithAddress:_address.commandAddress port:_commandPort.commandMultiPort
                                                                               user:_usr pwd:_pwd scheme:_scheme];
                self.m_CommandConnector.tag = HTTP_API_COMMAND;
                self.m_CommandConnector.delegage = self;
                m_ConnectorCounter++;
            }
            if (_address.dataAddress.length > 0 && ![_address.dataAddress isEqualToString:_address.commandAddress]) {
                self.m_AddressConnector = [[addressConnector alloc] initWithAddress:_address.dataAddress port:_commandPort.dataMultiPort
                                                                               user:_usr pwd:_pwd scheme:_scheme];
                
                self.m_AddressConnector.tag = HTTP_API_ADDRESS;
                self.m_AddressConnector.delegage = self;
                m_ConnectorCounter++;
            }
        }
            break;
        default:
            break;
    }
    
    self.m_deviceInfo = _deviceInfo;
    
    if ([m_originalScheme length] == 0 || [m_originalScheme isEqualToString:@"https"]) {
        m_Http_DeviceConnector = [[deviceConnector alloc] deviceConnectorWithAddress:_address port:_commandPort user:_usr pwd:_pwd delegate:_delegate deviceInfo:_deviceInfo state:_state type:_type scheme:@"http" ConnectorType:_connectorType];
    }else{
        m_Http_DeviceConnector = nil;
    }
    
    return self;
}

- (void)dealloc {
    if (self.m_CommandConnector) {
        [self.m_CommandConnector setDelegage:nil];
        self.m_CommandConnector = nil;
    }
    
    if(self.m_AddressConnector)
    {
        [self.m_AddressConnector setDelegage:nil];
        self.m_AddressConnector = nil;
    }
    
    if(self.m_DDNSConnector)
    {
        [self.m_DDNSConnector setDelegage:nil];
        self.m_DDNSConnector = nil;
    }
    
    if(self.m_deviceInfo)
    {
        self.m_deviceInfo = nil;
    }
    
    if (m_Http_DeviceConnector) {
        m_Http_DeviceConnector = nil;
    }
}

- (void)stopConnectionAction {
    if (m_Http_DeviceConnector) {
        [m_Http_DeviceConnector stopConnectionAction];
    }
    
    if(self.m_DeviceConnector)
    {
        [self.m_DeviceConnector cancelLoginToDevice];
    }
    else
    {
        if (self.m_CommandConnector) {
            [self.m_CommandConnector cancelLoginToDevice];
        }
        if (self.m_AddressConnector) {
            [self.m_AddressConnector cancelLoginToDevice];
        }
        if (self.m_DDNSConnector) {
            [self.m_DDNSConnector cancelLoginToDevice];
        }
    }
}

-(void) loginToDeviceWithGetRTSPInfo:(BOOL) _blnGetRtspInfo checkPrevious:(BOOL) _blnCheckPrevious ignoreLoginCache:(BOOL)_blnIgnoreLoginCache {
    m_blnGetRtspInfo = _blnGetRtspInfo;
    m_blnCheckPrevious = _blnCheckPrevious;
    m_blnIgnoreLoginCache = _blnIgnoreLoginCache;
    [NSThread detachNewThreadSelector:@selector(startLoginToDevice) toTarget:self withObject:nil];
}

-(void) startCheckOnlineStatus
{
    m_blnCheckStatus = YES;
    m_blnGetRtspInfo = NO;
    m_blnIgnoreLoginCache = YES;
    [NSThread detachNewThreadSelector:@selector(startCheckStatus) toTarget:self withObject:nil];
}

-(void) getVideoStreamURLByChannel:(NSInteger)_channel
{
    if (m_Http_DeviceConnector) {
        [m_Http_DeviceConnector getVideoStreamURLByChannel:_channel];
    }else{
        [self.m_DeviceConnector getVideoStreamURLByChannel:_channel];
    }
}

-(void) getTwoWayAudioInfo
{
    if (m_Http_DeviceConnector) {
        [m_Http_DeviceConnector getTwoWayAudioInfo];
    }else{
        [self.m_DeviceConnector getTwoWayAudioInfo];
    }
}

-(NSInteger) getStreamsCodecInfo:(NSMutableArray * __strong *)_aryStreamCodecInfo
{
    if (m_Http_DeviceConnector) {
        return [m_Http_DeviceConnector getStreamsCodecInfo:_aryStreamCodecInfo];
    }
    return [self.m_DeviceConnector getStreamsCodecInfo:_aryStreamCodecInfo];
}

#pragma mark deviceConnectorDelegate
-(void) failedAfterRetry:(HttpAPICommander *)_caller
{
    
}

-(void) didLoginResult:(NSInteger) _resultCode msg:(NSString *) _resultMsg caller:(HttpAPICommander *) _caller info:(NSDictionary *) _LoginInfo address:(NSString *)_strAddress port:(MultiPort)_commandPort
{
    NSLog(@"ResultCode : %zd",_resultCode);
    self.m_ConnectionFailCounter++;
    NSLog(@"F:%zd C:%zd",self.m_ConnectionFailCounter,m_ConnectorCounter);
    
    if (self.m_blnHasReported) {
        NSLog(@"HasReported");
        return;
    }
    
    if(_LoginInfo != nil && _resultCode == 0)
    {
        NSLog(@"_resultCode=%zd",_resultCode);
        [self stopOthersConnectorByConnecedId:_caller.tag];
        self.m_DeviceConnector = _caller;
        self.m_ConnectorType = _caller.tag;
    }
    
    if ((_resultCode == 0 || _resultCode == -99) && !self.m_blnHasReported)
    {
        self.m_DeviceConnector = _caller;                         //Add by Daniel 2015/01/915
        [self stopOthersConnectorByConnecedId:self.m_DeviceConnector.tag]; //Add by Daniel 2015/01/915
        
        self.m_blnHasReported = YES;
        self.m_ConnectionFailCounter = 0;
        if (_resultCode == 0) {
            if (m_Http_DeviceConnector && [[[StaticHttpRequest sharedInstance] getSchecmeFromLoginResult:_LoginInfo] isEqualToString:@"http"]) {
                [m_Http_DeviceConnector loginToDeviceWithGetRTSPInfo:m_blnGetRtspInfo checkPrevious:m_blnCheckPrevious ignoreLoginCache:m_blnIgnoreLoginCache];
            }else{
                if (m_Http_DeviceConnector) {
                    m_Http_DeviceConnector = nil;
                }
                [self.delegate didfinishLoginActionByResultType:_resultCode deviceInfo:_LoginInfo errorDesc:_resultMsg address:_strAddress port:_commandPort];
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.delegate didfinishLoginActionByResultType:_resultCode deviceInfo:_LoginInfo errorDesc:_resultMsg address:_strAddress port:_commandPort];
            });
        }
    }
    else if (_resultCode == -99 && self.m_ConnectionFailCounter == m_ConnectorCounter)
    {
        self.m_DeviceConnector = _caller;
        [self stopOthersConnectorByConnecedId:self.m_DeviceConnector.tag];
        if(!self.m_blnHasReported){
            self.m_blnHasReported = YES;
            self.m_ConnectionFailCounter = 0;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.delegate didfinishLoginActionByResultType:_resultCode deviceInfo:_LoginInfo errorDesc:_resultMsg address:_strAddress port:_commandPort];
            });
        }
    }
    //    else if (_resultCode == SYMMETRIC_NAT)
    //    {
    //        self.m_blnHasReported = YES;
    //        self.m_ConnectionFailCounter=0;
    //        [self.delegate didfinishLoginActionByResultType:-1 deviceInfo:_LoginInfo errorDesc:_resultMsg address:_strAddress port:_commandPort];
    //    }
    else if (_resultCode != 0 && !self.m_blnHasReported)
    {
        //self.m_ConnectionFailCounter++;
        NSLog(@"(%zd)%@ :%@",self.m_ConnectionFailCounter, NSStringFromClass([self.delegate class]), _resultMsg);
        
        if (_resultCode == -2 && _resultMsg) {
            tmpMesage = [[NSString alloc] initWithString:_resultMsg];
        }
        
        if(self.m_ConnectionFailCounter >= m_ConnectorCounter)
        {
            if(!self.m_blnHasReported){
                self.m_blnHasReported = YES;
                self.m_ConnectionFailCounter = 0;
                [self stopOthersConnectorByConnecedId:-1]; //Add by Daniel 2014/12/09
                if (m_currentState == CHECK_ONLINE_CONNECTOR && _resultCode == 57) {
                    //                    [self.delegate didfinishLoginActionByResultType:57 deviceInfo:_LoginInfo errorDesc:@"Connect Failed!!" address:_strAddress port:_commandPort];
                    [self startCheckOnlineStatus];
                }else if (tmpMesage != nil){
                    [self.delegate didfinishLoginActionByResultType:-2 deviceInfo:_LoginInfo errorDesc:[[NSString alloc] initWithString:tmpMesage] address:_strAddress port:_commandPort];
                }else{
                    [self.delegate didfinishLoginActionByResultType:-1 deviceInfo:_LoginInfo errorDesc:_resultMsg address:_strAddress port:_commandPort];
                }
            }
            
        }else{
            if (m_currentConnectorType != UNKNOWN_TYPE) {
                if (_caller.tag == self.m_CommandConnector.tag) {
                    [self.m_CommandConnector cancelLoginToDevice];
                }
                else if (_caller.tag == self.m_AddressConnector.tag)
                {
                    [self.m_AddressConnector cancelLoginToDevice];
                }
                else if (_caller.tag == self.m_DDNSConnector.tag)
                {
                    [self.m_DDNSConnector cancelLoginToDevice];
                }
                
                [self startReLoginToDevice];
            }
        }
    }
    
}

-(void) didGetRTSPResponse:(NSInteger)_resultCode msg:(NSString *)_msg
{
    [self.delegate didGetRTSPResponse:_resultCode msg:_msg];
}

-(void) didGetRtspURLByChannel:(NSInteger) _resultCode msg:(NSString *) _msg ch:(NSInteger) _ch url:(NSString *) _rtspURL ipRatio:(NSInteger) _IPRatio
{
    [self.delegate didGetRTSPUrlResult:_resultCode msg:_msg ch:_ch url:_rtspURL ipRatio:_IPRatio];
}

-(void)didGetTwoWayAudioResponse:(NSInteger)_resultCode msg:(NSString *)_msg
{
    [self.delegate didGetTwoWayAudioResponse:_resultCode msg:_msg];
}

-(void) didGetTwoWayAudioResult:(NSInteger) _resultCode url:(NSString *) _url type:(NSString *) _audioType sampleRate:(NSInteger) _sampleRate bps:(NSInteger) _bps
{
    [self.delegate didGetTwoWayAudioResult:_resultCode url:_url type:_audioType sampleRate:_sampleRate bps:_bps];
}

-(void) didReportFileDownloadPort:(NSInteger)_resultCode msg:(NSString *)_msg port:(NSInteger)_mappedPort
{
    if(_resultCode == 0)
    {
        [self.delegate didReportFileDownloadPort:_resultCode msg:_msg port:_mappedPort];
    }
}

-(void) didinTheSameLAN:(NSString *) _strDeviceAddress port:(MultiPort) _commandPort
{
    NSLog(@"[deviceConnector][didinTheSameLAN] %@:%zd",_strDeviceAddress, _commandPort.httpPort);
    
    if (self.m_CommandConnector) {
        [self stopOthersConnectorByConnecedId:self.m_CommandConnector.tag];
        
        self.m_CommandConnector.m_blnIsAPPAndDUTUnderTheSameLAN = YES;
        self.m_CommandConnector.m_strAddress = [NSString stringWithFormat:@"%@", _strDeviceAddress];
        self.m_CommandConnector.m_CommandPort = _commandPort;
        self.m_CommandConnector.m_RetryTime = 0;
        [self.m_CommandConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
        
    }else if(self.m_AddressConnector)
    {
        [self stopOthersConnectorByConnecedId:self.m_AddressConnector.tag];
        
        self.m_AddressConnector.m_blnIsAPPAndDUTUnderTheSameLAN = YES;
        self.m_AddressConnector.m_strAddress = [NSString stringWithFormat:@"%@", _strDeviceAddress];
        self.m_AddressConnector.m_CommandPort = _commandPort;
        self.m_AddressConnector.m_RetryTime = 0;
        [self.m_AddressConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
        
    }
    else if(self.m_DDNSConnector)
    {
        [self stopOthersConnectorByConnecedId:self.m_DDNSConnector.tag];
        
        
        self.m_DDNSConnector.m_blnIsAPPAndDUTUnderTheSameLAN = YES;
        self.m_DDNSConnector.m_strAddress = [NSString stringWithFormat:@"%@", _strDeviceAddress];
        self.m_DDNSConnector.m_CommandPort = _commandPort;
        self.m_DDNSConnector.m_RetryTime = 0;
        [self.m_DDNSConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
    }
}

-(void) updateUserName:(NSString*) _strUserName pwd:(NSString *)_strPwd
{
    NSLog(@"self.m_DeviceConnector");
    if (m_Http_DeviceConnector) {
        [m_Http_DeviceConnector updateUserName:_strUserName pwd:_strPwd];
    }
    [self.m_DeviceConnector updateUserName:_strUserName pwd:_strPwd];
}

@end


@implementation deviceConnector(Private)

-(void) startLoginToDevice
{
    self.m_blnHasReported = NO;
    
    if (m_ConnectorCounter == 0) {
        [self didLoginResult:-1 msg:@"connect failed " caller:nil info:nil address:nil port:MultiPortZero()];
        return;
    }
    
    if (self.m_CommandConnector) {
        self.m_CommandConnector.m_RetryTime = 0;
        self.m_CommandConnector.m_blnStopConnection = NO;
        [self.m_CommandConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
    }
    
    switch (m_currentConnectorType) {
        case ADDRESS_TYPE:
        {
            if(self.m_AddressConnector)
            {
                self.m_AddressConnector.m_RetryTime = 0;
                self.m_AddressConnector.m_blnStopConnection = NO;
                [self.m_AddressConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
            }
        }
            break;
        case DDNS_TYPE:
        {
            if(self.m_DDNSConnector)
            {
                self.m_DDNSConnector.m_RetryTime = 0;
                self.m_DDNSConnector.m_blnStopConnection = NO;
                [self.m_DDNSConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
            }
        }
            break;
        default:
        {
            if(self.m_AddressConnector)
            {
                self.m_AddressConnector.m_RetryTime = 0;
                self.m_AddressConnector.m_blnStopConnection = NO;
                [self.m_AddressConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
            }
            if(self.m_DDNSConnector)
            {
                self.m_DDNSConnector.m_RetryTime = 0;
                self.m_DDNSConnector.m_blnStopConnection = NO;
                [self.m_DDNSConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
            }
        }
            break;
    }
}

- (void)startReLoginToDevice {
    switch (m_currentConnectorType) {
        case ADDRESS_TYPE:
        {
            if(self.m_DDNSConnector)
            {
                self.m_DDNSConnector.m_RetryTime = 0;
                [self.m_DDNSConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
            }
        }
            break;
        case DDNS_TYPE:
        {
            if(self.m_AddressConnector)
            {
                self.m_AddressConnector.m_RetryTime = 0;
                [self.m_AddressConnector startLoginToDeviceWithGetStringInfo:m_blnGetRtspInfo IgnoreLoginCache:m_blnIgnoreLoginCache];
            }            
        }
            break;
        default:
            break;
    }
}

-(void)startCheckStatus
{
    self.m_blnHasReported = NO;
    
    if (m_ConnectorCounter == 0) {
        [self didLoginResult:-1 msg:@"connect failed " caller:nil info:nil address:nil port:MultiPortZero()];
        return;
    }
    
    if (self.m_CommandConnector) {
        NSLog(@"-(void) startCheckStatus~~~~~~~~~~~~~~Command:%@:%zd start check on line", self.m_CommandConnector.m_strAddress,self.m_CommandConnector.m_CommandPort.httpPort);
        self.m_CommandConnector.m_RetryTime = 3;
        [self.m_CommandConnector checkDeviceOnline];
    }
    if(self.m_AddressConnector)
    {
        NSLog(@"-(void) startCheckStatus~~~~~~~~~~~~~~Address:%@:%zd start check on line", self.m_AddressConnector.m_strAddress,self.m_AddressConnector.m_CommandPort.httpPort);
        self.m_AddressConnector.m_RetryTime = 3;
        [self.m_AddressConnector checkDeviceOnline];
    }
    if(self.m_DDNSConnector)
    {
        NSLog(@"-(void) startCheckStatus~~~~~~~~~~~~~~DDNS:%@:%zd start check on line", self.m_DDNSConnector.m_strAddress,self.m_DDNSConnector.m_CommandPort.httpPort);
        self.m_DDNSConnector.m_RetryTime = 3;
        [self.m_DDNSConnector checkDeviceOnline];
    }
}

-(void) stopOthersConnectorByConnecedId:(NSInteger) _connectedID
{
    NSLog(@"stopOthersConnectorByConnecedId:%zd", _connectedID);
    if (_connectedID != self.m_CommandConnector.tag) {
        [self.m_CommandConnector cancelLoginToDevice];
    }
    if (_connectedID != self.m_AddressConnector.tag)
    {
        [self.m_AddressConnector cancelLoginToDevice];
    }
    if (_connectedID != self.m_DDNSConnector.tag)
    {
        [self.m_DDNSConnector cancelLoginToDevice];
    }
}

@end
