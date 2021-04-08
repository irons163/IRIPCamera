//
//  VideoDecoder.h
//  test1
//
//  Created by sniApp on 12/9/14.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VideoFrameBuffer.h"
#import <IRPlayer/IRPlayer.h>
#import <IRPlayer/IRFFTools.h>

@protocol VideoDecoderDelegate

- (void)videoChangeWidth:(NSInteger) _width height:(NSInteger) _height;

@end

@interface VideoDecoder : NSObject {
    VideoFrameBuffer *m_FrameBuffer;
    BOOL m_blnDecoding;
    IRFFVideoInput *showView;
    UIInterfaceOrientation m_currentOrientation;
    BOOL m_blnChangeOrientation;
    AVCodecContext *m_decodeContext;
    
    NSInteger m_channel;
    
    NSFileHandle *myHandle;
    
    CGFloat m_ImageWidth;
    CGFloat m_ImageHeight;
    
    UIImage *m_imgShow;
    UIImage *snapImage;
    
    NSData *DisplayJPEG;
    
    BOOL m_blnShowImage;
    BOOL m_blnStopDecodeing;
    __unsafe_unretained id<VideoDecoderDelegate> delegate;
}

@property (nonatomic ,retain) VideoFrameBuffer *m_FrameBuffer;
@property (nonatomic) BOOL m_blnDecoding;
@property (nonatomic ,retain) IRFFVideoInput *showView;
@property (nonatomic) UIInterfaceOrientation m_currentOrientation;
@property (nonatomic) BOOL m_blnChangeOrientation;
@property (nonatomic) BOOL m_blnShowImage;
@property (nonatomic) BOOL m_blnStopDecodeing;
@property (nonatomic) NSInteger m_channel;
@property (strong, atomic) ALAssetsLibrary* library;
@property (nonatomic) BOOL m_blnRanderFinish;
@property (nonatomic) BOOL m_blnDecodeFinish;
@property (nonatomic) CGFloat m_ImageWidth;
@property (nonatomic) CGFloat m_ImageHeight;
@property (assign) id <VideoDecoderDelegate> delegate;

- (id)initDecoder;
- (id)initDecoderWithUIImageView:(IRFFVideoInput *)imageView;
- (void)setDisplayUIView:(IRFFVideoInput *)imageView;
- (NSUInteger)setCodecWithCodecString:(NSString*) strCodec;
- (void)startDecode;
- (void)stopDecode;
- (void)setExtraData:(NSInteger)_iLen extraData:(uint8_t *)_extradata;
- (void)setChannel:(NSInteger)_ch;
- (void)setShowImageOrNot:(BOOL)_blnShow;

// For VideoToolBox(NV12)
- (void)setSPSFrame:(FrameBaseClass *)sps_frame;
- (void)setPPSFrame:(FrameBaseClass *)pps_frame;
- (void)iOS8HWDecode:(AVCodecContext *)pCodecCtx packet:(AVPacket)packet;

@end
