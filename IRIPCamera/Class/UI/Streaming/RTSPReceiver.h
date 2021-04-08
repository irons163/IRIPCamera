//
//  RTSPReceiver.h
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "Receiver.h"
#import "RTSPClientSession.h"
#import "errorCodeDefine.h"
@class FrameBaseClass;

@interface RTSPReceiver : Receiver <RTSPClientSessionDelegate> {
    RTSPClientSession *m_RTSPClient;
    FrameBaseClass  *m_SPSFrame;
    FrameBaseClass  *m_PPSFrame;
    
    BOOL m_blnProcessData;
    NSString *m_strURL;
    NSInteger pCount;
    char exit;
    
    unsigned int i_VideoExtra;
    uint8_t *p_VideoExtra;
    unsigned int i_AudioExtra;
    uint8_t *p_AudioExtra;
    
    NSString *m_sessionid;
    NSInteger m_clientPort;
    double m_LastReceivetime;
    
    uint64_t m_preSeconds;
    uint64_t m_processSec;
}

-(void) startHandleStream;

@end
