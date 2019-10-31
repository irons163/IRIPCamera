//
//  httpAudioSender.m
//  inputStreamAudio
//
//  Created by sniApp on 13/6/10.
//  Copyright (c) 2013年 sniApp. All rights reserved.
//

#import "httpAudioSender.h"
#import "NSStreamAdditions.h"

@interface httpAudioSender(PrivateMethod)
-(void) buildAudioConnection;
-(void) closeAudio;
-(void) doAudioSend;
void _base64_encode_triple(unsigned char triple[3], char result[4]);
int base64_audio_encode(unsigned char *source, size_t sourcelen, char *target, size_t targetlen);
@end

@implementation httpAudioSender
@synthesize m_AudioData ,m_audioGetter ,iStream ,oStream ,m_blnLogin;
@synthesize m_hostPort ,m_password ,m_strHost ,m_userName;
@synthesize delegate, m_strCGIPath, m_strURL;

-(id) initWithHost:(NSString *) _hostAddr port:(NSInteger) _hostPort user:(NSString *) _userName password:(NSString *) _pwd delegage:(id) _delegate
{
    if (![super init])
    {
        return nil;
    }
    
    self.m_strHost  = [NSString stringWithFormat:@"%@",_hostAddr];
    self.m_userName = [NSString stringWithFormat:@"%@",_userName];
    self.m_password = [NSString stringWithFormat:@"%@",_pwd];
    self.m_hostPort = _hostPort;
    self.delegate = _delegate;
    //    self.m_audioGetter = [[AudioInput alloc] initWithSampleRate:8000 bps:0 balign:0 fsize:0];
    
    //    self.m_audioGetter = [[AudioInput alloc] initWithSampleRate:8000 bps:0 balign:0 fsize:0 audioType:@"ulaw"];
    //[self.m_audioGetter setDelegate:self];
    return self;
}

-(id) initWithURL:(NSString *)_url user:(NSString *)_userName password:(NSString *)_pwd delegage:(id)_delegate
{
    if (![super init])
    {
        return nil;
    }
    
    self.m_strURL  = [NSString stringWithFormat:@"%@",_url];
    self.m_userName = [NSString stringWithFormat:@"%@",_userName];
    self.m_password = [NSString stringWithFormat:@"%@",_pwd];
    self.delegate = _delegate;
    return self;
}

-(void) setPostCGIPath:(NSString *) _cgiPath sampleRate:(NSInteger) _sampleRate bitsPerSample:(NSInteger) _bitsPerSample audioType:(NSString*) _audioType
{
    self.m_strCGIPath = [NSString stringWithFormat:@"%@", _cgiPath];
    self.m_strURL = [NSString stringWithFormat:@"http://%@:%d/%@",self.m_strHost, self.m_hostPort, _cgiPath];
    self.m_audioGetter = [[AudioInput alloc] initWithSampleRate:_sampleRate bps:_bitsPerSample balign:0 fsize:0 audioType:_audioType];
    [self.m_audioGetter setDelegate:self];
    
}

-(void) dealloc
{
    [self closeAudio];
    [self.m_AudioData release];
    [self.m_audioGetter release];
    
    [super dealloc];
}

-(void) twoWayAudiostart:(BOOL)_blnToDevice
{
    NSLog(@"%@",self.m_strHost);
    if (![self.m_strHost isEqualToString:@""]) {
        NSURL *website = [NSURL URLWithString:self.m_strHost];
        if (!website) {
            NSLog(@"%@ is not a valid URL",self.m_strHost);
            [self.delegate twoWayAudioFailedEvnent:FAIL_HOST_ADDRESS_INVALID];
            return;
        } else {
#ifdef DEV
            if (!iStream && !oStream) {
#endif
                [NSStream getStreamsToHostNamed:self.m_strHost
                                           port:self.m_hostPort
                                    inputStream:&iStream
                                   outputStream:&oStream];
                [iStream retain];
                [oStream retain];
                
                [iStream setDelegate:self];
                [oStream setDelegate:self];
                
                [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                   forMode:NSDefaultRunLoopMode];
                [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                   forMode:NSDefaultRunLoopMode];
                
                [oStream open];
                [iStream open];
                [self.m_audioGetter start];
#ifdef DEV
            }
#endif
            if (_blnToDevice) {
                m_blnStopAudio = NO;
            }
            else{
                m_blnStopAudio = YES;
            }
        }
    }
}

-(void) twoWayAudiostop:(BOOL)_blnToDevice
{
    m_blnStopAudio = YES;
    if (_blnToDevice) {
        [self closeAudio];
    }
}


#pragma NSStream delegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            NSLog(@"NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"NSStreamEventOpenCompleted");
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"NSStreamEventHasBytesAvailable");
            if(aStream == iStream)
            {
                uint8_t buf[1024]={"\0"};
                [iStream read:buf maxLength:sizeof(buf)];
                NSLog(@"%s",buf);
                NSData *tmpData = [[[NSData alloc] initWithBytes:buf length:sizeof(buf)] autorelease];
                NSString *ack = [[NSString alloc] initWithData:tmpData encoding:NSASCIIStringEncoding];
                [ [ack lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSLog(@"[%d] ,%@",[ack length],ack);
                if([[ack lowercaseString] rangeOfString:@"occupied"].location != NSNotFound)
                {
                    NSLog(@"some body has used two way audio");
                    [self.delegate twoWayAudioFailedEvnent:FAIL_TWO_WAY_AUDIO_USED];
                    [self twoWayAudiostop:YES];
                }
                else if([[ack lowercaseString] rangeOfString:@"disabled"].location != NSNotFound)
                {
                    NSLog(@"audio config disabled ");
                    [self.delegate twoWayAudioFailedEvnent:FAIL_TWO_WAY_AUDIO_OFF];
                    [self twoWayAudiostop:YES];
                }
                else if([[ack lowercaseString] rangeOfString:@"401 unauthorized"].location != NSNotFound)
                {
                    NSLog(@"user name password error");
                    [self.delegate twoWayAudioFailedEvnent:FAIL_USERNAME_PASSWORD];
                    [self twoWayAudiostop:YES];
                }
                else
                {
                    
                }
                
                [ack release];
                
                
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            //            NSLog(@"NSStreamEventHasSpaceAvailable");
            if (aStream == oStream && !self.m_blnLogin)
            {
                [self buildAudioConnection];
            }
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"NSStreamEventErrorOccurred");
            NSLog(@"error code=%d desc=%@",[[aStream streamError] code] ,[[aStream streamError] localizedDescription]);
            if(aStream == oStream)
            {
                NSLog(@"Connection fail");
                [self closeAudio];
                [self.delegate twoWayAudioFailedEvnent:FAIL_TO_OPEN_SERVER];
            }
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered");
            break;
        default:
            break;
    }
}

#pragma AudtioInput Delegate
-(void) putAudio:(void *)_audioData length:(int)_length
{
    if(!m_blnStopAudio)
    {
        if(!self.m_AudioData)
            self.m_AudioData = [[NSMutableData alloc] init];
        [self.m_AudioData appendBytes:_audioData length:_length];
        //        NSLog(@"size=%d",_length);
        if([self.m_AudioData length] >= 512)
        {
            NSLog(@"audio len gth%d",[self.m_AudioData length]);
            [oStream write:[self.m_AudioData bytes] maxLength:[self.m_AudioData length]];
            [self.m_AudioData release];
            self.m_AudioData = [[NSMutableData alloc] init];
            //            [NSThread detachNewThreadSelector:@selector(doAudioSend) toTarget:self withObject:nil];
            //            [self performSelectorOnMainThread:@selector(doAudioSend) withObject:nil waitUntilDone:YES];
            
        }
    }
}

@end


@implementation httpAudioSender(PrivateMethod)

-(void) doAudioSend
{
    if([self.m_AudioData length] >= 512)
    {
        
        [oStream write:[self.m_AudioData bytes] maxLength:[self.m_AudioData length]];
        [self.m_AudioData release];
        self.m_AudioData = [[NSMutableData alloc] init];
    }
    
}

-(void) closeAudio
{
    [self.m_audioGetter stop];
    self.m_blnLogin = NO;
    if (self.m_AudioData) {
        [self.m_AudioData release];
        self.m_AudioData = nil;
    }
    
    self.m_AudioData = [[NSMutableData alloc] initWithData:[@"---------------------------6066166931395477081095466896" dataUsingEncoding:
                                                            NSUTF8StringEncoding]];
    [oStream write:[self.m_AudioData bytes] maxLength:[self.m_AudioData length]];
    [self.m_AudioData release];
    self.m_AudioData = nil;
    
    if (iStream) {
        CFReadStreamClose((CFReadStreamRef)iStream);
        CFRelease(iStream);
        iStream = nil;
    }
    if (oStream) {
        CFWriteStreamClose((CFWriteStreamRef)oStream);
        CFRelease(oStream);
        oStream = nil;
    }
}

/**
 * encode three bytes using base64 (RFC 3548)
 *
 * @param triple three bytes that should be encoded
 * @param result buffer of four characters where the result is stored
 */
void _base64_encode_triple(unsigned char triple[3], char result[4])
{
    const char *BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    int tripleValue, i;
    
    tripleValue = triple[0];
    tripleValue *= 256;
    tripleValue += triple[1];
    tripleValue *= 256;
    tripleValue += triple[2];
    
    for (i=0; i<4; i++)
    {
        result[3-i] = BASE64_CHARS[tripleValue%64];
        tripleValue /= 64;
    }
}

/**
 * encode an array of bytes using Base64 (RFC 3548)
 *
 * @param source the source buffer
 * @param sourcelen the length of the source buffer
 * @param target the target buffer
 * @param targetlen the length of the target buffer
 * @return 1 on success, 0 otherwise
 */
int base64_audio_encode(unsigned char *source, size_t sourcelen, char *target, size_t targetlen)
{
    /* check if the result will fit in the target buffer */
    if ((sourcelen+2)/3*4 > targetlen-1)
        return 0;
    
    /* encode all full triples */
    while (sourcelen >= 3)
    {
        _base64_encode_triple(source, target);
        sourcelen -= 3;
        source += 3;
        target += 4;
    }
    
    /* encode the last one or two characters */
    if (sourcelen > 0)
    {
        unsigned char temp[3];
        memset(temp, 0, sizeof(temp));
        memcpy(temp, source, sourcelen);
        _base64_encode_triple(temp, target);
        target[3] = '=';
        if (sourcelen == 1)
            target[2] = '=';
        
        target += 4;
    }
    
    /* terminate the string */
    target[0] = 0;
    
    return 1;
}

-(void) buildAudioConnection
{
    char tmpAuth[256];
    char tmpEnCodedAuth[256];
    sprintf(tmpAuth, "%s:%s", [self.m_userName UTF8String], [self.m_password UTF8String]);
    base64_audio_encode((unsigned char *)tmpAuth, strlen(tmpAuth), tmpEnCodedAuth, 256);
    
    //    NSLog(@"uotputStr=%@",[self decodeBase64:inputStr]);
    
    const uint8_t httpHeader[1024];
    char *httpMethod;
    char *httpContentType;
    char httpTargetFile[256];
    
    // Nevio protocal
    httpMethod = "POST";
    sprintf(httpTargetFile, "/commands/audioback.do");
    httpContentType = "application/x-www-form-urlencoded";
    
    sprintf(httpHeader,
            "%s /%s HTTP/1.0\r\n"
            "Content-Type: %s\r\n"
            "Keep-Alive: 115\r\n"
            "Connection: keep-alive\r\n"
            "Referer: %s\r\n"
            "Content-Type: multipart/form-data; boundary=---------------------------6066166931395477081095466896\r\n"
            "Content-Length: 99999999\r\n"
            "Authorization: Basic %s\r\n\r\n"
            "-----------------------------6066166931395477081095466896\r\n"
            "Content-Disposition: form-data; name=\"audioOutput\"; filename=\"8k_16bit_10sec.pcm\"\r\n\r\n"
            , httpMethod
            , [self.m_strCGIPath UTF8String]
            , httpContentType
            , [self.m_strHost UTF8String]
            , tmpEnCodedAuth);
    
    NSLog(@"%s", httpHeader);
    self.m_blnLogin = YES;
    [oStream write:httpHeader maxLength:sizeof(httpHeader)];
    
    //    [oStream close];
    
}


@end
