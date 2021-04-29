//
//  AudioDecoder.m
//  live555Client
//
//  Created by sniApp on 12/9/24.
//  Copyright (c) 2012年 sniApp. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "AudioDecoder.h"
#import "errorCodeDefine.h"
#import <Accelerate/Accelerate.h>

#define INBUF_SIZE 4096
#define AUDIO_INBUF_SIZE 20480
#define AUDIO_REFILL_THRESH 4096
#define AVCODEC_MAX_AUDIO_FRAME_SIZE 192000 // 1 second of 48khz 32bit audio

@interface AudioDecoder (PrivateMethod)

- (NSUInteger)getCodecWithCodecString:(NSString *)strCodec;

@end

@implementation AudioDecoder
@synthesize m_channelNO;
@synthesize delegate;

- (id)initAudioDecode {
    m_blnStopDecode = NO;
    return self;
}

- (NSUInteger)setCodecWithCodecString:(NSString *)strCodec {
    NSUInteger iRtn = 0;
    AVCodec *codec = NULL;
    
    NSUInteger iCodec = 0;
    iCodec = [self getCodecWithCodecString:strCodec];
    
    do {
        if (iCodec == 0) {
            iRtn = FIND_AUDIOCODEC_BYSTRING_FAIL;
            break;
        }
        
        avcodec_register_all();
        NSInteger iCount = 0;
        
        do {
            iCount++;
            codec = avcodec_find_decoder(iCodec);
            
            if(iCount == 5)
                break;
            
        } while (codec == NULL);
        
        if (!codec) {
            iRtn = FIND_AUDIO_CODEC_FAIL;
            break;
        }
        
        context = avcodec_alloc_context3(codec);
        
        if (context == NULL) {
            iRtn = ALLOC_AUDIO_AVCONTEXT_FAIL;
            break;
        }
        
        context->codec_type = AVMEDIA_TYPE_AUDIO;
        context->sample_rate = 12000;
        context->channels = 2;
        
        if (avcodec_open2(context, codec, NULL) < 0 ) {
            iRtn = OPEN_AUDIO_AVCODEC_FAIL;
            break;
        }
        
        //Fix AAC issue 160115
        if (context->channel_layout!=0) {
            pSwrCtx = swr_alloc_set_opts(NULL,  // we're allocating a new context
                                         AV_CH_LAYOUT_MONO,  // out_ch_layout
                                         AV_SAMPLE_FMT_S16,    // out_sample_fmt
                                         12000,                // out_sample_rate
                                         AV_CH_LAYOUT_STEREO, // in_ch_layout
                                         AV_SAMPLE_FMT_FLTP,   // in_sample_fmt
                                         12000,                // in_sample_rate
                                         0,                    // log_offset
                                         NULL);                // log_ctx
        } else {
            pSwrCtx = swr_alloc_set_opts(pSwrCtx,
                                         context->channels+1,
                                         AV_SAMPLE_FMT_S16,
                                         context->sample_rate,
                                         context->channels+1,
                                         context->sample_fmt,
                                         context->sample_rate,
                                         0,
                                         0);
        }
        
        if (swr_init(pSwrCtx)<0) {
            NSLog(@"swr_init() for AV_SAMPLE_FMT_FLTP fail");
            iRtn = SWR_INIT_FAIL;
            break;
        }
        
    } while (0);
    
    return iRtn;
}

- (void)setAudioDecodeSampleRate:(NSInteger)sampleRate channels:(NSInteger)channels {
    if(sampleRate > 48000)
        sampleRate = 48000;
    
    m_Channels = channels;
    m_SampleRate = sampleRate;
    
    if (context) {
        context->sample_rate = m_SampleRate;
        context->channels = channels;
    }
    
    if (!mPlayer) {
        mPlayer = [[AudioPlayer alloc] initWithSampleRate:m_SampleRate];
        [mPlayer start];
    }
}

- (void)setExtraData:(NSInteger)_iLen extraData:(uint8_t *)_extradata {
    if (context && _extradata && (_iLen > 0)) {
        context->extradata_size = _iLen;
        context->extradata = (uint8_t *)malloc(_iLen + AV_INPUT_BUFFER_PADDING_SIZE);
        
        if (context->extradata) {
            memcpy(context->extradata, _extradata, _iLen);
            memset(&((uint8_t*)context->extradata)[_iLen], 0, AV_INPUT_BUFFER_PADDING_SIZE);
        }
    }
}

- (void)decodeAudioFromSource:(const uint8_t *)audioData length:(int)length {
    if (m_blnStopDecode) {
        return;
    }
    
    AVFrame *decoded_frame = av_frame_alloc();
    
    AVPacket avpkt;
    
    av_init_packet(&avpkt);
    
    avpkt.data = malloc(length);
    memcpy(avpkt.data, audioData, length);
    avpkt.size = length;
    
    if (avpkt.data == NULL) return;
    
    int result = avcodec_send_packet(context, &avpkt);
    
    if (result < 0 && result != AVERROR(EAGAIN) && result != AVERROR_EOF) {
        return;
    }
    
    while (result >= 0) {
        result = avcodec_receive_frame(context, decoded_frame);
        
        if (result < 0) {
            if (result != AVERROR(EAGAIN) && result != AVERROR_EOF) {
                return;
            }
            break;
        }
        
        @autoreleasepool {
            const NSUInteger sizeOfS16 = 2;
            const int numChannels = 1;
            int ratio = MAX(1, 12000 / context->sample_rate) * MAX(1, numChannels / context->channels) * 2;
            const int bufSize = av_samples_get_buffer_size(NULL,
                                                           numChannels,
                                                           decoded_frame->nb_samples * ratio,
                                                           AV_SAMPLE_FMT_S16,
                                                           1);
            
            int numFrames = bufSize / (sizeOfS16 * numChannels);
            
            SInt16 *s16p = (SInt16 *) decoded_frame->data[0];
            
            int _swrBufferSize = 0;
            void * _swrBuffer = NULL;
            
            if (pSwrCtx) {
                if (!_swrBuffer || _swrBufferSize < (bufSize * 2)) {
                    _swrBufferSize = bufSize * 2;
                    _swrBuffer = realloc(_swrBuffer, _swrBufferSize);
                }
                
                Byte *outbuf[2] = {_swrBuffer, 0};
                
                numFrames = swr_convert(pSwrCtx,
                                        outbuf,
                                        decoded_frame->nb_samples * 2,
                                        (const uint8_t **) decoded_frame->data,
                                        decoded_frame->nb_samples);
                
                if (numFrames < 0) {
                    NSLog(@"fail resample audio");
                    continue;
                }
                
                s16p = _swrBuffer;
            }
            
            const NSUInteger numElements = numFrames * numChannels;
            
            NSUInteger data_size = numElements * sizeof(float);
            float* tmpData = (float*)malloc(data_size);
            
            vDSP_vflt16(s16p, 1, tmpData, 1, numElements);
            float scale = 1.0 / (float) INT16_MAX;
            vDSP_vsmul(tmpData, 1, &scale, tmpData, 1, numElements);
            [mPlayer playAudio:tmpData length:data_size];
            
            if (tmpData != NULL) {
                free(tmpData);
                tmpData = NULL;
            }
        }
    }
    
    av_packet_unref(&avpkt);
    
    if (decoded_frame)
        av_frame_free(&decoded_frame);
    
    av_packet_unref(&avpkt);
}

- (void)stopDecode {
    m_blnStopDecode = YES;
    [mPlayer stop];
}

- (void)startDecode {
    m_blnStopDecode = NO;
    [mPlayer start];
}

- (void)dealloc {
    if (context) {
        avcodec_free_context(&context);
        context = NULL;
    }
    
    //Fix AAC issue 160115
    if (pSwrCtx)
        swr_free(&pSwrCtx);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation AudioDecoder (PrivateMethod)

- (NSUInteger)getCodecWithCodecString:(NSString *)strCodec {
    NSUInteger iRtn = 0;
    strCodec = [strCodec uppercaseString];
    
    if ([strCodec isEqualToString:@"MPA"]) {
        iRtn = AV_CODEC_ID_MP3;
    } else if ([strCodec isEqualToString:@"L16"]) {
        iRtn = AV_CODEC_ID_PCM_S16BE;
    } else if ([strCodec isEqualToString:@"MPEG4-GENERIC"]) {
        iRtn = AV_CODEC_ID_AAC;
    } else if ([strCodec isEqualToString:@"PCMU"]) {
        iRtn = AV_CODEC_ID_PCM_MULAW;
    } else if ([strCodec isEqualToString:@"L8"]) {
        iRtn = AV_CODEC_ID_PCM_MULAW;
    } else if ([strCodec isEqualToString:@"PCMA"]) {
        iRtn = AV_CODEC_ID_PCM_ALAW;
    } else {
        iRtn = AV_CODEC_ID_PCM_ALAW;
    }
    
    return iRtn;
}

@end
