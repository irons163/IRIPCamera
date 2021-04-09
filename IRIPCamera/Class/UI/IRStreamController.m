//
//  IRStreamController.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRStreamController.h"
#import "IRCustomStreamConnector.h"
#import "IRGLRenderModeFactory.h"

#define LOGIN_IPCAM_CALLBACK    0X0001
#define GET_RTSPINFO_CALLBACK   0X0010
#define GET_AUDIOOUT_CALLBACK   0X0100
#define GET_FISHEYE_CENTER_CALLBACK 0X1000

@interface IRStreamController () <ReceiverDelegate, IRStreamConnectorDelegate>

- (void)showReconnectFailByType:(NSInteger)_iType errorDesc:(NSString *)_strErrorDesc;
- (void)showStreamingFailByType:(NSInteger)_iType;

@end

@implementation IRStreamController {
    IRStreamConnector *streamConnector;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initStreamingQueue];
        
        m_httpRequest = [StaticHttpRequest sharedInstance];
        
        m_aryRtspURL = [[NSMutableArray alloc] init];
        m_aryStreamInfo = [[NSMutableArray alloc] init];
        m_aryIPRatio = [[NSMutableArray alloc] init];
        
        m_blnStopStreaming = NO;
        m_blnUseTCP = NO;
        m_blnStopforever = NO;
        m_blnShowAuthorityAlert = NO;
    }
    return self;
}

- (instancetype)initWithRtspUrl:(NSString *)rtspURL {
    if(self = [self init]){
        streamConnector = [[IRStreamConnector alloc] init];
        streamConnector.delegate = self;
        streamConnector.rtspURL = rtspURL;
    }
    return self;
}

- (instancetype)initWithDevice:(DeviceClass *)device {
    if(self = [self init]){
        streamConnector = [[IRCustomStreamConnector alloc] init];
        streamConnector.delegate = self;
        ((IRCustomStreamConnector*)streamConnector).m_deviceInfo = device;
        
        [self setDeviceClass:device ch:0];
    }
    return self;
}

- (void)startStreamingWithResponse:(IRStreamConnectionResponse *)response {
    if (modes == nil && [response.deviceModelName isEqualToString:@"FisheyeCAM"]) {
        if(!parameter)
            parameter = [[IRFisheyeParameter alloc] initWithWidth:1440 height:1024 up:NO rx:510 ry:510 cx:680 cy:524 latmax:75];
        modes = [self createFisheyeModesWithParameter:parameter];
        if(self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(updatedVideoModes)]){
            [self.eventDelegate updatedVideoModes];
        }
    } else if (modes == nil) {
        if(self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(updatedVideoModes)]){
            [self.eventDelegate updatedVideoModes];
        }
    }
    
    m_aryStreamInfo = [response.streamsInfo mutableCopy];
    m_currentURL = response.rtspURL;
    
    if (m_RTSPStreamer) {
        [m_RTSPStreamer stopConnection:NO];
        m_RTSPStreamer = nil;
        NSLog(@"Restart!!");
    }
    
    dispatch_async(streamingQueue, ^{
        if (self->m_currentURL) {
            NSLog(@"Start Stream id=%ld ,name=%@ ,url=%@",(long)self->m_deviceInfo.m_deviceId,self->m_deviceInfo.m_deviceName,self->m_currentURL);
            
            NSInteger httpPort = self->m_deviceInfo.m_httpPort.httpPort;
            
            self->m_RTSPStreamer = [[RTSPReceiver alloc] initDeviceWithUserName:self->m_deviceInfo.m_userName
                                    
                                                                       password:self->m_deviceInfo.m_password
                                                                             IP:self->m_currentURL
                                                                           port:httpPort
                                                                         useTCP:self->m_blnUseTCP
                                                                            FPS:self->m_deviceInfo.m_ipratio
                                    ];
            
            [self->m_RTSPStreamer setEventDelegate:self];
            
            if (!self->m_RTSPStreamer.m_VideoDecoder.showView) {
                [self->m_RTSPStreamer setDisplayUIImageView:self.m_videoView.videoInput];
            }
            
            [self->m_RTSPStreamer setChannel:self->m_Channel];
            [self->m_RTSPStreamer.m_audioDecoder setDelegate:self.AudioDelegate];
            [self->m_RTSPStreamer setPlayAudio:YES];
            [self->m_RTSPStreamer startConnection];
            
            self->m_blnStopStreaming = NO;
        } else {
            NSLog(@"streams=%zd ",self->m_AvailableStrems);
            self->m_blnStopStreaming = YES;
        }
    });
}

- (void)connectFailByType:(NSInteger)_iType errorDesc:(NSString *)_strErrorDesc {
    [self showReconnectFailByType:_iType errorDesc:_strErrorDesc];
}

- (void)reconnectToDevice {
    if(!m_blnStopStreaming && m_ReconnectTimes < MAX_RETRY_TIMES) {
        [self startShow];
        //        [self setDeviceClass:m_deviceInfo ch:m_Channel];
        [streamConnector startStreamConnection];
        m_ReconnectTimes++;
    }
}

- (void)initStreamingQueue {
    if(!streamingQueue)
        streamingQueue = dispatch_queue_create("streaming.queue", DISPATCH_QUEUE_SERIAL);
}

- (void)setDeviceClass:(DeviceClass *)_deviceInfo ch:(NSInteger)_ch {
    m_deviceInfo = _deviceInfo;
    m_deviceInfo.m_strStreamInfo = nil;
    m_Channel = _ch;
    
    NSLog(@"device name=%@",_deviceInfo.m_deviceName);
}

- (void)startStreamConnection {
    [self.eventDelegate streamControllerStatusChanged:IRStreamControllerStatus_PreparingToPlay];
    [streamConnector startStreamConnection];
}

- (NSInteger)stopStreaming:(BOOL)_blnStopForever {
    m_blnStopStreaming = YES;
    m_blnStopforever = _blnStopForever;
    
    if (m_RTSPStreamer)
    {
        //dispatch_async(streamingQueue, ^{
        [m_RTSPStreamer stopConnection:_blnStopForever];
        //});
    }
    
    return [streamConnector stopStreaming:_blnStopForever];
}

- (void)dealloc {
    if (m_RTSPStreamer) {
        [m_RTSPStreamer stopConnection:YES];
        m_RTSPStreamer = nil;
    }
}

- (void)videoLossWithErrorCode:(int)_code msg:(NSString *)_strmsg {
    NSLog(@"videoLossWithErrorCode: %d msg: %@",_code,_strmsg);
    
    if (m_deviceInfo.m_httpCMDAddress) {
        if (!m_blnStopStreaming && !m_blnStopforever) {
            [streamConnector stopStreaming:m_blnStopforever];
            
            if (m_ReconnectTimes < MAX_RETRY_TIMES) {
                [self performSelectorOnMainThread:@selector(reconnectToDevice) withObject:nil waitUntilDone:NO];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self showStreamingFailByType:_code];
                });
            }
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self showStreamingFailByType:_code];
        });
    }
}

#pragma ReceiverDelegate
- (void) videoLoss:(id)_sender ErrorCode:(int)_code msg:(NSString *)_strmsg {
    if(self)
        [self videoLossWithErrorCode:(int)_code msg:(NSString *)_strmsg];
}

- (void)connectSuccess:(id)_sender {
    NSLog(@"Video connect success");
    m_ReconnectTimes = 0;
    m_blnStopStreaming = NO;
    [self showHideLoading:YES];
}

- (void)onResolutionChange {
    
}

- (void)didFinishStaticRequestJSON:(NSDictionary *)_strAckResult callbackID:(NSUInteger)_callback {
    float width = [[_strAckResult objectForKey:@"GetWidth"] floatValue];
    float height = [[_strAckResult objectForKey:@"GetHheight"] floatValue];
    float centerX = [[_strAckResult objectForKey:@"GetCenterX"] floatValue];
    float centerY = [[_strAckResult objectForKey:@"GetCenterY"] floatValue];
    float radius = [[_strAckResult objectForKey:@"GetCenterR"] floatValue];
    parameter = [[IRFisheyeParameter alloc] initWithWidth:width height:height up:NO rx:radius ry:radius cx:centerX cy:centerY latmax:75];
    modes = [self createFisheyeModesWithParameter:parameter];
    
    if(!m_blnStopStreaming && !m_blnStopforever)
    {
        m_blnShowAuthorityAlert = NO;
        //            [NSThread detachNewThreadSelector:@selector(startStreaming) toTarget:self withObject:nil];
    }
}

- (void)failToStaticRequestWithErrorCode:(NSInteger)_iFailStatus description:(NSString *)_desc callbackID:(NSUInteger)_callback {
    //    [m_LoadingActivity stopAnimating];
    NSLog(@"%@",_desc);
    m_blnShowAuthorityAlert = NO;
    
    if(!m_blnStopStreaming && _callback != GET_AUDIOOUT_CALLBACK)
    {
        if(m_ReconnectTimes < MAX_RETRY_TIMES && _iFailStatus != 401 && !m_blnStopforever)
        {
            
            //            [self performSelectorOnMainThread:@selector(reconnectStream) withObject:nil waitUntilDone:NO];
            //            [self reconnectToDevice];
            [NSThread detachNewThreadSelector:@selector(reconnectToDevice) toTarget:self withObject:nil];
        }
        else if (_iFailStatus == 401)
        {
            m_blnShowAuthorityAlert = YES;
            
        }
        else
        {
            NSString *errorTitleTmp = _(@"LinkFailTitle");
            NSString *errorTitle = [NSString stringWithFormat:@"%@:%zd",errorTitleTmp ,_iFailStatus];
            NSString *strAddress=[NSString stringWithFormat:@"http://%@:%zd",m_deviceInfo.m_deviceAddress ,m_deviceInfo.m_httpPort.httpPort];
            NSString *strDeviceName = [NSString stringWithFormat:@"%@",m_deviceInfo.m_deviceName];
            NSString *strShow =[NSString stringWithFormat:@"%@\n%@\n%@",strDeviceName ,strAddress ,_desc];
            
            
            UIAlertView *tmpView = [[UIAlertView alloc] initWithTitle:errorTitle
                                                              message:strShow
                                                             delegate:nil
                                                    cancelButtonTitle:_(@"ButtonTextOk")
                                                    otherButtonTitles:nil, nil];
            
            [tmpView show];
            
            //            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //            appDelegate.sharedAlertView = tmpView;
        }
        
    }
}

- (BOOL)IsStopStreaming {
    if(!m_deviceInfo)
        m_blnStopStreaming = YES;
    
    return m_blnStopStreaming;
}

- (void)changeStream:(NSInteger)_stream {
    if(m_deviceInfo.m_streamNO != _stream)
    {
        [self performSelectorOnMainThread:@selector(startShow) withObject:nil waitUntilDone:NO];
        m_deviceInfo.m_strStreamInfo = [m_aryStreamInfo objectAtIndex:_stream];
        m_deviceInfo.m_streamNO = _stream;
        
        [self stopStreaming:NO];
        
        [NSThread detachNewThreadSelector:@selector(dochangeStream:) toTarget:self withObject:[NSNumber numberWithInteger:_stream]];
        
    }
}

- (void)dochangeStream:(NSInteger)_stream {
    if(!m_blnStopforever)
    {
        [streamConnector changeStream:_stream];
    }
}

- (void)startShow {
    //    [self.eventDelegate connectReslt:self Connection:NO MicSupport:NO SpeakerSupport:NO];
    [self.eventDelegate streamControllerStatusChanged:IRStreamControllerStatus_PreparingToPlay];
}

- (NSInteger)getCurrentStream {
    return m_deviceInfo.m_streamNO;
}

- (NSArray<IRGLRenderMode *> *)getRenderModes {
    return [self.m_videoView renderModes];
}

- (IRGLRenderMode *)getCurrentRenderMode {
    return [self.m_videoView renderMode];
}

- (void)setCurrentRenderMode:(IRGLRenderMode *)renderMode {
    [self.m_videoView selectRenderMode:renderMode];
}

//-(void) reconnectStream
//{
//    m_ReconnectTimes++;
//    if(m_ReconnectTimes <= MAX_RETRY_TIMES)
//    {
//        [self setDeviceClass:m_deviceInfo ch:m_Channel];
//    }
//    else
//        m_ReconnectTimes = YES;
//}

//1. call Live555RTSPServer start
- (void)startTwoWayAudio:(BOOL)_blnToDevice {
    
}

- (void)stopTwoWayAudio:(BOOL)_blnToDevice {
    
}

- (void)showHideLoading:(BOOL)_connected {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (_connected) {
            [self.eventDelegate connectReslt:self Connection:YES MicSupport:NO SpeakerSupport:NO];
        }else{
            [self.eventDelegate connectReslt:self Connection:NO MicSupport:NO SpeakerSupport:NO];
        }
    });
}

- (void)parseJSONCommand:(NSDictionary *)_jsonDictionary {
    NSDictionary *tmpList = [_jsonDictionary valueForKey:@"StreamSettings"];
    NSArray *Streams = [tmpList valueForKey:@"StreamSetting"];
    
    m_AvailableStrems = 0;
    [m_aryIPRatio removeAllObjects];
    [m_aryRtspURL removeAllObjects];
    [m_aryStreamInfo removeAllObjects];
    
    for (int i = 0; i < [Streams count]; i++)
    {
        NSDictionary *stream = [Streams objectAtIndex:i];
        if(stream)
        {
            if([stream objectForKey:@"Enable"])
            {
                if(![stream objectForKey:@"Enable"])
                    continue;
            }
            
            m_AvailableStrems++;
            
            NSString *strInfo = [NSString stringWithFormat:@"%@ (%@)",[stream objectForKey:@"Codec"], [stream objectForKey:@"Resolution"]];
            NSLog(@"%@",[stream objectForKey:@"URL"]);
            [m_aryRtspURL addObject:[stream objectForKey:@"URL"]];
            [m_aryStreamInfo addObject:strInfo];
            [m_aryIPRatio addObject:[NSNumber numberWithInteger:[[stream objectForKey:@"FPS"] integerValue]]];
        }
    }
}

- (void)showReconnectFailByType:(NSInteger)_iType errorDesc:(NSString *)_strErrorDesc {
    NSString *strShow = _(@"ReconnectStreamConnectFail");
    
    int errorCode = -99999;
    
    if (_iType == AuthorizationError)
    {
        strShow = _(@"loginFail");
    }else if (_iType == NotSupported)
    {
        strShow = _(@"DEVCE_NOT_SUPPORTED");
    }
    else if (_iType == -2 && [m_errorMsg length] > 0)
    {
        errorCode = [self getErrorCode];
        strShow = m_errorMsg;
    }
    else {
        errorCode = [self getErrorCode];
        strShow = _(@"ConnectFail");
    }
    
    [self.eventDelegate showErrorMessage:strShow];
    
    [self showHideLoading:NO];
}

- (void)showStreamingFailByType:(NSInteger)_iType {
    NSString *strShow = _(@"ReconnectStreamConnectFail");
    
    strShow = [NSString stringWithFormat:@"%@(%ld)", strShow, (long)_iType];
    [self.eventDelegate showErrorMessage:strShow];
    
    [self showHideLoading:NO];
}

- (int)getErrorCode {
    return [streamConnector getErrorCode];
}

#pragma mark - Wide Functions
- (BOOL)resetUnit {
    [self stopMotionDetection];
    
    if ([m_deviceInfo getWideDegreeValue] == 0) {
        return NO;
    }
    
    return YES;
}

- (void)stopMotionDetection {
    //    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    [appDelegate.motionManager stopDeviceMotionUpdates];
}

- (NSArray<IRGLRenderMode *> *)createFisheyeModesWithParameter:(nullable IRMediaParameter *)parameter {
    IRGLRenderMode *normal = [[IRGLRenderMode2D alloc] init];
    IRGLRenderMode *fisheye2Pano = [[IRGLRenderMode2DFisheye2Pano alloc] init];
    IRGLRenderMode *fisheye = [[IRGLRenderMode3DFisheye alloc] init];
    IRGLRenderMode *fisheye4P = [[IRGLRenderModeMulti4P alloc] init];
    NSArray<IRGLRenderMode*>* modes = @[
        fisheye2Pano,
        fisheye,
        fisheye4P,
        normal
    ];
    
    normal.shiftController.enabled = NO;
    
    fisheye2Pano.contentMode = IRGLRenderContentModeScaleAspectFill;
    fisheye2Pano.wideDegreeX = 360;
    fisheye2Pano.wideDegreeY = 20;
    
    fisheye4P.parameter = fisheye.parameter = [[IRFisheyeParameter alloc] initWithWidth:0 height:0 up:NO rx:0 ry:0 cx:0 cy:0 latmax:80];
    fisheye4P.aspect = fisheye.aspect = 16.0 / 9.0;
    
    normal.name = @"Rawdata";
    fisheye2Pano.name = @"Panorama";
    fisheye.name = @"Onelen";
    fisheye4P.name = @"Fourlens";
    
    return modes;
}

@end

