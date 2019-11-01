//
//  DeviceClass.m
//  IRIPCamera
//
//  Created by sniApp on 12/10/23.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "DeviceClass.h"
#import "AppDelegate.h"

@implementation DeviceClass

- (void) didfinishLoginActionByResultType:(NSInteger) _resultCode deviceInfo:(NSDictionary *) _deviceInfo errorDesc :(NSString *) _strErrorDesc address:(NSString *) _strAddress port:(MultiPort) _commandPort
{
    NSLog(@"%@:%zd ,result=%d ,error Desc = %@",_strAddress ,_commandPort.httpPort, (int)_resultCode, _strErrorDesc);
    
    [self.delegate didDeviceStatusFinish:self];
}

- (id) init
{
    self = [super init];
    
    if (self) {
        self.m_deviceAddress  =[NSString stringWithFormat:@""];
        self.m_deviceName  =[NSString stringWithFormat:@""];
        
        self.m_password  =[NSString stringWithFormat:@""];
        self.m_userName  =[NSString stringWithFormat:@""];
        
        self.m_deviceAddress  =[NSString stringWithFormat:@""];
        self.m_strStreamInfo  =[NSString stringWithFormat:@""];
        self.m_strMAC  =[NSString stringWithFormat:@""];

        
        self.m_deviceId  = 0;
        self.m_streamNO  = -1;
      
        self.m_httpPort  = MultiPortInitial();
        
        self.m_httpCMDAddress = [NSString stringWithFormat:@""];
        
        self.m_httpCMDPort = MultiPortInitial();//https command port default 9091
        
        
        self.m_blnSelected = NO;
        self.m_blnOnLine = 0;
        self.m_prefType = UNKNOWN_TYPE;
        self.m_ipratio = 60;
    }
    
    return  self;
}

-(id) initWithDelegate:(id<deviceClassDelegate>)_delegate
{
    self.delegate = _delegate;
    
    return [self init];
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        
        [copy setM_deviceId:self.m_deviceId];
        [copy setM_httpPort:self.m_httpPort];
        [copy setM_httpCMDPort:self.m_httpCMDPort];
        [copy setM_streamNO:self.m_streamNO];
  
        
        [copy setM_deviceName:[self.m_deviceName copyWithZone:zone]];
        [copy setM_deviceAddress:[self.m_deviceAddress copyWithZone:zone]];
        [copy setM_userName:[self.m_userName copyWithZone:zone]];
        [copy setM_password:[self.m_password copyWithZone:zone]];
   
        [copy setM_strStreamInfo:[self.m_strStreamInfo copyWithZone:zone]];
        [copy setM_strMAC:[self.m_strMAC copyWithZone:zone]];

        
        [copy setM_blnSelected:self.m_blnSelected];
        [copy setM_blnOnLine:self.m_blnOnLine];
        [copy setM_prefType:self.m_prefType];
      
        
        [copy setM_httpCMDAddress:[self.m_httpCMDAddress copyWithZone:zone]];
       
    }
    
    return copy;
}

-(void) dealloc
{
//    [self.m_http release];
}

-(void) stopConnectionAction
{
    [self.m_connector stopConnectionAction];
    [self.m_connector setDelegate:nil];
    self.m_connector = nil;
}

- (float)getWideDegreeValue{
    return 0;
}

#pragma mark StaticHttpRequestDelegate

- (void)didFinishStaticRequestJSON:(NSDictionary *)_strAckResult callbackID:(NSUInteger)_callback
{
    [self.delegate didDeviceStatusFinish:self];
}

- (void)failToStaticRequestWithErrorCode:(NSInteger)_iFailStatus description:(NSString *)_desc callbackID:(NSUInteger)_callback
{
    self.m_blnOnLine = NO;
    [self.delegate didDeviceStatusFinish:self];
}

@end
