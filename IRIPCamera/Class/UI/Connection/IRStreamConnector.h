//
//  IRStreamConnector.h
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "StaticHttpRequest.h"
#import "deviceConnector.h"
#import "IRStreamConnectionResponse.h"

@import CoreMotion;
@class DeviceClass;

@protocol IRStreamConnectorDelegate <NSObject>

- (void)connectFailByType:(NSInteger) _iType errorDesc :(NSString *) _strErrorDesc;
- (void)startStreamingWithResponse:(IRStreamConnectionResponse *)response;

@end

@interface IRStreamConnector : NSObject <UIAlertViewDelegate, deviceConnectorDelegate> {
@protected
    NSInteger videoRetry;
    IRStreamConnectionResponse *response;
}

@property BOOL m_blnStopforever;
@property (weak) id<IRStreamConnectorDelegate> delegate;
@property NSString *rtspURL;

- (void)startStreamConnection;
- (NSInteger)stopStreaming:(BOOL)_blnStopForever;
- (void)changeStream :(NSInteger) _stream;
- (int)getErrorCode;

@end
