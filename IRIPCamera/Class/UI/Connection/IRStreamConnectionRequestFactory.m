//
//  IRStreamConnectionRequestFactory.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRStreamConnectionRequestFactory.h"
#import "IRCustomStreamConnectionRequest.h"

@implementation IRStreamConnectionRequestFactory

+ (NSArray<IRStreamConnectionRequest *> *)createStreamConnectionRequest {
    NSMutableArray *m_aryDevices = [NSMutableArray array];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:ENABLE_RTSP_URL_KEY] boolValue]) {
        IRStreamConnectionRequest *request = [[IRStreamConnectionRequest alloc] init];
        request.rtspUrl = [userDefaults objectForKey:RTSP_URL_KEY];
        [m_aryDevices addObject:request];
    } else {
        DeviceClass *device = [[DeviceClass alloc] init];
        IRCustomStreamConnectionRequest *request = [[IRCustomStreamConnectionRequest alloc] init];
        request.device = device;
        [m_aryDevices addObject:request];
    }
    
    return m_aryDevices;
}
@end

