//
//  DataDefine.h
//  IRIPCamera
//
//  Created by Phil on 2019/11/1.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "StaticLanguage.h"

#ifndef DataDefine_h
#define DataDefine_h

#define GET_STREAM_SETTINGS     @"GetVideoStreamSettings"
#define GET_AUDIOOUT_INFO       @"GetTwowayAudioInfo"

#define GET_FISHEYE_CENTER_TAG              @"GetFishEyeCenterResult"
#define SETTING_LANGUALE_KEY                @"SettingLanguages"

#define ENABLE_RTSP_URL_KEY                 @"EnableRTSPURL"
#define RTSP_URL_KEY                        @"RTSPURL"

//Language Key
#define LANGUAGE_ENGLISH_SHORT_ID              @"en"
#define LANGUAGE_CHINESE_TRADITIONAL_SHORT_ID  @"zh-Hant"
#define LANGUAGE_CHINESE_SIMPLIFIED_SHORT_ID   @"zh-Hans"

//Get multi language string
#define _(str)  [[StaticLanguage sharedInstance] stringFor:str]

#define MAX_RETRY_TIMES 3

#define HTTPS_APP_COMMAND_PORT 9091
#define HTTP_APP_COMMAND_PORT  9090
#define VIDEO_PORT             554
#define AUDIO_PORT             2000
#define NORMAL_PORT            8080
#define DOWNLOAD_PORT          9000

#endif /* DataDefine_h */
