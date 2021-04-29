//
//  StaticLanguage.h
//  IRIPCamera
//
//  Created by sniApp on 2015/4/18.
//  Copyright (c) 2015年 sniApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StaticLanguage : NSObject {
    NSString        *currentLanguage;
    NSBundle        *currentLanguageBundle;
}

-(id) init UNAVAILABLE_ATTRIBUTE;
+(id) new UNAVAILABLE_ATTRIBUTE;

+(id)sharedInstance;

-(void)setLanguage:(NSString*)languageName;
-(NSString*)stringFor:(NSString*)srcString;
-(NSString*)getLanguageIDWithLanguageName:(NSString*)languageName;

@property (nonatomic, strong) NSString        *currentLanguage;

@end
