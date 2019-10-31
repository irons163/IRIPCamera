
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>



#define AQ_BUFFER_NUMBER	10
#define AQ_BUFFER_SIZE		128

//char *tmpfilename;

@protocol AudioInputDelegate

-(void) putAudio:(void*) _audioData length:(int) _length;

@end
@interface AudioInput : NSObject{

    __unsafe_unretained id<AudioInputDelegate> delegate;
	
	// AQ
	AudioStreamBasicDescription	audioDesc;
	AudioQueueRef				queue;
	AudioQueueBufferRef			aqbuf[AQ_BUFFER_NUMBER];
    
    NSFileHandle *myHandle;
    NSString* filenameStr;
}

@property (nonatomic ,assign) id<AudioInputDelegate> delegate;
@property (nonatomic ,retain) NSFileHandle *myHandle;
@property (nonatomic, retain) AVAudioSession *audioSession;

- (id)initWithSampleRate:(int)srate bps:(int)bps balign:(int)balign fsize:(int)fsize audioType:(NSString *) _audioType;
- (BOOL)start;
- (void)stop;

@end
