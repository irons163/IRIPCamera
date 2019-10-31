//
//  IRStreamConnector.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRStreamConnector.h"
#import "deviceClass.h"
#import "dataDefine.h"
#import "AppDelegate.h"

#define LOGIN_IPCAM_CALLBACK    0X0001
#define GET_RTSPINFO_CALLBACK   0X0010
#define GET_AUDIOOUT_CALLBACK   0X0100
#define GET_FISHEYE_CENTER_CALLBACK 0X1000

#define MinZoomScale 1.0
#define RangeY 20.0

#define Login_Failed_via_UID 18
#define Login_Failed_via_Direct_Access 19
#define Login_Failed_via_IP 20

#define ERROR_DEVICE_NOT_ONLINE -3

@interface IRStreamConnector(PrivateMethod)
@end

@implementation IRStreamConnector

-(void)startStreamConnection{
    response = [[IRStreamConnectionResponse alloc] init];
    response.rtspURL = self.rtspURL;
    videoRetry = 0;
    
    [self.delegate startStreamingWithResponse:response];
}

-(NSInteger) stopStreaming:(BOOL)_blnStopForever
{
    NSInteger iRtn = 0;
    
//    if(_blnStopForever)
//    {
//        if (useRelay) {
//            [self.delegate connectFailByType:RelayTimeout errorDesc:nil];
//        }
//    }
    
    return iRtn;
}

-(void) changeStream :(NSInteger) _stream
{
    
}

-(int)getErrorCode{
    int errorCode = -1;
    return errorCode;
}

@end

