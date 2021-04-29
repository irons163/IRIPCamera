//
//  VideoFrameBuffer.m
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "VideoFrameBuffer.h"
#import <pthread.h>

@interface VideoFrameBuffer (private)

- (BOOL)checkIframeInBuffer;

@end

@implementation VideoFrameBuffer {
    pthread_mutex_t mtx;
    pthread_cond_t cond;
}

@synthesize  m_aryFrameBuffer;
@synthesize m_Channel;

- (void)dealloc {
    m_aryFrameBuffer = nil;
    pthread_mutex_destroy(&mtx);
    pthread_cond_destroy(&cond);
}

- (void)close {
    m_aryFrameBuffer = nil;
    pthread_mutex_lock(&mtx);
    pthread_cond_broadcast(&cond);
    pthread_mutex_unlock(&mtx);
}

- (id)initWithGop:(NSInteger)iGOPCount {
    self.m_aryFrameBuffer = [[NSMutableArray alloc] initWithCapacity:iGOPCount];
    pthread_mutex_init(&mtx, NULL);
    pthread_cond_init(&cond, NULL);
    
    return self;
}

- (void)addFrameIntoBuffer:(FrameBaseClass *)videoFrame {
    pthread_mutex_lock(&mtx);
    
    if ((videoFrame.m_intFrameType == VIDEO_I_FRAME && [m_aryFrameBuffer count] > 0 ) || [m_aryDecodeBuffer count] >30) {
        [self clearBuffer];
    }
    
    [m_aryFrameBuffer insertObject:videoFrame atIndex:0 ];
    videoFrame = nil;
    
    pthread_cond_signal(&cond);
    pthread_mutex_unlock(&mtx);
}

- (FrameBaseClass *)getOneFrame {
    VideoFrame *rtnFrame = nil;
    
    pthread_mutex_lock(&mtx);
    
    do {
        if ([self.m_aryFrameBuffer count] > 0) {
            rtnFrame = (VideoFrame*)[self.m_aryFrameBuffer lastObject];
            [self.m_aryFrameBuffer removeLastObject];
            pthread_mutex_unlock(&mtx);
            return rtnFrame;
        }
        
        if (!rtnFrame) {
            pthread_cond_wait(&cond, &mtx);
        }
    } while (m_aryFrameBuffer);
    
    pthread_mutex_unlock(&mtx);
    
    return rtnFrame;
}

- (void)clearBuffer {
    [m_aryFrameBuffer removeAllObjects];
    m_aryFrameBuffer = nil;
    m_aryFrameBuffer = [[NSMutableArray alloc] init];
}

@end


@implementation VideoFrameBuffer(private)

- (BOOL)checkIframeInBuffer {
    BOOL blnRtn = NO;
    
    for (VideoFrame *tmpFrame in self.m_aryFrameBuffer) {
        if(tmpFrame.m_intFrameType == VIDEO_I_FRAME) {
            blnRtn = YES;
            break;
        }
    }
    return blnRtn;
}

@end
