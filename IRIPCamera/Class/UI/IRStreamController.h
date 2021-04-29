//
//  IRStreamController.h
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <IRPlayer/IRPlayer.h>
#import "RTSPReceiver.h"
#import "StaticHttpRequest.h"
#import "deviceConnector.h"
#import "DeviceClass.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, IRStreamControllerStatus) {
    IRStreamControllerStatus_None,
    IRStreamControllerStatus_PreparingToPlay,
    IRStreamControllerStatus_ReadyToPlay,
    IRStreamControllerStatus_PlayToEnd,
    IRStreamControllerStatus_Failed,
};

@protocol IRStreamControllerDelegate <NSObject>

- (void)connectReslt:(id)_videoView Connection:(BOOL)connection MicSupport:(BOOL)_micSupport SpeakerSupport:(BOOL)_speakerSupport;
- (void)recordingFailedWithErrorCode:(NSInteger)_code desc:(NSString *)_desc;
- (void)finishRecordingWithShowLoadingIcon:(BOOL)_blnShow;
- (void)showErrorMessage:(NSString*)msg;
- (void)streamControllerStatusChanged:(IRStreamControllerStatus)status;
#ifdef DEV
- (BOOL)checkIsAutoLiveOn;
#endif
@optional
- (void)updatedVideoModes;

@end

@interface IRStreamController : NSObject {
    StaticHttpRequest *m_httpRequest;
    NSInteger m_Channel;
    
    NSMutableArray *m_aryRtspURL;
    NSMutableArray *m_aryStreamInfo;
    NSMutableArray *m_aryIPRatio;
    NSInteger m_AvailableStrems;
    NSInteger m_DeviceStreamMode;
    NSInteger m_ReconnectTimes;
    BOOL m_blnStopStreaming;
    BOOL m_blnUseTCP;
    BOOL m_blnSelected;
    BOOL m_blnStopforever;
    BOOL m_blnShowAuthorityAlert;
    
    NSString *m_currentURL;
    NSInteger m_currentIPRatio;
    DeviceClass *m_deviceInfo;
    
    NSString* m_Token;
    
    NSString* m_errorMsg;
    
    NSArray *modes;
    
    IRMediaParameter* parameter;
    UIImageView *imageView;
    CALayer* borderLayer;
    
    dispatch_queue_t streamingQueue;
    RTSPReceiver *m_RTSPStreamer;
}

@property (weak) id AudioDelegate;
@property (weak) id<IRStreamControllerDelegate> eventDelegate;
@property (weak) IRPlayerImp *m_videoView;

- (instancetype)initWithRtspUrl:(NSString *)rtspURL;
- (instancetype)initWithDevice:(DeviceClass *)device;
- (void)startStreamConnection;
- (NSInteger)stopStreaming:(BOOL)_blnStopForever;
- (void)changeStream:(NSInteger)_stream;

@end


NS_ASSUME_NONNULL_END
