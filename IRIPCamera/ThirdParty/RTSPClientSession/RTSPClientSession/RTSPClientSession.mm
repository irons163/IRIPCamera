
//
//  RTSPClient.m
//  RTSPClient
//
//  Copyright 2010 Dropcam. All rights reserved.
//

#import "RTSPClientSession.h"
#include <liveMedia.hh>
#include <BasicUsageEnvironment.hh>
#include <GroupsockHelper.hh>

@interface RTSPClientSession (PrivateMethod)

- (void)DESCRIBECallback:(RTSPClient *)_rtspClient code:(int)_resultCode result:(char *)_resultString;
- (void)setupNextSubsession:(RTSPClient *)_rtspClient;
- (void)SETUPCallbackByRtspClient:(RTSPClient *)_rtspClient code:(int)_resoultCode result:(char *)_resultString;
- (void)PLAYCallbackByRtspClient:(RTSPClient *)_rtspClient code:(int)_resoultCode result:(char *)_resultString;
- (void)TEARDOWNCallbackByRtspClient:(RTSPClient *)_rtspClient code:(int)_resoultCode result:(char *)_resultString;
- (void)subsessionAfterPlaying:(void *)_clientData;
- (void)subsessionByeHandler:(void *)_clientData;
- (void)streamTimerHandler:(void *)_clientData;
- (void)shutdownStreamByRtspClient:(RTSPClient *)_rtspClient code:(int)_code;

@end

class StreamClientState {
    public :
    StreamClientState():iter(NULL), session(NULL), subsession(NULL), streamTimerTask(NULL), duration(0.0) {
        
    }
    virtual ~StreamClientState() {
        delete iter;
        
        if(session != NULL) {
            UsageEnvironment &env = session->envir();
            env.taskScheduler().unscheduleDelayedTask(streamTimerTask);
            Medium::close(session);
        }
    }
    
public:
    MediaSubsessionIterator *iter;
    MediaSession *session;
    MediaSubsession *subsession;
    TaskToken streamTimerTask;
    double duration;
};

class ourRTSPClient : public RTSPClient {
public:
    static ourRTSPClient* createNew(UsageEnvironment &env, char const *_rstpURL, int verbosityLevel = 0
                                    ,char const* applicationName = NULL, portNumBits tunnelOverHTTPPortNum = 0) {
        return new ourRTSPClient(env, _rstpURL, verbosityLevel, applicationName, tunnelOverHTTPPortNum);
    }
    
protected:
    ourRTSPClient(UsageEnvironment &env, char const *_rstpURL, int verbosityLevel
                  ,char const* applicationName, portNumBits tunnelOverHTTPPortNum)
    
    :RTSPClient(env, _rstpURL, verbosityLevel, applicationName, tunnelOverHTTPPortNum ,-1) {
        
    }
    
public:
    StreamClientState scs;
    RTSPClientSession *m_myClientSession;
    Boolean m_blnStop;
};

static void DESCRIBECallback(RTSPClient *_rtspClient, int _resultCode, char *_resultString) {
    [((ourRTSPClient *)_rtspClient)->m_myClientSession DESCRIBECallback:_rtspClient code:_resultCode result:_resultString];
}

static void setupNextSubsession(RTSPClient *_rtspClient) {
    [((ourRTSPClient *)_rtspClient)->m_myClientSession setupNextSubsession:_rtspClient];
}

static void SETUPCallbackByRtspClient(RTSPClient *_rtspClient, int _resoultCode, char *_resultString) {
    [((ourRTSPClient *)_rtspClient)->m_myClientSession SETUPCallbackByRtspClient:_rtspClient code:_resoultCode result:_resultString];
}

static void PLAYCallbackByRtspClient(RTSPClient *_rtspClient, int _resoultCode, char *_resultString) {
    [((ourRTSPClient *)_rtspClient)->m_myClientSession PLAYCallbackByRtspClient:_rtspClient code:_resoultCode result:_resultString];
}

static void TEARDOWNCallbackByRtspClient(RTSPClient *_rtspClient, int _resoultCode, char *_resultString) {
    [((ourRTSPClient *)_rtspClient)->m_myClientSession TEARDOWNCallbackByRtspClient:_rtspClient code:_resoultCode result:_resultString];
}

static void subsessionAfterPlaying(void *_clientData) {
    MediaSubsession *subsession = (MediaSubsession *)_clientData;
    ourRTSPClient *tmpClient = (ourRTSPClient *)(subsession->miscPtr);
    [tmpClient->m_myClientSession subsessionAfterPlaying:_clientData];
}

static void subsessionByeHandler(void *_clientData) {
    MediaSubsession *subsession = (MediaSubsession *)_clientData;
    ourRTSPClient *tmpClient = (ourRTSPClient *)(subsession->miscPtr);
    [tmpClient->m_myClientSession subsessionByeHandler:_clientData];
}

static void streamTimerHandler(void *_clientData) {
    MediaSubsession *subsession = (MediaSubsession *)_clientData;
    ourRTSPClient *tmpClient = (ourRTSPClient *)(subsession->miscPtr);
    [tmpClient->m_myClientSession streamTimerHandler:_clientData];
}

static void shutdownStreamByRtspClient(RTSPClient *_rtspClient, int _resoultCode, char *_resultString) {
    [((ourRTSPClient *)_rtspClient)->m_myClientSession shutdownStreamByRtspClient:_rtspClient code:1];
}

class RTSPSubsessionMediaSink : public MediaSink {
    
public:
    static RTSPSubsessionMediaSink* createNew(UsageEnvironment &env, MediaSubsession &subsession, char const* streamId=NULL) {
        return new RTSPSubsessionMediaSink(env, subsession, streamId);
    }
    
private:
    RTSPSubsessionMediaSink(UsageEnvironment &env, MediaSubsession &subsession, char const* streamId):MediaSink(env),fSubsession(&subsession) {
        //        fSubsession = _subsession;
        bufLen = 256000;
        //        bufLen = 512000;
        buf = new uint8_t[bufLen];
    }
    
    virtual ~RTSPSubsessionMediaSink() {
        delete[] buf;
    }
    
    void afterGettingFrame(unsigned frameSize,
                           unsigned numTruncatedBytes,
                           struct timeval presentationTime,
                           unsigned durationInMicroseconds
                           ,int channel) {
        if (numTruncatedBytes > 0)
            NSLog(@"Frame was truncated.");
        
        ourRTSPClient *tmpClient = (ourRTSPClient*)(fSubsession->miscPtr);
        
        if (!tmpClient->m_blnStop) {
            [tmpClient->m_myClientSession.delegate didReceiveFrame:buf
                                                   frameDataLength:frameSize
                                                  presentationTime:presentationTime
                                            durationInMicroseconds:durationInMicroseconds
                                                         codecName:[NSString stringWithCString:fSubsession->codecName() encoding:NSUTF8StringEncoding]];
            
            if (!continuePlaying()) {
                NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@ continuePlaying fail");
            }
        }
    }
    
    static void afterGettingFrame1(void* clientData, unsigned frameSize,
                                   unsigned numTruncatedBytes,
                                   struct timeval presentationTime,
                                   unsigned durationInMicroseconds) {
        // Create an autorelease pool around each invocation of afterGettingFrame because we're being dispached
        // calls from the Live555 event loop, not a normal Cocoa event loop.
        
        @autoreleasepool {
            RTSPSubsessionMediaSink *sink = (RTSPSubsessionMediaSink*)clientData;
            sink->afterGettingFrame(frameSize, numTruncatedBytes, presentationTime, durationInMicroseconds ,sink->channelId);
        }
    }
    
    virtual Boolean continuePlaying() {
        if (fSource) {
            fSource->getNextFrame(buf, bufLen, afterGettingFrame1, this, onSourceClosure, this);
            return True;
        }
        NSLog(@"return false");
        return False;
    }
    
private:
    RTSPSubsession *subsession;
    MediaSubsession *fSubsession;
    uint8_t *buf;
    int bufLen;
    NSDate *receiveTime;
    
public:
    int channelId;
    RTSPReceiver *m_RTSPClient;
};

struct RTSPSubsessionContext {
    MediaSubsession *subsession;
    UsageEnvironment *env;
};

@implementation RTSPSubsession

@synthesize delegate;

- (id)initWithMediaSubsession:(MediaSubsession *)subsession environment:(UsageEnvironment *)env {
    if (self = [super init]) {
        context = new RTSPSubsessionContext;
        context->subsession = subsession;
        context->env = env;
    }
    
    return self;
}

- (void)dealloc {
    delete context;
}

- (NSString *)getSessionId {
    return [NSString stringWithCString:context->subsession->sessionId() encoding:NSUTF8StringEncoding];
}

- (NSString *)getMediumName {
    return [NSString stringWithCString:context->subsession->mediumName() encoding:NSUTF8StringEncoding];
}

- (NSString *)getProtocolName {
    return [NSString stringWithCString:context->subsession->protocolName() encoding:NSUTF8StringEncoding];
}

- (NSString *)getCodecName {
    return [NSString stringWithCString:context->subsession->codecName() encoding:NSUTF8StringEncoding];
}

- (NSUInteger)getAudioSmapleRate {
    return context->subsession->rtpTimestampFrequency();
}

- (NSUInteger)getAudioChannel {
    return context->subsession->numChannels();
}
- (NSUInteger)getServerPortNum {
    return context->subsession->serverPortNum;
}

- (NSUInteger)getClientPortNum {
    return context->subsession->clientPortNum();
}

- (int)getSocket {
    return context->subsession->rtpSource()->RTPgs()->socketNum();
}

- (NSString *)getSDP_spropparametersets {
    return [NSString stringWithCString:context->subsession->fmtp_spropparametersets() encoding:NSUTF8StringEncoding];
}

- (NSString *)getSDP_config {
    return [NSString stringWithCString:context->subsession->fmtp_config() encoding:NSUTF8StringEncoding];
}

- (NSUInteger)getSDP_VideoWidth {
    return context->subsession->videoWidth();
}

- (NSUInteger)getSDP_VideoHeight {
    return context->subsession->videoHeight();
}

- (void)increaseReceiveBufferTo:(NSUInteger)size {
    int recvSocket = context->subsession->rtpSource()->RTPgs()->socketNum();
    increaseReceiveBufferTo(*context->env, recvSocket, (unsigned)size);
}

- (void)setPacketReorderingThresholdTime:(NSUInteger)uSeconds {
    context->subsession->rtpSource()->setPacketReorderingThresholdTime((unsigned)uSeconds);
}

- (BOOL)timeIsSynchronized {
    return context->subsession->rtpSource()->hasBeenSynchronizedUsingRTCP();
}

- (NSInteger)getChanelID {
    return ((RTSPSubsessionMediaSink*)context->subsession)->channelId;
}

- (void)setDelegate:(id <RTSPSubsessionDelegate>)_delegate {
    delegate = _delegate;
}

- (MediaSubsession *)getMediaSubsession {
    return context->subsession;
}

- (int)getExtraData:(unsigned int *)i_extra extradata:(uint8_t **) p_extra {
    int iRtn = 0;
    
    if ((*p_extra = parseGeneralConfigStr(context->subsession->fmtp_config(), *i_extra))) {
        
    }
    return iRtn;
}

- (void)setReceiver:(RTSPReceiver *)_RTSPReceiver {
    m_RTSPReceiver = _RTSPReceiver;
}

- (void)setURL:(NSString *)_url {
    m_url = _url;
}

- (NSString *)getUrl {
    return m_url;
}

@end

struct RTSPClientSessionContext {
    TaskScheduler *scheduler;
    UsageEnvironment *env;
    RTSPClient *client;
    MediaSession *session;
};

@implementation RTSPClientSession
@synthesize url;
@synthesize delegate;
@synthesize m_blnUseTCP;

- (id)initWithURL:(NSURL *)_url delegate:(id)_delegate {
    delegate = _delegate;
    return [self initWithURL:_url username:nil password:nil];
}

- (id)initWithURL:(NSURL *)_url username:(NSString *)_username password:(NSString *)_password {
    self = [super init];
    if (self) {
        eventLoopWatchVariable = 0;
        url = _url;
        username = _username;
        password = _password;
        
        context = new RTSPClientSessionContext;
        
        memset(context, 0, sizeof(*context));
        
        SPSData = NULL;
        PPSData = NULL;
        
        m_aryH264StartCode[0] = 0X00;
        m_aryH264StartCode[1] = 0X00;
        m_aryH264StartCode[2] = 0X00;
        m_aryH264StartCode[3] = 0X01;
        
        context->scheduler = BasicTaskScheduler::createNew();
        
        if(!context->scheduler)
            return nil;
        
        context->env = BasicUsageEnvironment::createNew(*context->scheduler);
        
        if(!context->env)
            return nil;
        
        context->client = ((RTSPClient*)ourRTSPClient::createNew(*context->env, [[url absoluteString] UTF8String], RTSPCLIENT_VERBOSITY_LEVEL, "IRIPCamera"));
        ((ourRTSPClient*)context->client)->m_myClientSession = self;
        if(!context->client)
            return nil;
    }
    
    return self;
}

- (void)dealloc {
    if(context->client)
        Medium::close(context->client);
    context->env->reclaim();
    delete context->scheduler;
    delete context;
    
    url = nil;
    username = nil;
    password = nil;
    sdp = nil;
}

- (BOOL)setupWithTCP:(BOOL)_blnUseTCP {
    eventLoopWatchVariable = 0;
    m_blnDescribeDone = NO;
    m_blnSetupDone = NO;
    m_blnPlayDone = NO;
    
    self.m_blnUseTCP = _blnUseTCP;
    NSLog(@"url=%@", [url absoluteString]);

    ((ourRTSPClient*)context->client)->m_blnStop = False;
    NSLog(@"0. sendDescribeCommand");
    context->client->sendDescribeCommand(DESCRIBECallback);
    context->env->taskScheduler().doEventLoop(&eventLoopWatchVariable);
    Medium::close(context->client);
    context->client = nil;
    //        if(self.delegate)
    //            [self.delegate tearDownCallback];
    
    return YES;
}

- (BOOL)shutdownStream {
    ourRTSPClient *tmpClent = (ourRTSPClient *) context->client;
    [self shutdownStreamByRtspClient:tmpClent code:0];

    eventLoopWatchVariable = 1;
    NSLog(@"Do shutdown event");
    
    return YES;
}

- (NSArray *)getSubsessions {
    NSMutableArray *subsessions = [[NSMutableArray alloc] init];
    
    MediaSubsessionIterator iter(*context->session);
    while (MediaSubsession *subsession = iter.next()) {
        RTSPSubsession *newObj = [[RTSPSubsession alloc] initWithMediaSubsession:subsession environment:context->env];
        
        [subsessions addObject:newObj];
    }
    return subsessions;
}

- (NSString *)getLastErrorString {
    return [NSString stringWithCString:context->env->getResultMsg() encoding:NSUTF8StringEncoding];
}

- (NSString *)getSDP {
    return sdp;
}

- (NSData *)getBase64DecodeString:(NSString *)strEncoded {
    return [[NSData alloc] initWithBase64EncodedString:strEncoded options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (int)getSocket {
    return context->client->socketNum();
}

@end

@implementation RTSPClientSession(PrivateMethod)

- (void)DESCRIBECallback:(RTSPClient* )_rtspClient code:(int)_resultCode result:(char*)_resultString {
    NSLog(@"1. describe call back resuleCode=%d :%s",_resultCode ,_resultString);
    do {
        m_blnDescribeDone = YES;
        UsageEnvironment &env = _rtspClient->envir();
        StreamClientState &scs = ((ourRTSPClient *) _rtspClient)->scs;
        
        if(_resultCode != 0)
        {
            [((ourRTSPClient*) _rtspClient)->m_myClientSession.delegate rtspFailCallbackByErrorCode:_resultCode msg:[NSString stringWithFormat:@"%s",_resultString]];
            break;
        }
        
        char* const sdpDescription = _resultString;
        
        sdp = [[NSString alloc] initWithCString:_resultString encoding:NSUTF8StringEncoding];

        scs.session = MediaSession::createNew(env, sdpDescription);
        delete[] sdpDescription;
        
        if(scs.session == NULL)
        {
            break;
        }
        else if(!scs.session->hasSubsessions())
        {
            break;
        }
        
        scs.iter = new MediaSubsessionIterator(*scs.session);
        
        [self setupNextSubsession:_rtspClient];
    } while (0);
}

- (void)setupNextSubsession:(RTSPClient *)_rtspClient {
    StreamClientState &scs = ((ourRTSPClient *)_rtspClient)->scs;
    
    scs.subsession = scs.iter->next();
    
    if (scs.subsession != NULL) {
        if (!scs.subsession->initiate()) {
            [self setupNextSubsession:_rtspClient];
        } else {
            Boolean blnTCP = self.m_blnUseTCP ? True : False;
            NSLog(@"2. send setup command");
            _rtspClient->sendSetupCommand(*scs.subsession, SETUPCallbackByRtspClient, False, blnTCP, False);
        }
        return;
    }
    
    NSLog(@"4. send play command");
    _rtspClient->sendPlayCommand(*scs.session, PLAYCallbackByRtspClient);
}

- (void)SETUPCallbackByRtspClient:(RTSPClient *)_rtspClient code:(int)_resultCode result:(char *)_resultString {
    NSLog(@"3. setup callback");
    do {
        m_blnSetupDone = YES;
        UsageEnvironment &env = _rtspClient->envir();
        StreamClientState &scs = ((ourRTSPClient*)_rtspClient)->scs;
        RTSPClientSession *tmpClient =((ourRTSPClient*)_rtspClient)->m_myClientSession;
        
        if (_resultCode != 0) {
            [((ourRTSPClient*) _rtspClient)->m_myClientSession.delegate rtspFailCallbackByErrorCode:_resultCode msg:[NSString stringWithFormat:@"%s",_resultString]];
            break;
        }
        
        if (scs.subsession) {
            scs.subsession->sink = RTSPSubsessionMediaSink::createNew(env, *scs.subsession, _rtspClient->url());
            
            if(scs.subsession->sink == NULL)
                break;
            
            scs.subsession->miscPtr = _rtspClient;
            scs.subsession->sink->startPlaying(*(scs.subsession->readSource()), subsessionAfterPlaying, scs.subsession);
            NSString*tmpMedium = [NSString stringWithCString: scs.subsession->mediumName() encoding:NSUTF8StringEncoding];
            NSString*tmpCodec = [NSString stringWithCString: scs.subsession->codecName() encoding:NSUTF8StringEncoding];
            NSData *tmpExtra = nil;
            unsigned int i_extra = 0;
            uint8_t * p_extra;
            
            
            if ([tmpCodec isEqualToString:@"MP4V-ES"] || [tmpCodec isEqualToString:@"MPEG4-GENERIC"])
            {
                if((p_extra = parseGeneralConfigStr(scs.subsession->fmtp_config(), *(&i_extra))))
                {
                    tmpExtra = [[NSData alloc] initWithBytes:p_extra length:i_extra];
                }
            }
            
            if([tmpMedium isEqualToString:@"video"])
            {
                [tmpClient.delegate videoCallbackByCodec:tmpCodec extraData:tmpExtra];
            }
            else if([tmpMedium isEqualToString:@"audio"])
            {
                NSInteger iSampleRate = scs.subsession->rtpTimestampFrequency();
                NSInteger iChannel = scs.subsession->numChannels();
                [tmpClient.delegate audioCallbackByCodec:tmpCodec sampleRate:(int)iSampleRate ch:(int)iChannel extraData:tmpExtra];
            }
            
            if(scs.subsession->rtcpInstance() != NULL)
            {
                scs.subsession->rtcpInstance()->setByeHandler(subsessionByeHandler, scs.subsession);
            }
        }
    } while (0);
    
    setupNextSubsession(_rtspClient);
}

- (void)PLAYCallbackByRtspClient:(RTSPClient *)_rtspClient code:(int)_resultCode result:(char *) _resultString {
    NSLog(@"5. play call back");
    m_blnPlayDone = YES;
    do {
        if (_resultCode != 0) {
            [((ourRTSPClient*) _rtspClient)->m_myClientSession.delegate rtspFailCallbackByErrorCode:_resultCode msg:[NSString stringWithFormat:@"%s",_resultString]];
            
            break;
        }

        [((ourRTSPClient *) _rtspClient)->m_myClientSession.delegate startPlayCallback];
        
        return;
    } while (0);
    
    [self shutdownStreamByRtspClient:_rtspClient code:1];
}

- (void)TEARDOWNCallbackByRtspClient:(RTSPClient *)_rtspClient code:(int)_resoultCode result:(char *)_resultString {
    eventLoopWatchVariable = 1;
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~teardown finish");
    //    [self.delegate tearDownCallback];
}

- (void)subsessionAfterPlaying:(void *)_clientData {
    MediaSubsession *subsession = (MediaSubsession *)_clientData;
    ourRTSPClient *tmpClient = (ourRTSPClient*)(subsession->miscPtr);
    
    Medium::close(subsession->sink);
    subsession->sink = NULL;
    
    MediaSession &session = subsession->parentSession();
    MediaSubsessionIterator iter(session);
    
    while ((subsession = iter.next() ) != NULL)
    {
        if(subsession->sink != NULL)
            return;
    }
    
    [self shutdownStreamByRtspClient:(RTSPClient*)tmpClient code:1];
}

- (void)subsessionByeHandler:(void *)_clientData {
}

- (void)streamTimerHandler:(void *)_clientData {
}

- (void)shutdownStreamByRtspClient:(RTSPClient *)_rtspClient code:(int)_code {
    ourRTSPClient *tmpClent = (ourRTSPClient *) context->client;
    
    tmpClent->m_blnStop = True;
    StreamClientState &scs = tmpClent->scs;
    
    if (scs.session != NULL) {
        Boolean someSubsessionWereActive = False;
        MediaSubsessionIterator iter(*scs.session);
        MediaSubsession *subsession;
        
        while ((subsession = iter.next()) != NULL) {
            if (subsession->sink != NULL) {
                Medium::close(subsession->sink);
                subsession->sink = NULL;
                
                if (subsession->rtcpInstance() != NULL) {
                    subsession->rtcpInstance()->setByeHandler(NULL, NULL);
                }
                
                someSubsessionWereActive = True;
            }
        }
        
        if (someSubsessionWereActive) {
            tmpClent->sendTeardownCommand(*scs.session, TEARDOWNCallbackByRtspClient);
        }
    }
}

@end

