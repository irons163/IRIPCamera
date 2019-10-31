//
//  AudioOutput.m
//  MobileFocus
//
//  Created by Nobel on 2011/3/4.
//  Copyright 2011 EverFocus. All rights reserved.
//

#import "AudioOutput.h"
//#import "libkern/OSAtomic.h"

static void CASoundAQOutputCallback(
									void *                  inUserData,
									AudioQueueRef           inAQ,
									AudioQueueBufferRef     inBuffer);

@interface AudioOutput (private)
// buffer
- (void)writeData:(int)writeNumBytes buffer:(void *)buffer;
- (int)readData:(int)needNumBytes buffer:(void *)buffer; // return actural output

// player
- (BOOL)prepareForPlay;
- (void)queue: (AudioQueueRef)inAQ buffer: (AudioQueueBufferRef)inBuffer;

@end

@implementation AudioOutput

@synthesize codecId;
@synthesize m_AudioData;


- (id)initWithCodecId:(int)cid srate:(int)srate bps:(int)bps balign:(int)balign fsize:(int)fsize {
	
	if (!(self=[super init])) return nil;
    
    // buffer for AQ
	lpcmBufSize = srate*2*3; // 3sec
	dalayLength = srate; // 0.5sec
	dataBuffer	= malloc(lpcmBufSize);
	memset(dataBuffer, 0, lpcmBufSize);
	readPos		= dataBuffer;
	writePos	= dataBuffer+dalayLength;
	readFlag	= 0;
	writeFlag	= 0;
	
	// player
	audioDesc.mSampleRate		= srate;//+20;
	audioDesc.mFormatID			= kAudioFormatLinearPCM;
	audioDesc.mFormatFlags		= kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
	audioDesc.mBytesPerPacket	= 2;
	audioDesc.mFramesPerPacket	= 1;
	audioDesc.mBytesPerFrame	= 2;
	audioDesc.mChannelsPerFrame	= 1;
	audioDesc.mBitsPerChannel	= 16;
	audioDesc.mReserved			= 0;

	queue = nil;

	
	isDecoding = NO;
	isStop = YES;
	m_AudioData = [[NSMutableArray alloc] init];
	return self;
}


- (BOOL) start {

    OSStatus error = 0;
	if (queue!=nil)
        return YES;
		
	// create audio queue
	if ([self prepareForPlay]) {

		AudioQueueSetParameter(queue, kAudioQueueParam_Volume, 1.0f);
		 error = AudioQueueStart(queue, NULL);
		if (error)
		{
			NSLog(@"AudioQueueStart: OS error %li\n", error);
			
			[self stop];
			return NO;
		}
		
		isStop = NO;
		
		NSLog(@"Audio output start.");
		return YES;
	}
	else {
		[self stop];
		return NO;
	}
}
- (void)playAudio:(Byte *)pInAudio length:(int)length {
    
//    NSData *tmpAudio = [[NSData alloc] initWithBytes:pInAudio length:length];
//    [m_AudioData addObject:[tmpAudio retain]];
//    [tmpAudio release];
//    NSLog(@"%d audio frames",[m_AudioData count]);
    [self writeData:length buffer:pInAudio];
}

- (void)stop {
	
	if (queue==nil) return;
		
	isStop = YES;
	
	AudioQueueStop(queue, true);
	
	// dispose audio queue
	AudioQueueDispose(queue, true);
	queue = nil;
	[m_AudioData removeAllObjects];
	while ( isDecoding ) {
		
		[NSThread sleepForTimeInterval:0.001];
	}
	
	NSLog(@"Audio output stop.");
}

- (void)dealloc {
	
	[self stop];
	
    m_AudioData = nil;
	
}

- (BOOL)prepareForPlay
{
	OSStatus error;
	
	// create a new audio queue output
	error = AudioQueueNewOutput(&audioDesc, CASoundAQOutputCallback, (__bridge void *)(self), NULL, NULL, 0, &queue);
	if (error)
	{
		NSLog(@"AudioQueueNewOutput: OS error %li\n", error);
		return NO;
	}
	
	for (UInt32 i = 0; i < AQ_BUFFER_NUMBER; ++i) {
		
		error = AudioQueueAllocateBuffer(queue, AQ_BUFFER_SIZE, aqbuf+i);
		if (error)
		{
			NSLog(@"AudioQueueAllocateBuffer: OS error %li\n", error);
			return NO;
		}
		
		CASoundAQOutputCallback((__bridge void *)(self), queue, aqbuf[i]);
	}
	
	return YES;
}

- (void)queue: (AudioQueueRef)inAQ buffer: (AudioQueueBufferRef)inBuffer
{	
	//if (isStop) return;
	
//	UInt32 bytesToFill = inBuffer->mAudioDataBytesCapacity;
//	UInt8* fillPtr = (UInt8*)inBuffer->mAudioData;
//    
//    if([m_AudioData count] >0)
//    {
//        NSData *tmpAudio = [m_AudioData objectAtIndex:0];
//
//        memcpy(fillPtr, (void*)[tmpAudio bytes], [tmpAudio length]);
//        inBuffer->mAudioDataByteSize = [tmpAudio length];
//        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
//        [m_AudioData removeObjectAtIndex:0];
//    }
//    else
//    {
//        NSLog(@"bytesToFill empty=%d",(unsigned int)bytesToFill);    
//        Byte* tmp = (Byte*)malloc(bytesToFill);
//        memset(tmp, 0, bytesToFill);
//        NSData *tmpEmpty = [[NSData alloc] initWithBytes:tmp length:bytesToFill];
//        [m_AudioData addObject:[tmpEmpty retain]];
//        [tmpEmpty release];
//    }
    
    UInt32 bytesToFill = inBuffer->mAudioDataBytesCapacity;
	UInt8* fillPtr = (UInt8*)inBuffer->mAudioData;
	UInt32 bytesFilled = 0;
	
	// get a data from array
	bytesFilled = [self readData:bytesToFill buffer:fillPtr];
	
	inBuffer->mAudioDataByteSize = bytesFilled;
	
	//if (bytesFilled) {
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
	//}
}

- (void)writeData:(int)writeNumBytes buffer:(void *)buffer {
	
	int bytesToFill = writeNumBytes;
	void* fillPtr = buffer;
	int bytesFilled = 0;
	
	while (true) {
		
		int ioNumBytes = 0;
		int bufRemnantSize = dataBuffer+lpcmBufSize-writePos;
		
		if(bytesToFill<bufRemnantSize) {
			ioNumBytes = bytesToFill;
		}
		else {
			ioNumBytes = bufRemnantSize;
		}
        
		memcpy(writePos, fillPtr, ioNumBytes);
		
		writePos += ioNumBytes;
		
		if (writePos>=(dataBuffer+lpcmBufSize)) {
            
			writePos = dataBuffer;
			writeFlag++;
			//NSLog(@"=========================write flag=%d",writeFlag);
		}
		
		if (writeFlag>readFlag && writePos>=readPos) {
			
			readFlag = writeFlag;
			readPos = ((writePos-dalayLength)<dataBuffer)?dataBuffer:(writePos-dalayLength);
			NSLog(@"Skip audio for 1 buffer length");
		}
		
		fillPtr += ioNumBytes;
		bytesFilled += ioNumBytes;
		bytesToFill -= ioNumBytes;
		
		if (bytesToFill == 0) {
			break;
		}
	}
}

- (int)readData:(int)needNumBytes buffer:(void *)buffer {
	
	int bytesToFill = needNumBytes;
	void* fillPtr = buffer;
	int bytesFilled = 0;
	
	while (true) {
		
		int ioNumBytes = 0;
		int bufAvailanleSize = 0;
		
		if(writeFlag>readFlag) {
			bufAvailanleSize = dataBuffer+lpcmBufSize-readPos;
		}
		else if (writePos>readPos) {
			bufAvailanleSize = writePos-readPos;
		}
		
		if (bufAvailanleSize>=bytesToFill) {
			ioNumBytes = bytesToFill;
		}
		else {
			ioNumBytes = bufAvailanleSize;
		}
        
		
		if (ioNumBytes) {
            
			memcpy(fillPtr, readPos, ioNumBytes);
			
			readPos += ioNumBytes;
			if (readPos>=(dataBuffer+lpcmBufSize)) {
				
				readPos = dataBuffer;
				readFlag++;
				//NSLog(@"=========================read flag=%d",readFlag);
			}
			
			fillPtr += ioNumBytes;
			bytesFilled += ioNumBytes;
			bytesToFill -= ioNumBytes;
			
			if (bytesToFill == 0) {
				break;
			}
		}
		else {
			if (isStop) {
				break;
			}
			else {
				// no data to read, fill null data to buffer
//				NSLog(@"Audio buffering...");
				void* tmp = malloc(dalayLength);
				memset(tmp, 0, dalayLength);
				[self writeData:dalayLength buffer:tmp];
				free(tmp);
			}
		}
	}
	
	return bytesFilled;
}

- (void)mute {
	AudioQueueSetParameter(queue, kAudioQueueParam_Volume, 0.0f);
}


- (void)play {
	AudioQueueSetParameter(queue, kAudioQueueParam_Volume, 1.0f);
}
@end

static void CASoundAQOutputCallback(
									void *                  inUserData,
									AudioQueueRef           inAQ,
									AudioQueueBufferRef     inBuffer)
{
	//NSLog(@"callback: %x", inBuffer);
	AudioOutput* sound = (__bridge AudioOutput*)inUserData;
	[sound queue:inAQ buffer:inBuffer];
//    UInt32 bytesToFill = inBuffer->mAudioDataBytesCapacity;
//	UInt8* fillPtr = (UInt8*)inBuffer->mAudioData;
//    
//    if([sound.m_AudioData count] > 0)
//    {
//        NSData *tmpAudio = [sound.m_AudioData objectAtIndex:0];
//        
//        memcpy(fillPtr, (void*)[tmpAudio bytes], [tmpAudio length]);
//        inBuffer->mAudioDataByteSize = [tmpAudio length];
//        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
//        [sound.m_AudioData removeObjectAtIndex:0];
//    }
//    else
//    {
//        NSLog(@"bytesToFill empty=%d",(unsigned int)bytesToFill);
//        Byte* tmp = (Byte*)malloc(bytesToFill);
//        memset(tmp, 0, bytesToFill);
//        memcpy(fillPtr, (void*)tmp, bytesToFill);
//        inBuffer->mAudioDataByteSize = bytesToFill;
//        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
//    }

}
