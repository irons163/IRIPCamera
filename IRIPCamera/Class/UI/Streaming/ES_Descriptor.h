//
//  Header.h
//  recording
//
//  Created by sniApp on 13/8/13.
//  Copyright (c) 2013年 sniApp. All rights reserved.
//


#ifndef recording_Header_h
#define recording_Header_h

static inline int getESDSElementSize(int _size)
{
    int iRtn = 0;
    
    int i = 3;
    
    for( ; i > 0 ; i--)
    {
        iRtn |= (((_size>> 7*i) | 0x80)) << 8*(i);
    }
    iRtn |= _size & 0X7F;
    return iRtn;
}

typedef struct _SLConfigDescriptor
{
    Byte tag;//0x60
    unsigned int Length : 32;
    Byte predefined;
    /*
     //defined in 14496-1 but not implement here
     if(predefined == 0)
     {
     
     
     }
     
    */
    
    
} SLConfigDescriptor ;


typedef struct _DecoderConfigInfo
{
    Byte tag;//0x50
    unsigned int Length : 32;
//    Byte *vosvolData; //mark by robert hsu ,if use this field  will get wrong sizeof(ES_Descriptor)
    
} DecoderConfigInfo ;


typedef struct _DecoderConfigDescriptor
{
    Byte tag;//0x40
    unsigned int Length : 32;
    Byte objectProfileIndication;
    unsigned char reserved:1;
    unsigned char upstream:1;
    unsigned char streamType:6;


    //Byte bufferSize[3];
    unsigned int bufferSize : 24;
    unsigned int maxBitrate : 32;
    unsigned int avgBitrate : 32;
} DecoderConfigDescriptor ;



typedef struct _ES_Descriptor
{

    Byte tag;//0x30
    unsigned int Length : 32;
    unsigned int ES_ID : 16;//always 0x0000
    unsigned int streamPriority:5;
    unsigned int reserved:1;
    unsigned int URL_Flag:1;
    unsigned int streamDependenceFlag:1;
    
} ES_Descriptor ;


#endif
