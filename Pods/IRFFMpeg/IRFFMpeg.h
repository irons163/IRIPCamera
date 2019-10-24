//
//  IRFFMpeg.h
//  IRPlayer
//
//  Created by Phil on 2019/10/3.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double IRFFMpegVersionNumber;
FOUNDATION_EXPORT const unsigned char IRFFMpegVersionString[];

#import "libavformat/avformat.h"
#import "libswscale/swscale.h"
#import "libavcodec/avcodec.h"
#import "libavutil/avutil.h"
#import "libswresample/swresample.h"
#import "libavfilter/avfilter.h"
#import "libavdevice/avdevice.h"
