//
//  IRCustomStreamConnectionRequest.h
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRStreamConnectionRequest.h"
#import "DeviceClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRCustomStreamConnectionRequest : IRStreamConnectionRequest

@property DeviceClass *device;

@end

NS_ASSUME_NONNULL_END
