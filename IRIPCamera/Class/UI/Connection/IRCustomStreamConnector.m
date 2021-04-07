//
//  IRCustomStreamConnector.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRCustomStreamConnector.h"
#import "DeviceClass.h"
#import "AppDelegate.h"

@implementation IRCustomStreamConnector

- (void)startStreamConnection {
    if(!self.m_deviceConnector)
    {
        self.m_deviceConnector = [[deviceConnector alloc] deviceConnectorWithAddress:GroupAddressMake(self.m_deviceInfo.m_deviceAddress, self.m_deviceInfo.m_httpCMDAddress)
                                                                                port:GroupPortMake(self.m_deviceInfo.m_httpPort, self.m_deviceInfo.m_httpCMDPort)
                                                                                user:self.m_deviceInfo.m_userName
                                                                                 pwd:self.m_deviceInfo.m_password
                                                                            delegate:self
                                                                          deviceInfo:self.m_deviceInfo
                                                                               state:LOGIN_CONNECTOR
                                                                                type:IPCAM_TYPE
                                                                              scheme:@"http"
                                                                       ConnectorType:self.m_deviceInfo.m_prefType];
        response = [[IRStreamConnectionResponse alloc] init];
    }
    videoRetry = 0;
    [self.m_deviceConnector loginToDeviceWithGetRTSPInfo:YES checkPrevious:NO ignoreLoginCache:YES];
}

- (NSInteger)stopStreaming:(BOOL)_blnStopForever {
    NSInteger iRtn = 0;
    
    if(self.m_deviceConnector)
    {
        if(_blnStopForever)
        {
            [self.m_deviceConnector stopConnectionAction];
            [self.m_deviceConnector setDelegate:nil];
            self.m_deviceConnector = nil;
        }
    }
    
    return iRtn;
}

- (void)changeStream:(NSInteger)_stream {
    [self.m_deviceConnector getVideoStreamURLByChannel:self.m_deviceInfo.m_streamNO];
}

- (int)getErrorCode {
    int errorCode = -1;
    return errorCode;
}

- (void)didfinishLoginActionByResultType:(NSInteger)_resultCode deviceInfo:(NSDictionary *)_deviceInfo errorDesc :(NSString *)_strErrorDesc address:(NSString *)_strAddress port:(MultiPort)_commandPort {
    if (_resultCode == 0) {
        NSString *strModel = _deviceInfo[@"ModelName"];
        response.deviceModelName = strModel;
    }
    
    if(_resultCode == -1) {
        [self.delegate connectFailByType:_resultCode errorDesc:nil];
    } else if (_resultCode == -2) {
        [self.delegate connectFailByType:_resultCode errorDesc:_strErrorDesc];
    } else if (_resultCode == -99) {
        [self.delegate connectFailByType:AuthorizationError errorDesc:nil];
    }
    
    NSLog(@"didfinishLoginActionByResultType:%zd, %@",_resultCode ,_strErrorDesc);
}

- (void)didGetRTSPResponse:(NSInteger)_resultCode msg:(NSString *)_msg {
    videoRetry++;
    if (_resultCode == -97 && videoRetry > 3) {
        if(!self.m_blnStopforever)
        {
            [self.m_deviceConnector getStreamsCodecInfo:&m_aryStreamInfo];
            if(self.m_deviceInfo.m_streamNO == -1)
                self.m_deviceInfo.m_streamNO =[m_aryStreamInfo count] -1;
            
            [self.m_deviceConnector getVideoStreamURLByChannel:self.m_deviceInfo.m_streamNO];
        }
    }
    else if (_resultCode == -2 && videoRetry > 3){
        [self.delegate connectFailByType:_resultCode errorDesc:_msg];
    }
    else if(!self.m_blnStopforever)
    {
        [self.m_deviceConnector getStreamsCodecInfo:&m_aryStreamInfo];
        if(self.m_deviceInfo.m_streamNO == -1)
            self.m_deviceInfo.m_streamNO =[m_aryStreamInfo count] -1;
        
        [self.m_deviceConnector getVideoStreamURLByChannel:self.m_deviceInfo.m_streamNO];
    }
}

- (void)didGetRTSPUrlResult:(NSInteger)_resultCode msg:(NSString *)_msg ch:(NSInteger)_ch url:(NSString *)_rtspURL ipRatio:(NSInteger)_IPRatio {
    if (_resultCode == 0) {
        while (_ch >= [m_aryStreamInfo count]) {
            NSLog(@"@@ ch = %zd , array = %tu",_ch,[m_aryStreamInfo count]);
            _ch--;
        }
        
        response.streamsInfo = [m_aryStreamInfo copy];
        self.m_deviceInfo.m_strStreamInfo = [m_aryStreamInfo objectAtIndex:_ch];
        self.m_deviceInfo.m_streamNO = _ch;
        //        self.m_currentURL = [NSString stringWithFormat:@"%@", _rtspURL];
        NSLog(@"[%zd]%@",_ch ,_rtspURL);
        //        [NSThread detachNewThreadSelector:@selector(startStreaming) toTarget:self withObject:nil];
        response.rtspURL = _rtspURL;
        [self.delegate startStreamingWithResponse:response];
        
        /* //do m_httpRequest in this class is more proper.
         NSString *strCmd = [NSString stringWithFormat:GET_FISHEYE_CENTER
         ,self.m_deviceInfo.m_scheme
         ,self.m_deviceInfo.m_httpCMDAddress
         ,self.m_deviceInfo.m_httpCMDPort.httpPort
         ];
         
         [self.m_httpRequest doJsonRequestWithToken:nil
         externalLink:nil
         Url:strCmd
         method:@"GET"
         postData:nil
         callbackID:GET_FISHEYE_CENTER_CALLBACK
         target:self];
         */
    }
}

- (void)didGetTwoWayAudioResponse:(NSInteger)_resultCode msg:(NSString *)_msg {
    [self.m_deviceConnector getTwoWayAudioInfo];
}

- (void)didGetTwoWayAudioResult:(NSInteger)_resultCode url:(NSString *)_url type:(NSString *)_audioType sampleRate:(NSInteger)_sampleRate bps:(NSInteger)_bps {
    
}

@end


