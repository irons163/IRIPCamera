//
//  IRStreamConnectionRequestFactory.h
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRStreamConnectionRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRStreamConnectionRequestFactory : NSObject

+ (NSArray<IRStreamConnectionRequest *> *)createStreamConnectionRequest;

@end

NS_ASSUME_NONNULL_END
