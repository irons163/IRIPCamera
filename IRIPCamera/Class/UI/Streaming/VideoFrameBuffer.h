//
//  VideoFrameBuffer.h
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoFrame.h"
#import <AVFoundation/AVSynchronizedLayer.h>

@interface VideoFrameBuffer : NSObject {
    NSMutableArray *m_aryFrameBuffer;
    NSMutableArray *m_aryDecodeBuffer;
    NSMutableArray *m_aryFreeBuffer;
    NSInteger m_Channel;
}

@property (nonatomic, retain) NSMutableArray *m_aryFrameBuffer;
@property (nonatomic) NSInteger m_Channel;

- (id)initWithGop:(NSInteger)iGOPCount;
- (void)addFrameIntoBuffer:(FrameBaseClass *)videoFrame;
- (FrameBaseClass *)getOneFrame;
- (void)clearBuffer;
- (void)close;

@end
