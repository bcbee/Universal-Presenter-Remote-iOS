//
//  DBZ_SlideControl.h
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/11/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBZ_SlideControl : NSObject

+(int)currentslide;
+(void)setSlide:(int)slide;

+ (void)slideControl:(int)action;
+ (void)slideLeft;
+ (void)slideRight;
+ (void)playMedia;
+ (void)reset;

@end
