//
//  IRRTSPMediaView.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/28.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRRTSPMediaView.h"
#import "deviceClass.h"
#import "dataDefine.h"
#import "AppDelegate.h"
#import "IRStreamControllerFactory.h"

#define LOGIN_IPCAM_CALLBACK    0X0001
#define GET_RTSPINFO_CALLBACK   0X0010
#define GET_AUDIOOUT_CALLBACK   0X0100
#define GET_FISHEYE_CENTER_CALLBACK 0X1000

#define MinZoomScale 1.0
#define RangeY 20.0

#define Login_Failed_via_UID 18
#define Login_Failed_via_Direct_Access 19
#define Login_Failed_via_IP 20

#define ERROR_DEVICE_NOT_ONLINE -3

@implementation IRRTSPMediaView {
    IRStreamController *streamController;
    NSArray *modes;
    IRMediaParameter* parameter;
}

- (void)dealloc {
    [self stopStreaming:YES];
//    [((KxMovieGLView*)self.m_videoView) closeGLView];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if(modes == nil){
            if(!parameter)
                parameter = [[IRFisheyeParameter alloc] initWithWidth:1440 height:1024 up:NO rx:510 ry:510 cx:680 cy:524 latmax:75];
            modes = [self createFisheyeModesWithParameter:parameter];
        }
        
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"IRRTSPMediaView" owner:self options:nil];
        UIView *m_loadVew = [nibObjects objectAtIndex:0];
        [m_loadVew setFrame:frame];
        
        [self addSubview:m_loadVew];//add xib file into subview
        
        
        [self.m_LoadingActivity setColor:[UIColor colorWithRed:56.0f/255.0f green:100.0f/255.0f blue:0.0f alpha:1.0f]];
    }
    return self;
}

- (void)setM_player:(IRPlayerImp *)m_player {
    _m_player = m_player;
    
//    self.m_player.view.frame = self.frame;
            
    //        ((KxMovieGLView*)self.m_videoView).delegate = self;
            
    imageView = [[UIImageView alloc] initWithFrame:self.m_player.view.frame];
    [self.m_player.view addSubview:imageView];
    [self.m_videoView insertSubview:self.m_player.view atIndex:0];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    top.active = YES;
    bottom.active = YES;
    left.active = YES;
    right.active = YES;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    top = [NSLayoutConstraint constraintWithItem:self.m_player.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    bottom = [NSLayoutConstraint constraintWithItem:self.m_player.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    left = [NSLayoutConstraint constraintWithItem:self.m_player.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    right = [NSLayoutConstraint constraintWithItem:self.m_player.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    top.active = YES;
    bottom.active = YES;
    left.active = YES;
    right.active = YES;
    self.m_player.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)startStreamConnectionWithRequest:(IRStreamConnectionRequest*)request {
    if(streamController){
        [streamController stopStreaming:YES];
        streamController = nil;
    }
    
    streamController = [IRStreamControllerFactory createStreamControllerByRequset:request];
    streamController.eventDelegate = self;
    
    [self startStreamConnection];
}

- (void)startStreamConnectionWithDevice:(deviceClass*)device {
    if(streamController){
        [streamController stopStreaming:YES];
        streamController = nil;
    }
    
    streamController = [[IRStreamController alloc] initWithDevice:device];
    streamController.eventDelegate = self;
    
    [self startStreamConnection];
}

- (void)startStreamConnection {
    streamController.m_videoView = self.m_player;
    [streamController startStreamConnection];
}

- (NSInteger)stopStreaming:(BOOL)_blnStopForever {
    NSInteger iRtn = 0;

    [streamController stopStreaming:_blnStopForever];
    
    return iRtn;
}

- (void)updateTimeLabelByTime:(double)time {
    if (time <= 0) {
        self.m_relayTimerBackground.hidden = YES;
    }else{
#if (defined Relay_Limit) || (defined DEV)
        self.m_relayTimerBackground.hidden = NO;
#endif
        NSTimeInterval aTimer = time - [[NSDate date] timeIntervalSince1970];
        int minute = (int)(aTimer/60);
        int second = aTimer - minute*60;
        
        NSString* timeString = [NSString stringWithFormat:@"%02d:%02d",minute,second];
        self.m_RelayTimerTitle.text = [NSString stringWithFormat:_(@"RelayTimeOut"),timeString];
    }
}

- (BOOL)IsStopStreaming {
    return m_blnStopStreaming;
}

- (void)connectReslt:(id)_videoView Connection:(BOOL)connection MicSupport:(BOOL)_micSupport SpeakerSupport:(BOOL)_speakerSupport {
    [self.m_LoadingActivity stopAnimating];
    
    if(!connection){
//        [((KxMovieGLView*)self.m_videoView) clearCanvas];
        [imageView setImage:[UIImage imageNamed:@"landscape_linkfail.png"]];
        [imageView setHidden:NO];
        return;
    }
    
    [imageView setImage:[UIImage imageNamed:@"landscape_1.png"]];
    [imageView setHidden:YES];
    
    if([[self.m_player renderModes] count] == 0){
        [self.m_player setRenderModes:modes];
        [self.m_player selectRenderMode:modes[0]];
    }
}

- (void)showErrorMessage:(NSString *)msg {
    [self.m_InfoLabel setText:msg];
    [self.m_InfoLabel setHidden:NO];
}

- (void)streamControllerStatusChanged:(IRStreamControllerStatus)status {
    switch (status) {
        case IRStreamControllerStatus_PreparingToPlay:
            [self.m_LoadingActivity startAnimating];
            [imageView setImage:[UIImage imageNamed:@"landscape_1.png"]];
            [imageView setHidden:NO];
            [self.m_InfoLabel setHidden:YES];
            break;
            
        default:
            break;
    }
}

- (void)finishRecordingWithShowLoadingIcon:(BOOL)_blnShow {
    
}


- (void)recordingFailedWithErrorCode:(NSInteger)_code desc:(NSString *)_desc {
    
}

- (NSArray<IRGLRenderMode*> *)createFisheyeModesWithParameter:(nullable IRMediaParameter *)parameter {
    IRGLRenderMode *normal = [[IRGLRenderMode2D alloc] init];
    IRGLRenderMode *fisheye2Pano = [[IRGLRenderMode2DFisheye2Pano alloc] init];
    IRGLRenderMode *fisheye = [[IRGLRenderMode3DFisheye alloc] init];
    IRGLRenderMode *fisheye4P = [[IRGLRenderModeMulti4P alloc] init];
    NSArray<IRGLRenderMode*>* modes = @[
                                        fisheye2Pano,
                                        fisheye,
                                        fisheye4P,
                                        normal
                                        ];
    
    normal.shiftController.enabled = NO;
    
    fisheye2Pano.contentMode = IRGLRenderContentModeScaleAspectFill;
    fisheye2Pano.wideDegreeX = 360;
    fisheye2Pano.wideDegreeY = 20;
    
    fisheye4P.parameter = fisheye.parameter = [[IRFisheyeParameter alloc] initWithWidth:0 height:0 up:NO rx:0 ry:0 cx:0 cy:0 latmax:80];
    fisheye4P.aspect = fisheye.aspect = 16.0 / 9.0;
    
    normal.name = @"Rawdata";
    fisheye2Pano.name = @"Panorama";
    fisheye.name = @"Onelen";
    fisheye4P.name = @"Fourlens";
    
    return modes;
}

@end

