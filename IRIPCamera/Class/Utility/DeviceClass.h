//
//  DeviceClass.h
//  IRIPCamera
//
//  Created by sniApp on 12/10/23.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//
@import CoreLocation;

#import <Foundation/Foundation.h>
#import "deviceConnector.h"

@class DeviceClass;

@protocol deviceClassDelegate <NSObject>
@optional
-(void) didDeviceStatusFinish:(DeviceClass*) _device;

@end

@interface DeviceClass : NSObject<NSCopying,deviceConnectorDelegate,StaticHttpRequestDelegate>

@property (nonatomic,retain) deviceConnector *m_connector;
@property (nonatomic) connectorState m_currentState;
@property (nonatomic) prefType m_prefType;
@property (nonatomic) NSInteger m_deviceId;
@property (nonatomic) MultiPort m_httpPort;
@property (nonatomic) NSInteger m_streamNO;
@property (nonatomic) BOOL m_blnSelected;
@property (nonatomic) NSInteger m_blnOnLine;
@property (nonatomic) NSInteger m_ipratio;

@property (nonatomic,retain) NSString *m_deviceName;
@property (nonatomic,retain) NSString *m_deviceAddress;// ip or url
@property (nonatomic,retain) NSString *m_userName;
@property (nonatomic,retain) NSString *m_password;
@property (nonatomic,retain) NSString *m_strStreamInfo;
@property (nonatomic,retain) NSString *m_strMAC;

@property (nonatomic,retain) id<deviceClassDelegate> delegate;
@property (nonatomic,retain) NSString* m_httpCMDAddress;
@property (nonatomic) MultiPort m_httpCMDPort;

//for playback & setting because these two function need administrator privilege
- (id)initWithDelegate:(id<deviceClassDelegate>) _delegate;
- (void)stopConnectionAction;
- (float)getWideDegreeValue;
- (id)copyWithZone:(NSZone *)zone;

@end
