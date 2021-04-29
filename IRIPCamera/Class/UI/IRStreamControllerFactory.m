//
//  IRStreamControllerFactory.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRStreamControllerFactory.h"
#import "IRCustomStreamConnectionRequest.h"

@implementation IRStreamControllerFactory

+ (IRStreamController *)createStreamControllerByRequset:(IRStreamConnectionRequest *)request{
    IRStreamController *streamController = nil;
    if([request isKindOfClass:[IRCustomStreamConnectionRequest class]]){
        streamController = [[IRStreamController alloc] initWithDevice:((IRCustomStreamConnectionRequest*)request).device];
    }else{
        streamController = [[IRStreamController alloc] initWithRtspUrl:request.rtspUrl];
    }
    
    return streamController;
}

@end
