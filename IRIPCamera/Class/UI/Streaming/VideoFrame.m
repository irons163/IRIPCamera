//
//  VideoFrame.m
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "VideoFrame.h"

@implementation VideoFrame

@synthesize m_intCodecType ,m_intFrameSEQ ,m_intVideoFrameType ,m_uintVideoTimeSec ,m_uintVideoTimeUSec;

- (void)dealloc {
    m_blnAvailable = NO;
    m_intFrameSEQ = 0;
    m_intVideoFrameType = 0;
    m_uintVideoTimeSec = 0;
    m_uintVideoTimeUSec = 0;
}

@end
