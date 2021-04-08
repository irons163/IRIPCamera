//
//  FrameBaseClass.m
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "FrameBaseClass.h"

@implementation FrameBaseClass
@synthesize m_blnAvailable ,m_intFrameType ,m_pRawData ,m_uintFrameLenth;

- (void)dealloc {
    if (m_pRawData != NULL) {
        @try {
            free(m_pRawData);
            m_intFrameType = 0;
            m_uintFrameLength = 0;
            m_blnAvailable = NO;
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.debugDescription);
        }
        @finally {
            
        }
    }
}

@end
