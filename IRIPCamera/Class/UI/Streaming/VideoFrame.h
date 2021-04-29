//
//  VideoFrame.h
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "FrameBaseClass.h"

@interface VideoFrame : FrameBaseClass {
    NSInteger  m_intVideoFrameType;
    NSInteger  m_intCodecType;
    NSInteger  m_intFrameSEQ;
    
    CGFloat m_uintVideoTimeUSec;
    CGFloat m_uintVideoTimeSec;
    NSInteger m_channel;
}

@property NSInteger m_intVideoFrameType;
@property NSInteger m_intCodecType;
@property NSInteger m_intFrameSEQ;

@property CGFloat m_uintVideoTimeUSec;
@property CGFloat m_uintVideoTimeSec;

@end
