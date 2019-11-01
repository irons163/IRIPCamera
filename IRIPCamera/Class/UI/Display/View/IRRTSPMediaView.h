//
//  IRRTSPMediaView.h
//  IRIPCamera
//
//  Created by Phil on 2019/10/28.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IRPlayer/IRPlayer.h>
#import "IRStreamController.h"
#import "IRStreamConnectionRequest.h"

NS_ASSUME_NONNULL_BEGIN

@import CoreMotion;

@class DeviceClass;

@interface IRRTSPMediaView : UIView<IRStreamControllerDelegate>
{
    UIImageView *imageView;
    BOOL m_blnStopStreaming;

}
@property (weak, nonatomic) IBOutlet UIView *m_titleBackground;
@property (weak, nonatomic) IBOutlet UILabel *m_lblTitle;
@property (weak, nonatomic) IBOutlet UIView *m_relayTimerBackground;
@property (weak, nonatomic) IBOutlet UILabel *m_RelayTimerTitle;
@property (weak, nonatomic) IBOutlet UIView *m_videoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *m_LoadingActivity;
@property (weak, nonatomic) IBOutlet UILabel *m_InfoLabel;
//@property (weak, nonatomic) StreamController *streamController;
@property (weak, nonatomic) IRPlayerImp *m_player;
@property (nonatomic) double tagTime;
@property (nonatomic) BOOL doubleTapEnable;

-(void) startStreamConnectionWithRequest:(IRStreamConnectionRequest*)request;
-(NSInteger) stopStreaming:(BOOL)_blnStopForever;
@end

NS_ASSUME_NONNULL_END
