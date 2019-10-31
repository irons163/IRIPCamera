//
//  deviceInfo.h
//  live555Client
//
//  Created by sniApp on 12/10/4.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface deviceInfo : NSObject
{
    NSString    *m_strDeviceLocation;
    NSString    *m_strUserName;
    NSString    *m_strPassword;
    NSUInteger  m_PortNumber;
}

-(id) initWithURL:(NSString *) strURLorIP useuName:(NSString *) _userNsme password:(NSString *) _Password port:(NSUInteger) _port;

@end
