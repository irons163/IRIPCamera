//
//  addressConnector.h
//  PJTunnel
//
//  Created by Robert on 2014/5/12.
//  Copyright (c) 2014年 Daniel. All rights reserved.
//

#import "HttpAPICommander.h"

@interface addressConnector : HttpAPICommander<StaticHttpRequestDelegate>

-(void) startLoginToDeviceWithGetStringInfo:(BOOL) _blnGetStreamInfo IgnoreLoginCache:(BOOL)_blnIgnoreLoginCache;

@end
