//
//  deviceConnector.m
//  PJTunnel
//
//  Created by Robert on 2014/5/12.
//  Copyright (c) 2014年 Daniel. All rights reserved.
//

#import "HttpAPICommander.h"

@interface HttpAPICommander(Private)

- (void)setUserName:(NSString *)_strUserName pwd:(NSString *)_password port:(MultiPort)_port scheme:(NSString *)_scheme;

@end

@implementation HttpAPICommander
@synthesize m_CommandPort, m_strUID, m_blnStopConnection, m_strAddress, m_strPassword, m_strUserName, delegage, m_blnGetRTSPInfo, m_blnGetAudioInfo, m_blnIgnoreLoginCache;
@synthesize m_audioInfo, m_loginInfo, m_VideoStreamInfo, m_RetryTime;
@synthesize tag, m_ASIHTTPSender, m_strToken ,m_strPrivilige,m_scheme;
@synthesize m_blnStopCommandTunnel;
@synthesize m_CurrentErrorType;
@synthesize m_blnIsAPPAndDUTUnderTheSameLAN;
@synthesize m_deviceType;

- (id)initWithAddress:(NSString *)_strIP port:(MultiPort)_port user:(NSString *)_user pwd:(NSString *)_pwd scheme:(NSString *)_scheme {
    self = [super init];
    
    if (self) {
        m_CommandPort = MultiPortInitial();
        
        self.m_strAddress = [[NSString alloc] initWithFormat:@"%@", _strIP];
        
        [self setUserName:_user pwd:_pwd port:_port scheme:_scheme];
        self.m_blnStopCommandTunnel = NO;
    }
    
    return self;
}

- (void)updateUserName:(NSString*)_strUserName pwd:(NSString*)_strPwd {
    [self setUserName:_strUserName pwd:_strPwd port:self.m_CommandPort scheme:self.m_scheme];
}

- (void) startLoginToDeviceWithGetStringInfo:(BOOL)_blnGetStreamInfo IgnoreLoginCache:(BOOL)_blnIgnoreLoginCache {
    self.m_blnGetRTSPInfo = _blnGetStreamInfo;
    self.m_blnIgnoreLoginCache = _blnIgnoreLoginCache;
}

- (void)cancelLoginToDevice {
    self.m_blnStopConnection = YES;
    
    NSLog(@"cancel type=%d", (int)self.tag);
    if (self.m_ASIHTTPSender) {
        //        [self.m_ASIHTTPSender setDelegate:nil];
        //        [self.m_ASIHTTPSender cancel];
    }
    
}

- (void)getVideoStreamURLByChannel:(NSInteger)_channel {
    
}

- (NSInteger)getStreamsCodecInfo:(NSMutableArray *__strong*)_aryStreamCodecInfo {
    NSInteger iRtn = -1;
    
    if(*_aryStreamCodecInfo)
        *_aryStreamCodecInfo = nil;
    
    *_aryStreamCodecInfo = [[NSMutableArray alloc] init];
    
    if(self.m_VideoStreamInfo) {
        NSDictionary *tmpList = [self.m_VideoStreamInfo valueForKey:@"StreamSettings"];
        NSArray *Streams = [tmpList valueForKey:@"StreamSetting"];
        
        for (int i = 0; i < [Streams count]; i++) {
            NSDictionary *stream = [Streams objectAtIndex:i];
            if(stream)
            {
                if([stream objectForKey:@"Enable"])
                {
                    if(![stream objectForKey:@"Enable"])
                        continue;
                }
                
                NSString *strInfo = [NSString stringWithFormat:@"%@(%@)",[stream objectForKey:@"Codec"], [stream objectForKey:@"Resolution"]];
                NSLog(@"%@",[stream objectForKey:@"URL"]);
                
                [*_aryStreamCodecInfo addObject:strInfo];
            }
        }
        
        iRtn = 0;
    }
    
    return iRtn;
}

- (void)getTwoWayAudioInfo {
    
}

- (void)closeTwoWayAudio {
    
}

- (void)setUserName:(NSString *)_strUserName pwd:(NSString *)_password port:(MultiPort)_port scheme:(NSString*)_scheme {
    self.m_CommandPort = _port;
    self.m_strUserName = _strUserName;
    self.m_strPassword = _password;
    self.m_scheme = _scheme;
}

- (void)checkDeviceOnline {
    
}

@end

