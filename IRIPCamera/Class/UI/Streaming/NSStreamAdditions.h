//
//  NSStreamAdditions.h
//  inputStreamAudio
//
//  Created by sniApp on 13/6/7.
//  Copyright (c) 2013年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStream (MyAdditions)

+ (void)getStreamsToHostNamed:(NSString *)hostName
                         port:(NSInteger)port
                  inputStream:(NSInputStream *__strong*)inputStreamPtr
                 outputStream:(NSOutputStream *__strong*)outputStreamPtr;

@end
