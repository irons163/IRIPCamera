//
//  staticHttpRequest.m
//  IRIPCamera
//
//  Created by sniApp on 2014/11/2.
//  Copyright (c) 2014年 sniApp. All rights reserved.
//

#import "StaticHttpRequest.h"
#import "AppDelegate.h"
#import "DeviceClass.h"

#define TIMEOUT_INTERVAL 15


__strong static id master = nil;
static dispatch_once_t p = 0;

@implementation StaticHttpRequest{
    id<StaticHttpRequestDelegate> downloadTarget;
    NSUInteger downloadCallback;
}



-(void)dealloc
{
    manager.operationQueue = nil;
    requestQueue = nil;
    downloadQueue = nil;
    targetDictionary = nil;
    manager = nil;
    NSLog(@"StaticHttpRequest Got Dealoc!!");
}

+(id)sharedInstance
{
    //    if (!master) {
    //        master = [self alloc];
    //        master = [master init];
    //        NSLog(@"StaticHttpRequest Got New!!");
    //    }
    //    return master;
    dispatch_once(&p, ^{
        master = [[self alloc] init];
    });
    
    return master;
}

-(id)init{
    if ((self = [super init])) {
        targetDictionary = [NSMutableDictionary dictionary];
        manager = [AFHTTPRequestOperationManager manager];
        _checkStatusQueue = [[NSOperationQueue alloc] init];
        _checkStatusQueue.maxConcurrentOperationCount = 1;
        requestQueue = [[NSOperationQueue alloc] init];
        downloadQueue = [[NSOperationQueue alloc] init];
        downloadQueue.maxConcurrentOperationCount = 20;
        downloading = NO;
    }
    return self;
}

-(void)destroySharedInstance{
    if (manager.operationQueue.operationCount > 0 || _checkStatusQueue.operationCount > 0 || requestQueue.operationCount > 0 || downloadQueue.operationCount > 0) {
        NSLog(@"StaticeHttpRequest Got Destroy");
        [targetDictionary removeAllObjects];
        [manager.operationQueue cancelAllOperations];
        [_checkStatusQueue cancelAllOperations];
        _checkStatusQueue = nil;
        [requestQueue cancelAllOperations];
        requestQueue = nil;
        [downloadQueue cancelAllOperations];
        downloadQueue = nil;
        manager = nil;
        master = nil;
        p = 0;
    }
}

-(void)cleanCamCheck{
    NSArray* operationArray = [self.checkStatusQueue operations];
    for (NSOperation* tmpOperation  in operationArray) {
        if ([tmpOperation isKindOfClass:[NSInvocationOperation class]]) {
            [tmpOperation cancel];
        }
    }
}

-(void)cleanRouterCheck{
    NSArray* operationArray = [self.checkStatusQueue operations];
    for (NSOperation* tmpOperation  in operationArray) {
        if ([tmpOperation isKindOfClass:[NSBlockOperation class]]) {
            [tmpOperation cancel];
        }
    }
}

-(void)doJsonRequestWithToken:(NSString *)_token externalLink:(NSString *)_externalLink Url:(NSString *)_url method:(NSString *)_method postData:(NSData *)_postData callbackID:(NSUInteger)_callback target:(id<StaticHttpRequestDelegate>)_target{
    NSString* URL = nil;
    if ([_url hasPrefix:@"://"]) {
        URL = [NSString stringWithFormat:@"https%@",_url];
    }else{
        URL = [NSString stringWithString:_url];
    }
    NSURL* requestURL = [NSURL URLWithString:URL];
    if ([requestURL.scheme isEqualToString:@"http"]) {
        [self doJsonHttpRequestWithToken:_token
                            externalLink:_externalLink
                                     Url:URL
                                  method:_method
                                postData:_postData
                              callbackID:_callback
                                  Scheme:@"http"
                                  target:_target];
    }else{
        [self doJsonHttpsRequestWithToken:_token
                             externalLink:_externalLink
                                      Url:URL
                                   method:_method
                                 postData:_postData
                               callbackID:_callback
                                   Scheme:@"https"
                                   target:_target];
    }
    
}

-(void)doJsonHttpsRequestWithToken:(NSString *)_token externalLink:(NSString *)_externalLink Url:(NSString *)_url method:(NSString *)_method postData:(NSData *)_postData callbackID:(NSUInteger)_callback Scheme:(NSString*)_scheme target:(id<StaticHttpRequestDelegate>)_target
{
    if (!targetDictionary) {
        NSLog(@"Request Stop!!");
        return;
    }
    
    NSURL* requestURL = [NSURL URLWithString:_url];
    requestURL = [self changeURL:requestURL withScheme:_scheme];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:TIMEOUT_INTERVAL];
    
    NSLog(@"StaticeHttpRequest URL:%@ - %zd",requestURL,requestQueue.operationCount);
    
    [targetDictionary setObject:_target forKey:[NSString stringWithFormat:@"%@-%zd",requestURL,_callback]];
    
    if (_postData && [_method isEqualToString:@"POST"]) {
        NSLog(@"%@",[[NSString alloc] initWithData:_postData encoding:NSUTF8StringEncoding]);
        [request setHTTPBody:_postData];
    }
    
    [request setHTTPMethod:_method];
    
    if (_token) {
        [request setValue:_token forHTTPHeaderField:@"Token"];
    }
    
    if (_externalLink) {
        [request setValue:_externalLink forHTTPHeaderField:@"EXTERNAL_LINK"];
    }else{
        [request setValue:requestURL.host forHTTPHeaderField:@"EXTERNAL_LINK"];
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    op.securityPolicy.allowInvalidCertificates = YES;
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [op setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        NSURL* redirectURL = [request URL];
        if (!(!redirectURL || ([redirectURL.host isEqualToString:requestURL.host] && [redirectURL.port integerValue]==[requestURL.port integerValue]))) {
            NSLog(@"Redirect %@ to %@",requestURL,redirectURL);
            [connection cancel];
            connection = nil;
            [self doJsonHttpsRequestWithToken:_token
                                 externalLink:_externalLink
                                          Url:[redirectURL absoluteString]
                                       method:_method
                                     postData:_postData
                                   callbackID:_callback
                                       Scheme:_scheme
                                       target:_target];
            return nil;
        }
        return request;
    }];
    
    [requestQueue addOperation:op];
}

-(void)doJsonHttpRequestWithToken:(NSString *)_token externalLink:(NSString *)_externalLink Url:(NSString *)_url method:(NSString *)_method postData:(NSData *)_postData callbackID:(NSUInteger)_callback  Scheme:(NSString*)_scheme target:(id<StaticHttpRequestDelegate>)_target{
    if (!targetDictionary) {
        NSLog(@"Request Stop!!");
        return;
    }
    
    NSURL* requestURL = [NSURL URLWithString:_url];
    requestURL = [self changeURL:requestURL withScheme:_scheme];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:TIMEOUT_INTERVAL];
    NSLog(@"StaticeHttpRequest URL:%@",requestURL);
    
    [targetDictionary setObject:_target forKey:[[NSString alloc] initWithFormat:@"%@-%zd",requestURL,_callback]];
    
    [request setHTTPMethod:_method];
    
    if (_token) {
        [request setValue:_token forHTTPHeaderField:@"Token"];
    }
    
    if (_externalLink) {
        [request setValue:_externalLink forHTTPHeaderField:@"EXTERNAL_LINK"];
    }else{
        [request setValue:requestURL.host forHTTPHeaderField:@"EXTERNAL_LINK"];
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    op.securityPolicy.allowInvalidCertificates = YES;
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (targetDictionary && [targetDictionary objectForKey:[NSString stringWithFormat:@"%@-%zd",requestURL,_callback]]) {
            NSLog(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            NSString* decryptedString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *data = [decryptedString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* json = nil;
            if (data) {
                json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
            }else{
                json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            }
            
            NSLog(@"%@ Response String : %@",requestURL,decryptedString);
            if ([_target respondsToSelector:@selector(didFinishStaticRequestJSON:callbackID:)]) {
                [_target didFinishStaticRequestJSON:json callbackID:_callback];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (targetDictionary && [targetDictionary objectForKey:[NSString stringWithFormat:@"%@-%zd",requestURL,_callback]]) {
            NSLog(@"%@ Response Error  %@",requestURL,error);
            if ([_target respondsToSelector:@selector(failToStaticRequestWithErrorCode:description:callbackID:)]) {
                [_target failToStaticRequestWithErrorCode:error.code description:error.localizedDescription callbackID:_callback];
            }
        }
    }];
    
    [op setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        NSURL* redirectURL = [request URL];
        if (!(!redirectURL || ([redirectURL.host isEqualToString:requestURL.host] && [redirectURL.port integerValue]==[requestURL.port integerValue]))) {
            NSLog(@"Redirect %@ to %@",requestURL,redirectURL);
            [connection cancel];
            connection = nil;
            [self doJsonHttpRequestWithToken:_token
                                externalLink:_externalLink
                                         Url:[redirectURL absoluteString]
                                      method:_method
                                    postData:_postData
                                  callbackID:_callback
                                      Scheme:_scheme
                                      target:_target];
            return nil;
        }
        return request;
    }];
    
    [requestQueue addOperation:op];
}

-(void)doDownloadtoPath:(NSString *)_path url:(NSString *)_url callbackID:(NSUInteger)_callback target:(id<StaticHttpRequestDelegate>)_target{
    if (!targetDictionary) {
        NSLog(@"Request Stop!!");
        return;
    }
    
    NSURL* requestURL = [NSURL URLWithString:_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:TIMEOUT_INTERVAL];
    
    NSLog(@"doDownloadtoPath URL:%@",requestURL);
    
    [targetDictionary setObject:_target forKey:[NSString stringWithFormat:@"%@-%zd",requestURL,_callback]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:_path append:YES];
    downloading = YES;
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded %@ to %@",responseObject, _path);
        if (targetDictionary && [targetDictionary objectForKey:[NSString stringWithFormat:@"%@-%zd",requestURL,_callback]]) {
            if ([_target respondsToSelector:@selector(didFinishStaticRequestJSON:callbackID:)]) {
                [_target didFinishStaticRequestJSON:responseObject callbackID:_callback];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (targetDictionary && [targetDictionary objectForKey:[NSString stringWithFormat:@"%@-%zd",requestURL,_callback]]) {
            if (downloading && [_target respondsToSelector:@selector(failToStaticRequestWithErrorCode:description:callbackID:)]) {
                [_target failToStaticRequestWithErrorCode:error.code description:error.localizedDescription callbackID:_callback];
            }
        }
    }];
    
    [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"bytesRead: %zd, totalBytesRead: %lld, totalBytesExpected: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
        if (targetDictionary && [targetDictionary objectForKey:[NSString stringWithFormat:@"%@-%zd",requestURL,_callback]]) {
            if ([_target respondsToSelector:@selector(updateProgressWithTotalBytesRead:TotalBytesExpectedToRead:)]) {
                [_target updateProgressWithTotalBytesRead:totalBytesRead TotalBytesExpectedToRead:totalBytesExpectedToRead];
            }
        }
    }];
    
    [downloadQueue addOperation:op];
}

-(void)stopDownload{
    downloading = NO;
    if ([downloadQueue operationCount] > 0) {
        [downloadQueue cancelAllOperations];
    }
}

-(NSString*)getSchecmeFromLoginResult:(NSDictionary *)_loginResult{
    return @"http";//Support HTTP Only
    NSString* schecme = @"https";
    if ([[_loginResult objectForKey:@"AgentCapability"] boolValue]) {
        schecme = @"http";
    }
    return schecme;
}

-(NSURL*)changeURL:(NSURL*)_url withScheme:(NSString*)_scheme{
    
    if (!_url) {
        return _url;
    }
    
    if ([_url.scheme isEqualToString:_scheme]) {
        return _url;
    }
    
    NSString* str = [_url absoluteString];
    NSInteger colon = [str rangeOfString:@":"].location;
    if (colon != NSNotFound) {
        str = [str substringFromIndex:colon];
        str = [_scheme stringByAppendingString:str];
    }
    
    return [NSURL URLWithString:str];
}

-(void)sleepWithTimeInterval:(double)seconds Function:(const char*)_function Line:(int)_line File:(char*)_file{
    //NSLog(@"\n Function: %s\n Line: %d\n File: %s\n Interval: %f(s)",_function, _line, _file, seconds);
    [NSThread sleepForTimeInterval:seconds];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

@end
