//
//  IRRTSPMediaView.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/28.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRRTSPMediaView.h"
#import "DeviceClass.h"
#import "AppDelegate.h"
#import "IRStreamControllerFactory.h"

@implementation IRRTSPMediaView {
    IRStreamController *streamController;
    NSArray *modes;
    IRMediaParameter* parameter;
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
        [self addSubview:m_loadVew];
        
        [self.loadingActivity setColor:[UIColor colorWithRed:56.0f/255.0f green:100.0f/255.0f blue:0.0f alpha:1.0f]];
    }
    return self;
}

- (void)dealloc {
    [self stopStreaming:YES];
}

- (void)setPlayer:(IRPlayerImp *)player {
    _player = player;
    
    imageView = [[UIImageView alloc] initWithFrame:self.player.view.frame];
    [self.player.view addSubview:imageView];
    [self.videoView insertSubview:self.player.view atIndex:0];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    top.active = YES;
    bottom.active = YES;
    left.active = YES;
    right.active = YES;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    top = [NSLayoutConstraint constraintWithItem:self.player.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    bottom = [NSLayoutConstraint constraintWithItem:self.player.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    left = [NSLayoutConstraint constraintWithItem:self.player.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    right = [NSLayoutConstraint constraintWithItem:self.player.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    top.active = YES;
    bottom.active = YES;
    left.active = YES;
    right.active = YES;
    self.player.view.translatesAutoresizingMaskIntoConstraints = NO;
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

- (void)startStreamConnectionWithDevice:(DeviceClass*)device {
    if(streamController){
        [streamController stopStreaming:YES];
        streamController = nil;
    }
    
    streamController = [[IRStreamController alloc] initWithDevice:device];
    streamController.eventDelegate = self;
    
    [self startStreamConnection];
}

- (void)startStreamConnection {
    streamController.m_videoView = self.player;
    [streamController startStreamConnection];
}

- (NSInteger)stopStreaming:(BOOL)stopForever {
    NSInteger iRtn = 0;
    
    [streamController stopStreaming:stopForever];
    
    return iRtn;
}

- (BOOL)IsStopStreaming {
    return m_blnStopStreaming;
}

- (void)connectReslt:(id)_videoView Connection:(BOOL)connection MicSupport:(BOOL)_micSupport SpeakerSupport:(BOOL)_speakerSupport {
    [self.loadingActivity stopAnimating];
    
    if(!connection){
        [imageView setImage:[UIImage imageNamed:@"landscape_linkfail.png"]];
        [imageView setHidden:NO];
        return;
    }
    
    [imageView setImage:[UIImage imageNamed:@"landscape_1.png"]];
    [imageView setHidden:YES];
    
    if([[self.player renderModes] count] == 0){
        [self.player setRenderModes:modes];
        [self.player selectRenderMode:modes[0]];
    }
}

- (void)showErrorMessage:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.infoLabel setText:msg];
        [self.infoLabel setHidden:NO];
    });
}

- (void)streamControllerStatusChanged:(IRStreamControllerStatus)status {
    switch (status) {
        case IRStreamControllerStatus_PreparingToPlay:
            [self.loadingActivity startAnimating];
            [imageView setImage:[UIImage imageNamed:@"landscape_1.png"]];
            [imageView setHidden:NO];
            [self.infoLabel setHidden:YES];
            break;
            
        default:
            break;
    }
}

- (void)finishRecordingWithShowLoadingIcon:(BOOL)show {
    
}


- (void)recordingFailedWithErrorCode:(NSInteger)code desc:(NSString *)desc {
    
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

