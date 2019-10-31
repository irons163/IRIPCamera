//
//  IRRTSPPlayer.h
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import "IRRTSPMediaView.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRRTSPPlayer : UIViewController {
    NSInteger m_intDisplayMode;
    NSInteger m_intCurrentCh;
    NSMutableArray *m_aryVideoView;
    
    __weak IBOutlet NSLayoutConstraint *m_firstViewConstraint;
    __weak IBOutlet NSLayoutConstraint *m_secondViewConstraint;
    __weak IBOutlet NSLayoutConstraint *m_thirdViewConstraint;
    __weak IBOutlet NSLayoutConstraint *m_fourthViewConstraint;
    __weak IBOutlet UIView *m_firstView;
    __weak IBOutlet UIView *m_secondView;
    __weak IBOutlet UIView *m_thirdView;
    __weak IBOutlet UIView *m_fourthView;
    IRRTSPMediaView *m_firstVideoView;
    IRRTSPMediaView *m_secondVideoView;
    IRRTSPMediaView *m_thirdVideoView;
    IRRTSPMediaView *m_fourthVideoView;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *m_LoadingActivity;
@property (weak, nonatomic) IBOutlet IRPlayerImp *m_videoView;
@property (weak, nonatomic) IBOutlet UILabel *m_InfoLabel;

@end

NS_ASSUME_NONNULL_END
