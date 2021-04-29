//
//  IRCustomStreamConnector.h
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
#import "IRStreamConnector.h"

@import CoreMotion;
@class DeviceClass;

NS_ASSUME_NONNULL_BEGIN

@interface IRCustomStreamConnector : IRStreamConnector <UIAlertViewDelegate, deviceConnectorDelegate> {
@private
    StaticHttpRequest *m_httpRequest;
    NSMutableArray *m_aryStreamInfo;
}

@property deviceConnector *m_deviceConnector;
@property DeviceClass *m_deviceInfo;
@property BOOL m_blnStopforever;

- (void)startStreamConnection;
- (NSInteger)stopStreaming:(BOOL)_blnStopForever;
- (void)changeStream :(NSInteger) _stream;
- (int)getErrorCode;

@end



NS_ASSUME_NONNULL_END
