//
//  IRStreamConnector.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRStreamConnector.h"
#import "DeviceClass.h"
#import "AppDelegate.h"

@implementation IRStreamConnector

- (void)startStreamConnection {
    response = [[IRStreamConnectionResponse alloc] init];
    response.rtspURL = self.rtspURL;
    videoRetry = 0;
    
    [self.delegate startStreamingWithResponse:response];
}

-(NSInteger) stopStreaming:(BOOL)_blnStopForever {
    NSInteger iRtn = 0;
    
    //    if(_blnStopForever)
    //    {
    //        if (useRelay) {
    //            [self.delegate connectFailByType:RelayTimeout errorDesc:nil];
    //        }
    //    }
    
    return iRtn;
}

- (void) changeStream :(NSInteger) _stream {
    
}

- (int)getErrorCode {
    int errorCode = -1;
    return errorCode;
}

@end

