//
//  errorCodeDefine.h
//  test1
//
//  Created by sniApp on 12/9/13.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#ifndef test1_errorCodeDefine_h
#define test1_errorCodeDefine_h

#define INIT_RTSPCLIENT_SESSION_FAIL    0XF00001
#define SETUP_RTSPCLIENT_SESSION_FAIL   0XF00002
#define GET_RTSPCLIENT_SESSION_FAIL     0XF00003

#define FIND_VIDEOCOCED_BYSTRING_FAIL   0XF10001
#define FIND_VIDEO_CODEC_FAIL           0XF10002
#define ALLOC_VIDEO_AVCONTEXT_FAIL      0XF10003
#define OPEN_VIDEO_AVCODEC_FAIL         0XF10004

#define FIND_AUDIOCODEC_BYSTRING_FAIL   0XF20001
#define FIND_AUDIO_CODEC_FAIL           0XF20002
#define ALLOC_AUDIO_AVCONTEXT_FAIL      0XF20003
#define OPEN_AUDIO_AVCODEC_FAIL         0XF20004
#define SWR_INIT_FAIL                   0XF20005

#endif