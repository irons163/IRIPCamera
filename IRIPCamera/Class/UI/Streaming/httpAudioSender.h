//
//  httpAudioSender.h
//  inputStreamAudio
//
//  Created by sniApp on 13/6/10.
//  Copyright (c) 2013年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioInput.h"

#define FAIL_TWO_WAY_AUDIO_OFF      0x00001
#define FAIL_TWO_WAY_AUDIO_USED     0x00010
#define FAIL_TO_OPEN_SERVER         0x00100
#define FAIL_HOST_ADDRESS_INVALID   0x01000
#define FAIL_USERNAME_PASSWORD      0x10000

@protocol AudioSenderDelegate

-(void) twoWayAudioFailedEvnent:(NSInteger) _type;

@end

@interface httpAudioSender : NSObject<NSStreamDelegate ,AudioInputDelegate>
{
    NSInputStream *iStream;
    NSOutputStream *oStream;
    AudioInput *m_audioGetter;
    
    NSMutableData *m_AudioData;
    BOOL m_blnLogin;
    id <AudioSenderDelegate> delegate;
    
@private
    NSString    *m_strHost;
    NSInteger   m_hostPort;
    NSString    *m_userName;
    NSString    *m_password;
    BOOL        m_blnStopAudio;
    NSString    *m_strCGIPath;
    NSString    *m_strURL;
}

@property (nonatomic ,retain) NSInputStream *iStream;
@property (nonatomic ,retain) NSOutputStream *oStream;
@property (nonatomic ,retain) AudioInput *m_audioGetter;
@property (nonatomic ,retain) NSMutableData *m_AudioData;
@property (nonatomic ,retain) NSString    *m_strHost;
@property (nonatomic ,retain) NSString    *m_userName;
@property (nonatomic ,retain) NSString    *m_password;
@property (nonatomic ,retain) NSString    *m_strCGIPath;
@property (nonatomic )        NSInteger   m_hostPort;
@property                     BOOL m_blnLogin;
@property (nonatomic ,retain) id<AudioSenderDelegate> delegate;
@property (nonatomic ,retain) NSString    *m_strURL;


-(id) initWithHost:(NSString *) _hostAddr port:(NSInteger) _hostPort user:(NSString *) _userName password:(NSString *) _pwd delegage:(id) _delegate;
-(id) initWithURL:(NSString*) _url user:(NSString *) _userName password:(NSString*) _pwd  delegage:(id) _delegate;
-(void) setPostCGIPath:(NSString *) _cgiPath sampleRate:(NSInteger) _sampleRate bitsPerSample:(NSInteger) _bitsPerSample audioType:(NSString*) _audioType;

-(void) twoWayAudiostart:(BOOL)_blnToDevice;
-(void) twoWayAudiostop:(BOOL)_blnToDevice;

@end
