//
//  AudioPlayer.h
//  IRIPCamera
//
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

#define AQ_BUFFER_NUMBER	2    //too large : will dealy too long time;too small : will have some unknow noise
#define AQ_BUFFER_SIZE		4096

@interface AudioPlayer : NSObject {
    // player
    AudioStreamBasicDescription		audioDesc;
    AudioQueueRef					m_AudioQueue;
    AudioQueueBufferRef				m_AudioBuffer[AQ_BUFFER_NUMBER];
    
    NSMutableArray *m_AudioData;
    Byte *m_emptyData;
}

// codec
- (id)initWithSampleRate:(int) _sampleRate;
- (void)playAudio:(float *)pInAudio length:(int)length;
- (BOOL)start;
- (void)stop;

// player
- (void)mute;
- (void)play;

@end
