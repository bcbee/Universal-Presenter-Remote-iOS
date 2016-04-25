//
//  DBZ_AppDelegate.h
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/16/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBZ_AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)networkIndicatorOn:(NSNotification *)notification;
- (void)networkIndicatorOff:(NSNotification *)notification;

@end
