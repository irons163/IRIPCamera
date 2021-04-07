//
//  StaticHttpRequest.h
//  IRIPCamera
//
//  Created by sniApp on 2014/11/2.
//  Copyright (c) 2014年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
//#import "httpRequest.h"

typedef enum _deviceType
{
    IPCAM_TYPE,
    ROUTER_TYPE
}deviceType;

@protocol StaticHttpRequestDelegate<NSObject,UIAlertViewDelegate>

- (void) didFinishStaticRequestJSON:(id) _strAckResult callbackID:(NSUInteger) _callback;
- (void) failToStaticRequestWithErrorCode:(NSInteger) _iFailStatus description:(NSString*) _desc callbackID:(NSUInteger) _callback;

@optional
- (void) updateProgressWithTotalBytesRead:(long long)_totalBytesRead TotalBytesExpectedToRead:(long long)_totalBytesExpectedToRead;

@end

@interface StaticHttpRequest : NSObject{
    NSMutableDictionary* targetDictionary;
    AFHTTPRequestOperationManager* manager;
    NSOperationQueue* requestQueue;
    NSOperationQueue* downloadQueue;
    BOOL downloading;
    id<StaticHttpRequestDelegate> FWCheckTarget;
    NSDictionary* FwCheckResponse;
    id upgradeDevice;
}

//@property (nonatomic ,retain) id<StaticHttpRequestDelegate> delegate;

@property (nonatomic, strong) NSOperationQueue* checkStatusQueue;

-(id) init UNAVAILABLE_ATTRIBUTE;
+(id) new UNAVAILABLE_ATTRIBUTE;

+(id)sharedInstance;
-(void)destroySharedInstance;
-(void)cleanCamCheck;
-(void)cleanRouterCheck;

//-(void)doJsonHttpRequestWithUrl:(NSString *) _url
//                         method:(NSString*) _method
//                       postData:(NSData *) _postData
//                     callbackID:(NSUInteger) _callback
//                         target:(id<StaticHttpRequestDelegate>)_target;

-(void)doJsonRequestWithToken:(NSString*)_token
                 externalLink:(NSString*)_externalLink
                          Url:(NSString *)_url
                       method:(NSString *)_method
                     postData:(NSData *)_postData
                   callbackID:(NSUInteger)_callback
                       target:(id<StaticHttpRequestDelegate>)_target;

-(void)doDownloadtoPath:(NSString*)_path
                    url:(NSString*)_url
             callbackID:(NSUInteger)_callback
                 target:(id<StaticHttpRequestDelegate>)_target;

-(void)stopDownload;

-(NSString*)getSchecmeFromLoginResult:(NSDictionary*)_loginResult;

-(void)checkNewFirmwareWithModel:(NSString *)_model Version:(NSString *)_version Device:(id)_device DeviceNeedUpdate:(BOOL)_deviceNeedUpdate;

-(void)sleepWithTimeInterval:(double)seconds Function:(const char*)_function Line:(int)_line File:(char*)_file;

@end
