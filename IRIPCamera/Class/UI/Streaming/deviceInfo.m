//
//  deviceInfo.m
//  live555Client
//
//  Created by sniApp on 12/10/4.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "deviceInfo.h"

@implementation deviceInfo

-(id)initWithURL:(NSString *)strURLorIP useuName:(NSString *)_userNsme password:(NSString *)_Password port:(NSUInteger)_port
{
    m_strDeviceLocation = [NSString stringWithFormat:@"%@", strURLorIP];
    m_strUserName = [NSString stringWithFormat:@"%@", _userNsme];
    m_strPassword = [NSString stringWithFormat:@"%@", _Password];
    m_PortNumber  = _port;
    return self;
}

-(void) dealloc
{
    m_strDeviceLocation = @"";
    m_strUserName = @"";
    m_strPassword = @"";
    m_PortNumber = 0;
}
@end
