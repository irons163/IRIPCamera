//
//  dataDefine.h
//  IRIPCamera
//
//  Created by sniApp on 12/10/23.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//

#import "StaticLanguage.h"

#ifndef dataDefine_h
#define dataDefine_h

#define DEVICE_LIST @"device_list"
#define VIEW_LIST   @"view_list"
#define VIEW_DETAIL @"view_detail"

#define CREATE_DEVICE_LIST @"(device_id INTEGER PRIMARY KEY AUTOINCREMENT ,device_name text ,device_address text ,user_name text ,password text ,http_port int,streamNo int ,create_date numberic ,router_id int ,mac_addr text, model_name text, device_uid text, scheme text, new_http_port int);"

#define CREATE_VIEW_LIST    @"(view_id INTEGER PRIMARY KEY AUTOINCREMENT,view_name text ,create_date numberic);"
#define CREATE_VIEW_DETAIL  @"(view_detail_id INTEGER PRIMARY KEY ,view_id int ,device_id int);"

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
#define STATUS_BAR_HEIGHT 20.0
#define NAVI_BAR_HEGHT 44.0
#define REFRESH_DISTANCE 30

#define HTTPS_APP_COMMAND_PORT 9091
#define HTTP_APP_COMMAND_PORT  9090
#define VIDEO_PORT             554
#define AUDIO_PORT             2000
#define NORMAL_PORT            8080
#define DOWNLOAD_PORT          9000

#endif
