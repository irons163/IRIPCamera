//
//  IRRTSPPlayer.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRRTSPPlayer.h"
#import <OpenGLES/gltypes.h>
#import <UIKit/UIKit.h>
#import "NSLayoutConstraint+Multiplier.h"
#import "IRRTSPSettingsViewController.h"
#import "IRStreamConnectionRequestFactory.h"

@interface IRRTSPPlayer () <IRRTSPSettingsViewControllerDelegate>

@property (nonatomic, strong) IRPlayerImp *player;
@property (nonatomic, strong) IRPlayerImp *player2;
@property (nonatomic, strong) IRPlayerImp *player3;
@property (nonatomic, strong) IRPlayerImp *player4;

@end

@implementation IRRTSPPlayer {
    UIImageView *imageView;
    NSMutableArray *m_aryStreamInfo;
    NSMutableArray *m_aryDevices;
}

@synthesize m_LoadingActivity;

- (void)dealloc {
    [self stopAllStreams:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_aryDevices = [NSMutableArray arrayWithArray:[IRStreamConnectionRequestFactory createStreamConnectionRequest]];
    m_intDisplayMode = 1;
    m_intCurrentCh = 0;
    
    self.player = [IRPlayerImp player];
    [self.player registerPlayerNotificationTarget:self
                                      stateAction:@selector(stateAction:)
                                   progressAction:@selector(progressAction:)
                                   playableAction:@selector(playableAction:)
                                      errorAction:@selector(errorAction:)];
    [self.player setViewTapAction:^(IRPlayerImp * _Nonnull player, IRPLFView * _Nonnull view) {
        NSLog(@"player display view did click!");
    }];
    self.player.decoder = [IRPlayerDecoder FFmpegDecoder];
    IRFFVideoInput *input = [[IRFFVideoInput alloc] init];
    [self.player replaceVideoWithInput:input videoType:IRVideoTypeNormal];
    
    self.player2 = [IRPlayerImp player];
    [self.player2 registerPlayerNotificationTarget:self
                                       stateAction:@selector(stateAction:)
                                    progressAction:@selector(progressAction:)
                                    playableAction:@selector(playableAction:)
                                       errorAction:@selector(errorAction:)];
    [self.player2 setViewTapAction:^(IRPlayerImp * _Nonnull player, IRPLFView * _Nonnull view) {
        NSLog(@"player display view did click!");
    }];
    self.player2.decoder = [IRPlayerDecoder FFmpegDecoder];
    IRFFVideoInput *input2 = [[IRFFVideoInput alloc] init];
    [self.player2 replaceVideoWithInput:input2 videoType:IRVideoTypeNormal];
    
    self.player3 = [IRPlayerImp player];
    [self.player3 registerPlayerNotificationTarget:self
                                       stateAction:@selector(stateAction:)
                                    progressAction:@selector(progressAction:)
                                    playableAction:@selector(playableAction:)
                                       errorAction:@selector(errorAction:)];
    [self.player3 setViewTapAction:^(IRPlayerImp * _Nonnull player, IRPLFView * _Nonnull view) {
        NSLog(@"player display view did click!");
    }];
    self.player3.decoder = [IRPlayerDecoder FFmpegDecoder];
    IRFFVideoInput *input3 = [[IRFFVideoInput alloc] init];
    [self.player3 replaceVideoWithInput:input3 videoType:IRVideoTypeNormal];
    
    self.player4 = [IRPlayerImp player];
    [self.player4 registerPlayerNotificationTarget:self
                                       stateAction:@selector(stateAction:)
                                    progressAction:@selector(progressAction:)
                                    playableAction:@selector(playableAction:)
                                       errorAction:@selector(errorAction:)];
    [self.player4 setViewTapAction:^(IRPlayerImp * _Nonnull player, IRPLFView * _Nonnull view) {
        NSLog(@"player display view did click!");
    }];
    self.player4.decoder = [IRPlayerDecoder FFmpegDecoder];
    IRFFVideoInput *input4 = [[IRFFVideoInput alloc] init];
    [self.player4 replaceVideoWithInput:input4 videoType:IRVideoTypeNormal];
    
    [self initVideoView];
    [self startStreamConnectionByDeviceIndex:0];
}

- (void)startStreamConnectionByDeviceIndex:(NSInteger)_ch {
    if ([m_aryVideoView count] > _ch && [m_aryDevices count] > _ch) {
        UIView *tmpView = [m_aryVideoView objectAtIndex:_ch] ;
        if (tmpView) {
            if ([[tmpView subviews] count] > 0) {
                IRRTSPMediaView *tmpVideo = [[tmpView subviews] objectAtIndex:0];
                if (tmpVideo) {
                    [tmpVideo startStreamConnectionWithRequest:[m_aryDevices objectAtIndex:_ch]];
                }
            }
        }
    }
}

- (void)stopAllStreams:(BOOL)_fromGoBack {
    for (CGFloat i = 0.0f ; i < 4.0f ; i++) {
        [self stopStreamByChannel:i fromgoback:_fromGoBack];
    }
}

- (void)stopStreamByChannel:(NSInteger)_ch fromgoback:(BOOL)_blnFromGoback {
    if ([m_aryVideoView count] > 0) {
        UIView *tmpView = [m_aryVideoView objectAtIndex:_ch] ;
        if (tmpView) {
            if ([[tmpView subviews] count] > 0) {
                IRRTSPMediaView *tmpVideo = [[tmpView subviews] objectAtIndex:0];
                if (tmpVideo) {
                    [tmpVideo stopStreaming:YES];
                    [tmpVideo removeFromSuperview];
                    tmpVideo = nil;
                }
            }
        }
    }
}

- (void)initVideoView {
    [self addVideoViewToBlock];
    
    m_aryVideoView = [[NSMutableArray alloc] initWithCapacity:0];
    [m_aryVideoView addObject:m_firstView];
    [m_aryVideoView addObject:m_secondView];
    [m_aryVideoView addObject:m_thirdView];
    [m_aryVideoView addObject:m_fourthView];
    
    [self setBlockShowOrHide:NO];
    [self resizeViewBlock];
}

- (void)setBlockShowOrHide:(BOOL)_blnFromViewDidLoad {
    for (NSInteger index=0; index < [m_aryVideoView count]; index++) {
        BOOL blnHide = NO;
        
        if(m_intDisplayMode == 1 && index != m_intCurrentCh)
        {
            blnHide = YES;
        }
        
        UIView *tmpView = [m_aryVideoView objectAtIndex:index];
        [tmpView setHidden:blnHide];
    }
}

- (void)addVideoViewToBlock {
    for (NSInteger i = 0 ; i < 4; i++) {
        [self addVideoViewToBlockByCh:i];
    }
}

- (void)addVideoViewToBlockByCh:(NSInteger)_ch {
    if (_ch == 0) {
        m_firstVideoView = [[IRRTSPMediaView alloc] init];
        m_firstVideoView.player = self.player;
        //        m_firstVideoView.m_videoView.tag = 1;
        m_firstVideoView.doubleTapEnable = YES;
        [m_firstView addSubview:m_firstVideoView];
        
        m_firstVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:m_firstVideoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_firstView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:m_firstVideoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_firstView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:m_firstVideoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:m_firstView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:m_firstVideoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:m_firstView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        top.active = YES;
        bottom.active = YES;
        left.active = YES;
        right.active = YES;
    } else if (_ch == 1) {
        m_secondVideoView = [[IRRTSPMediaView alloc] init];
        m_secondVideoView.player = self.player2;
        //        m_secondVideoView.m_videoView.tag = 2;
        m_secondVideoView.doubleTapEnable = YES;
        [m_secondView addSubview:m_secondVideoView];
        
        m_secondVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:m_secondVideoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_secondView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:m_secondVideoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_secondView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:m_secondVideoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:m_secondView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:m_secondVideoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:m_secondView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        top.active = YES;
        bottom.active = YES;
        left.active = YES;
        right.active = YES;
    } else if (_ch == 2) {
        m_thirdVideoView = [[IRRTSPMediaView alloc] init];
        m_thirdVideoView.player = self.player3;
        //        m_thirdVideoView.m_videoView.tag = 3;
        m_thirdVideoView.doubleTapEnable = YES;
        [m_thirdView addSubview:m_thirdVideoView];
        
        m_thirdVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:m_thirdVideoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_thirdView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:m_thirdVideoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_thirdView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:m_thirdVideoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:m_thirdView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:m_thirdVideoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:m_thirdView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        top.active = YES;
        bottom.active = YES;
        left.active = YES;
        right.active = YES;
        
    } else if (_ch == 3) {
        m_fourthVideoView = [[IRRTSPMediaView alloc] init];
        m_fourthVideoView.player = self.player4;
        //        m_fourthVideoView.m_videoView.tag = 4;
        m_fourthVideoView.doubleTapEnable = YES;
        [m_fourthView addSubview:m_fourthVideoView];
        
        m_fourthVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:m_fourthVideoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_fourthView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:m_fourthVideoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_fourthView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:m_fourthVideoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:m_fourthView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:m_fourthVideoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:m_fourthView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        top.active = YES;
        bottom.active = YES;
        left.active = YES;
        right.active = YES;
    }
}

- (void)resizeViewBlock {
    if (m_intDisplayMode == 1) {
        switch (m_intCurrentCh) {
            case 0:
                m_firstViewConstraint = [m_firstViewConstraint updateMultiplier:1.0f];
                break;
            case 1:
                m_secondViewConstraint = [m_secondViewConstraint updateMultiplier:1.0f];
                break;
            case 2:
                m_thirdViewConstraint = [m_thirdViewConstraint updateMultiplier:1.0f];
                break;
            case 3:
                m_fourthViewConstraint = [m_fourthViewConstraint updateMultiplier:1.0f];
                break;
            default:
                break;
        }
    } else {
        m_firstViewConstraint = [m_firstViewConstraint updateMultiplier:0.5f];
        m_secondViewConstraint = [m_secondViewConstraint updateMultiplier:0.5f];
        m_thirdViewConstraint = [m_thirdViewConstraint updateMultiplier:0.5f];
        m_fourthViewConstraint = [m_fourthViewConstraint updateMultiplier:0.5f];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    IRRTSPSettingsViewController *vc = [segue destinationViewController];
    vc.delegate = self;
}

- (void)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC {
    
}

- (void)updatedSettings:(DeviceClass *)device {
    m_aryDevices = [NSMutableArray arrayWithArray:[IRStreamConnectionRequestFactory createStreamConnectionRequest]];
    
    [self startStreamConnectionByDeviceIndex:0];
}

- (void)stateAction:(NSNotification *)notification {
    IRState * state = [IRState stateFromUserInfo:notification.userInfo];
    
    NSString * text;
    switch (state.current) {
        case IRPlayerStateNone:
            text = @"None";
            break;
        case IRPlayerStateBuffering:
            text = @"Buffering...";
            break;
        case IRPlayerStateReadyToPlay:
            text = @"Prepare";
            [self.player play];
            break;
        case IRPlayerStatePlaying:
            text = @"Playing";
            break;
        case IRPlayerStateSuspend:
            text = @"Suspend";
            break;
        case IRPlayerStateFinished:
            text = @"Finished";
            break;
        case IRPlayerStateFailed:
            text = @"Error";
            break;
    }
}

- (void)progressAction:(NSNotification *)notification {
    
}

- (void)playableAction:(NSNotification *)notification {
    IRPlayable * playable = [IRPlayable playableFromUserInfo:notification.userInfo];
    NSLog(@"playable time : %f", playable.current);
}

- (void)errorAction:(NSNotification *)notification {
    IRError * error = [IRError errorFromUserInfo:notification.userInfo];
    NSLog(@"player did error : %@", error.error);
}

- (NSString *)timeStringFromSeconds:(CGFloat)seconds {
    return [NSString stringWithFormat:@"%ld:%.2ld", (long)seconds / 60, (long)seconds % 60];
}

@end
