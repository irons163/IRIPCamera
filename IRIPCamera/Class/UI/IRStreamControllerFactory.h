//
//  IRStreamControllerFactory.h
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRStreamController.h"
#import "IRStreamConnectionRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRStreamControllerFactory : NSObject

+ (IRStreamController *)createStreamControllerByRequset:(IRStreamConnectionRequest *)request;

@end

NS_ASSUME_NONNULL_END
