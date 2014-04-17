//
//  DBZ_SlideControl.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/1/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_SlideControl.h"

@implementation DBZ_SlideControl

static int currentslide = 5000;

+(int)currentslide { return currentslide; }

+(void)setSlide:(int)slide {
    int deltaslide = slide - currentslide;
    
    if (deltaslide < 0) {
        [self slideLeft];
    }
    if (deltaslide > 0 && deltaslide < 50) {
        [self slideRight];
    }
    if (deltaslide > 50) {
        [self playMedia];
    }
    currentslide = slide;
}

+ (void)slideControl:(int)action {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
        NSURL *script = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"left" ofType:@"scpt"]];
        
        switch (action) {
            case 0:
                script = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"left" ofType:@"scpt"]];
                break;
            case 1:
                script = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"right" ofType:@"scpt"]];
                break;
            case 2:
                script = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"left" ofType:@"scpt"]];
                break;
            default:
                break;
        }
        for (int i=0; i<1; i++) {
            NSError *error;
            NSUserAppleScriptTask *task = [[NSUserAppleScriptTask alloc] initWithURL:script error:&error];
            [task executeWithCompletionHandler:^(NSError *error) {
                if (error){
                    NSLog(@"Script execution failed with error: %@", [error localizedDescription]);
                }
                [lock lock];
                [lock unlockWithCondition:1];
            }];
            
            //This will wait until the completion handler of the script task has run:
            [lock lockWhenCondition:1];
            [lock unlockWithCondition:0];
        }
    });
}

+ (void)slideLeft {
    [self slideControl:0];
}

+ (void)slideRight {
    [self slideControl:1];
}

+ (void)playMedia {
    [self slideControl:1];
}

+(void)reset {
    currentslide = 5000;
}


@end
