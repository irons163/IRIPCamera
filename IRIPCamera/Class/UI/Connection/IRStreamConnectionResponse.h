//
//  IRStreamConnectionResponse.h
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRStreamConnectionResponse : NSObject

@property NSString *rtspURL;
@property NSString *deviceModelName;
@property NSArray *streamsInfo;
//@property MediaParameter *mediaParameter;

@end

NS_ASSUME_NONNULL_END
