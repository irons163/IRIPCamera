//
//  FrameBaseClass.h
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define VIDEO_FRAME     0X000001
#define AUDIO_FRAME     0X000002
#define SPS_FRAME       0X000003
#define PPS_FRAME       0X000004
#define VIDEO_I_FRAME   0X100001
#define VIDEO_P_FRAME   0X100002

@interface FrameBaseClass : NSObject {
    NSUInteger  m_uintFrameLength;
    NSInteger   m_intFrameType;
    uint8_t     *m_pRawData;
    BOOL        m_blnAvailable;
}

@property NSUInteger    m_uintFrameLenth;
@property NSInteger     m_intFrameType;
@property uint8_t       *m_pRawData;
@property BOOL          m_blnAvailable;

@end
