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
#define INBUF_SIZE 4096
#define AUDIO_INBUF_SIZE 20480
#define AUDIO_REFILL_THRESH 4096
#define AVCODEC_MAX_AUDIO_FRAME_SIZE 192000 // 1 second of 48khz 32bit audio
//char *tmpfilename;
@interface AudioDecoder(PrivateMethod)
-(NSUInteger) getCodecWithCodecString:(NSString*) strCodec;

@end

@implementation AudioDecoder
@synthesize m_channelNO;
@synthesize delegate;

-(id)initAudioDecode
{
//    mySound = [[Sound alloc] init];
//    [mySound initOpenAL];


//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask, YES);
//    NSString* documentsDirectory = [paths objectAtIndex:0];
//    NSString* leafname = [@"decoded" stringByAppendingFormat: @".dat" ];
//    filenameStr = [NSString stringWithFormat:@"%@",[documentsDirectory
//                                                    stringByAppendingPathComponent:leafname]];
//    tmpfilename = (char *)malloc([filenameStr length]-1);
//    memcpy(tmpfilename, [filenameStr UTF8String], [filenameStr length]-1);
////    filenameStr = ;
//
//    [[NSFileManager defaultManager] createFileAtPath:filenameStr contents:nil attributes:nil];


//    NSLog(@"filePath=%@",filenameStr);
//    myHandle = [NSFileHandle fileHandleForWritingAtPath:filenameStr];
//    [myHandle seekToEndOfFile];
//    mPlayer =  [[AudioOutput alloc] initWithCodecId:0 srate:8000 bps:0 balign:0 fsize:0];

    m_blnStopDecode = NO;
    return self;
}

-(NSUInteger) setCodecWithCodecString:(NSString*) strCodec
{
    NSUInteger iRtn = 0;
    AVCodec *codec = NULL;

    NSUInteger iCodec = 0;
    iCodec = [self getCodecWithCodecString:strCodec];
    
    do {
        if(iCodec == 0)
        {
            iRtn = FIND_AUDIOCODEC_BYSTRING_FAIL;
            break;
        }
        
        avcodec_register_all();
        NSInteger iCount = 0;
        do {
            iCount++;
            //        codec = avcodec_find_decoder(CODEC_ID_PCM_S16BE);
            codec = avcodec_find_decoder(iCodec);
            
            if(iCount == 5)
                break;
            
        } while (codec == NULL);
        
        if(!codec)
        {
            iRtn = FIND_AUDIO_CODEC_FAIL;
            break;
        }
        
        context = avcodec_alloc_context3(codec);
        
        if(context == NULL)
        {
            iRtn = ALLOC_AUDIO_AVCONTEXT_FAIL;
            break;
        }
        
        context->codec_type = AVMEDIA_TYPE_AUDIO;
        context->sample_rate = 8000;
        context->channels = 1;
        

//        context->bits_per_coded_sample = 16;
        
        if(iCodec == AV_CODEC_ID_AAC)
        {
            //context->profile = FF_PROFILE_AAC_LTP;
        }
        
        if(avcodec_open2(context, codec, NULL) < 0 )
        {
            iRtn = OPEN_AUDIO_AVCODEC_FAIL;
            break;
        }
        
        //Fix AAC issue 160115
        if(context->channel_layout!=0)
        {
            pSwrCtx = swr_alloc_set_opts(pSwrCtx,
                                         context->channel_layout,
                                         AV_SAMPLE_FMT_S16,
                                         context->sample_rate,
                                         context->channel_layout,
                                         context->sample_fmt,
                                         context->sample_rate,
                                         0,
                                         0);
        }
        else
        {
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
        
        if(swr_init(pSwrCtx)<0)
        {
            NSLog(@"swr_init() for AV_SAMPLE_FMT_FLTP fail");
            iRtn = SWR_INIT_FAIL;
            break;
        }
        
    } while (0);
    
    
    return iRtn;
}


-(void) setAudioDecodeSampleRate:(NSInteger)sampleRate channels:(NSInteger)channels
{
    if(sampleRate > 48000)
        sampleRate = 48000;
    m_Channels = channels;
    m_SampleRate = sampleRate;
    
    if(context)
    {
        context->sample_rate = m_SampleRate;
        context->channels = channels;
    }

    // because if audio sample is 16k but use 16k to render will cause error,it should be fw issue
    // ios & web cms need use 8K to render until fw fix the issue
//    sampleRate = 8000;
    
//        NSLog(@"audio channel no=%d",m_channelNO);
//    [mySound setM_Chanel:m_channelNO];
//    [mySound setPlaySoundInfoWithSampleRate:sampleRate channels:channels];
    
    if(!mPlayer)
    {
        mPlayer = [[AudioPlayer alloc] initWithSampleRate:m_SampleRate];
//        mPlayer = [[AudioOutput alloc] initWithCodecId:0 srate:m_SampleRate bps:0 balign:0 fsize:0];
       [mPlayer start];
    }
}

-(void) setExtraData:(NSInteger) _iLen extraData:(uint8_t *) _extradata
{
    if(context && _extradata && (_iLen > 0))
    {
//        NSLog(@"%d %s",_iLen ,_extradata);
        context->extradata_size = _iLen;
        context->extradata = (uint8_t *)malloc(_iLen + AV_INPUT_BUFFER_PADDING_SIZE);
        
        if(context->extradata)
        {
            memcpy(context->extradata, _extradata, _iLen);
            memset(&((uint8_t*)context->extradata)[_iLen], 0, AV_INPUT_BUFFER_PADDING_SIZE);
        }
    }
}

-(void) decodeAudioFromSource:(const uint8_t *)audioData length:(int)length
{
    int len = 0;
    
    if (m_blnStopDecode) {
        return;
    }
    else
    {
//        if(!mySound)
//        {
//            mySound = [[Sound alloc] init];
//            [mySound initOpenAL];
//            
////            [mySound setPlaySoundInfoWithSampleRate:m_SampleRate channels:m_Channels];
//            [mySound setPlaySoundInfoWithSampleRate:8000 channels:m_Channels];
//        }
    }
    AVFrame *decoded_frame = av_frame_alloc();
    
    AVPacket avpkt;
    
    av_init_packet(&avpkt);

    avpkt.data = malloc(length);
    memcpy(avpkt.data, audioData, length);
    avpkt.size = length;
    
    context->block_align = length;
    context->frame_size = length;
    
    
//    NSData *tmpdata = [NSData dataWithBytes:audioData length:length];
//    [myHandle seekToEndOfFile];
//    [myHandle writeData:tmpdata];

    int i_got_frame = AVCODEC_MAX_AUDIO_FRAME_SIZE;
    
    if (pSwrCtx)
    {
        len = avcodec_decode_audio4(context, decoded_frame, &i_got_frame, &avpkt);
        if(i_got_frame && len >= 0)
        {
            
//            NSLog(@"bits_per_coded_sample=%d ,sample_rate=%d",context->bits_per_coded_sample ,context->sample_rate);
//            NSLog(@"decode siez=%d",i_got_frame);
            if(i_got_frame > 0)
            {
                int outCount=0;
                int data_size = av_samples_get_buffer_size(decoded_frame->linesize, context->channels,
                                                           decoded_frame->nb_samples,AV_SAMPLE_FMT_S16, 0);
                Byte* tmpData = (Byte*)malloc(data_size);
                
                uint8_t pTemp[data_size];
                uint8_t *pOut = (uint8_t *)&pTemp;
                int in_samples = decoded_frame->nb_samples;
                outCount = swr_convert(pSwrCtx,
                                       (uint8_t **)(&pOut),
                                       in_samples,
                                       (const uint8_t **)decoded_frame->extended_data,
                                       in_samples);
                memcpy(tmpData, pOut, data_size);
                
                
                
                
                if(mPlayer){
                    [mPlayer playAudio:tmpData length:data_size];
                }
                
                if(tmpData != NULL)
                {
                    free(tmpData);
                    tmpData = NULL;
                }
            }
        }
    }
    else{
        int16_t result[AVCODEC_MAX_AUDIO_FRAME_SIZE] = {0};
        if(context->codec)
            len = avcodec_decode_audio4(context, result, &i_got_frame, &avpkt);
        
        if(i_got_frame && len >= 0)
        {
            if(i_got_frame > 0)
            {
                Byte* tmpData = (Byte*)malloc(i_got_frame);
                memcpy(tmpData, result, i_got_frame);
                //            if(mySound)
                //                [mySound openAudioFromQueue:(unsigned char*)result dataSize:i_got_frame];
                if(mPlayer){
                    [mPlayer playAudio:tmpData length:i_got_frame];
                }
                
                //            [delegate playAudio:(unsigned char*)tmpData dataSize:i_got_frame];
                
                if(tmpData != NULL)
                {
                    free(tmpData);
                    tmpData = NULL;
                }
            }
        }
    }
    
/*

//    int i_got_frame = AVCODEC_MAX_AUDIO_FRAME_SIZE;
//    int16_t decoded_Data[192000];
//    len = avcodec_decode_audio3(context, (int16_t *)decoded_Data, &i_got_frame, &avpkt);
//    [mySound openAudioFromQueue:(unsigned char*)decoded_Data dataSize:i_got_frame];
//    NSLog(@"%d ,%d",i_got_frame ,len);
    

//    [mySound openAudioFromQueue:(unsigned char*)decoded_Data dataSize:i_got_frame];
//
//    if(decoded_Data != NULL)
//    {
//        free(decoded_Data);
//        decoded_Data = NULL;
//    }
//   decoded_frame->data
//    NSData *tmpdata = [NSData dataWithBytes:decoded_frame->data length:length*2];
//    [myHandle seekToEndOfFile];
//    [myHandle writeData:tmpdata];
//
//    if(len != 0 )
//    {
//        alBufferi(outputBuffer, AL_FREQUENCY, 44100);
//        alBufferi(outputBuffer, AL_CHANNELS, 2);
//        alBufferi(outputBuffer, AL_SIZE, length*2);
//        alBufferi(outputBuffer, AL_BITS, 16);
//        alBufferData(outputBuffer, AL_FORMAT_STEREO16, decoded_frame->data, length*2, 44100);
////        NSLog(@"Decode frame out size = %d",len);
//        alSourcei(outputSource, AL_BUFFER, outputBuffer);
//        alSourcePlay(outputSource);
//        
//    }
//    
//
//
//    av_free(decoded_frame);
//    av_free(context);
    
*/
    if (decoded_frame)
//        avcodec_free_frame(&decoded_frame);
        av_frame_free(&decoded_frame);
//    av_free_packet(&avpkt);
    av_packet_unref(&avpkt);
}

-(void) stopDecode
{
    m_blnStopDecode = YES;
//    [mySound stopSound];
    [mPlayer stop];
//    [mPlayer mute];
}

-(void) startDecode
{
    m_blnStopDecode = NO;
//    [mySound playSound];
    [mPlayer start];
}

-(void) dealloc
{
    [mySound stopSound];
    [mySound cleanUpOpenAL];
    if (context) {
        avcodec_free_context(&context);
        context = NULL;
    }
    
    //Fix AAC issue 160115
    if (pSwrCtx)
        swr_free(&pSwrCtx);
    
//    [mySound release];
//    mySound = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end


@implementation AudioDecoder(PrivateMethod)

-(NSUInteger) getCodecWithCodecString:(NSString*) strCodec
{
    NSUInteger iRtn = 0;
    strCodec = [strCodec uppercaseString];
    
    if([strCodec isEqualToString:@"MPA"])
    {
//        iRtn = AV_CODEC_ID_MP3;
        iRtn = AV_CODEC_ID_MP3;
    }
    else if ([strCodec isEqualToString:@"L16"])
    {
//        iRtn = AV_CODEC_ID_PCM_S16BE;
        iRtn = AV_CODEC_ID_PCM_S16BE;
    }
    else if ([strCodec isEqualToString:@"MPEG4-GENERIC"])
    {
//        iRtn = AV_CODEC_ID_AAC;
        iRtn = AV_CODEC_ID_AAC;
    }
    else if ([strCodec isEqualToString:@"PCMU"])
    {
//        iRtn = AV_CODEC_ID_PCM_MULAW;
        iRtn = AV_CODEC_ID_PCM_MULAW;
    }
    else if ([strCodec isEqualToString:@"L8"])
    {
//        iRtn = AV_CODEC_ID_PCM_MULAW;
        iRtn = AV_CODEC_ID_PCM_MULAW;
    }
    else if ([strCodec isEqualToString:@"PCMA"])
    {
        //        iRtn = AV_CODEC_ID_PCM_MULAW;
        iRtn = AV_CODEC_ID_PCM_ALAW;
    }
    else
    {
        iRtn = AV_CODEC_ID_PCM_ALAW;
//        iRtn = CODEC_ID_PCM_ALAW;
    }
//    AV_CODEC_ID_PCM_MULAW
//    AV_CODEC_ID_PCM_ALAW
    return iRtn;
}



@end
