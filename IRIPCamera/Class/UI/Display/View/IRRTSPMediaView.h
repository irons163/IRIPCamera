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

@interface IRRTSPMediaView : UIView <IRStreamControllerDelegate> {
    UIImageView *imageView;
    BOOL m_blnStopStreaming;
}

@property (weak, nonatomic) IBOutlet UIView *titleBackground;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IRPlayerImp *player;
@property (nonatomic) BOOL doubleTapEnable;

- (void)startStreamConnectionWithRequest:(IRStreamConnectionRequest *)request;
- (NSInteger)stopStreaming:(BOOL)stopForever;

@end

NS_ASSUME_NONNULL_END
