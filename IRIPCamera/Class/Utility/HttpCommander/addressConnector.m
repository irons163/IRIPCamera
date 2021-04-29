//
//  addressConnector.m
//  PJTunnel
//
//  Created by Robert on 2014/5/12.
//  Copyright (c) 2014年 Daniel. All rights reserved.
//

#import "addressConnector.h"
#import "AppDelegate.h"

@interface LocalIPInfoClass : NSObject

@property (nonatomic, strong) NSString *currentInterfaceIP;
@property (nonatomic, strong) NSString *wifiIP;
@property (nonatomic, strong) NSString* cellularIP;

@end

@implementation LocalIPInfoClass

@synthesize currentInterfaceIP;
@synthesize wifiIP;
@synthesize cellularIP;

@end

@interface addressConnector(Private)
-(void) loginToDevice;
-(void) getRTSPInfoWithToken:(NSString *) _strToken;
-(void) getTwoWayAudioInfoWithToken:(NSString *)_strToken;
@end

@implementation addressConnector

-(void) startLoginToDeviceWithGetStringInfo:(BOOL) _blnGetStreamInfo  IgnoreLoginCache:(BOOL)_blnIgnoreLoginCache
{
    [super startLoginToDeviceWithGetStringInfo:_blnGetStreamInfo IgnoreLoginCache:_blnIgnoreLoginCache];
    
    [NSThread detachNewThreadSelector:@selector(loginToDevice) toTarget:self withObject:nil];
}


- (void)getTwoWayAudioInfo {
    
}

-(void) getVideoStreamURLByChannel:(NSInteger)_channel
{
    NSDictionary *tmpList = [self.m_VideoStreamInfo valueForKey:@"StreamSettings"];
    NSArray *Streams = [tmpList valueForKey:@"StreamSetting"];
    NSInteger iChannel = 0;
    NSInteger iRtn = -1;
    
    if(_channel >= [Streams count])
        _channel = [Streams count] - 1;
    else if(_channel < 0)
        _channel = 0;
    
    for (NSInteger i = 0 ;  i < [Streams count]; i++)
    {
        NSDictionary *tmpStreamInfo = [Streams objectAtIndex:i];
        
        if(![[tmpStreamInfo objectForKey:@"Enable"] boolValue])
        {
            continue;
        }
        
        if(iChannel == _channel)
        {
            NSString *strRTSP = [tmpStreamInfo objectForKey:@"URL"];
            NSURLComponents * components = [NSURLComponents componentsWithString:strRTSP];
            
            components.host = self.m_strAddress;
            components.port = [NSNumber numberWithInteger:self.m_CommandPort.videoPort];
            NSURL* strRTSPURL = [components URL];
            [self.delegage didGetRtspURLByChannel:0 msg:nil ch:_channel url:[strRTSPURL absoluteString] ipRatio:[[tmpStreamInfo objectForKey:@"FPS"] integerValue]];
            
            iRtn = 0;
            break;
        }
        else
            iChannel ++;
    }
    
}

- (NSURL*)getRedirectURL:(NSURL*)url{
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:requestObj returningResponse:&response error:nil];
    return [response URL];
}

#pragma mark StaticHttpRequestDelegate

- (void)failToStaticRequestWithErrorCode:(NSInteger)_iFailStatus description:(NSString *)_desc callbackID:(NSUInteger)_callback
{
    NSLog(@"AddressConnector failToStaticRequestWithErrorCode callback %d",(int)_callback);
    if(self.m_blnStopConnection){
        NSLog(@"blnStopConnection Return");
        return;
    }
    
    self.m_RetryTime++;
    switch (_callback) {
        case DoDeviceLogin:
            if(self.m_RetryTime <= 3)
            {
                NSLog(@"RetryTime %d",(int)self.m_RetryTime);
                [NSThread detachNewThreadSelector:@selector(loginToDevice) toTarget:self withObject:nil];
            }
            else
            {
                if(!self.m_blnStopConnection)
                    [self.delegage didLoginResult:-1 msg:@"connect failed " caller:self info:nil address:self.m_strAddress port:self.m_CommandPort];
            }
            break;
        case GetVideoInfo:
            if(self.m_RetryTime <= 3)
            {
                [self getRTSPInfoWithToken:self.m_strToken];
            }
            else
            {
                [self.delegage didGetRTSPResponse:-2 msg:@"Get Rtsp Stream Info failed"];
            }
            break;
        case GetTwoWayAudioInfo:
            if(self.m_RetryTime <= 3)
            {
                [self getTwoWayAudioInfoWithToken:self.m_strToken];
            }
            else
            {
                [self.delegage didGetTwoWayAudioResult:-1 url:nil type:nil sampleRate:0 bps:0];
            }
            break;
        default:
            break;
    }
}

- (void)didFinishStaticRequestJSON:(NSDictionary *)_strAckResult callbackID:(NSUInteger)_callback
{
    NSLog(@"AddressConnector didFinishStaticRequestJSON callback %d",(int)_callback);
    if(self.m_blnStopConnection){
        NSLog(@"blnStopConnection Return");
        return;
    }
}

-(void) checkDeviceOnline
{
    [self startLoginToDeviceWithGetStringInfo:NO IgnoreLoginCache:YES];
}
@end

@implementation addressConnector(Private)

- (void)loginToDevice {
    if(self.m_blnStopConnection)
    {
        [self cancelLoginToDevice];
        return;
    }
}

-(void) getRTSPInfoWithToken:(NSString *)_strToken
{
    if(self.m_blnStopConnection)
    {
        [self cancelLoginToDevice];
        return;
    }
    
    NSInteger tmpPort = self.m_CommandPort.httpsPort;
    
    if ([self.m_scheme isEqualToString:@"http"]) {
        tmpPort = self.m_CommandPort.httpPort;
    }
    
    NSString *strCmd = [NSString stringWithFormat:GET_STREAM_SETTINGS
                        ,self.m_scheme
                        ,self.m_strAddress
                        ,(int)tmpPort
                        ];
    
    self.m_ASIHTTPSender = [StaticHttpRequest sharedInstance];
    [self.m_ASIHTTPSender doJsonRequestWithToken:self.m_strToken
                                    externalLink:[self getLocalIPInfo].currentInterfaceIP
                                             Url:strCmd
                                          method:@"GET"
                                        postData:nil
                                      callbackID:GetVideoInfo
                                          target:self];
}

- (void)getTwoWayAudioInfoWithToken:(NSString *)_strToken
{
    if(self.m_blnStopConnection)
    {
        [self cancelLoginToDevice];
        return;
    }
    
    NSInteger tmpPort = self.m_CommandPort.httpsPort;
    
    if ([self.m_scheme isEqualToString:@"http"]) {
        tmpPort = self.m_CommandPort.httpPort;
    }
    
    NSString *strCmd = [NSString stringWithFormat:GET_AUDIOOUT_INFO
                        ,self.m_scheme
                        ,self.m_strAddress
                        ,(int)tmpPort
                        ];
    
    self.m_ASIHTTPSender = [StaticHttpRequest sharedInstance];
    [self.m_ASIHTTPSender doJsonRequestWithToken:self.m_strToken
                                    externalLink:[self getLocalIPInfo].currentInterfaceIP
                                             Url:strCmd
                                          method:@"GET"
                                        postData:nil
                                      callbackID:GetTwoWayAudioInfo
                                          target:self];
    
}

- (LocalIPInfoClass*)getLocalIPInfo{
    NSString* wifiAddress = nil;
    NSString* cellAddress = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    wifiAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
                    cellAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    LocalIPInfoClass* localIPInfo = [LocalIPInfoClass new];
    localIPInfo.wifiIP = wifiAddress;
    localIPInfo.cellularIP = cellAddress;
    if (wifiAddress) {
        localIPInfo.currentInterfaceIP = wifiAddress;
        return localIPInfo;
    }
    
    localIPInfo.currentInterfaceIP = cellAddress;
    return localIPInfo;
}

@end
