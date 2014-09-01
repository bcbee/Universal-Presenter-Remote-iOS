//
//  DBZ_AppDelegate.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/16/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_AppDelegate.h"
#import "DBZ_ServerCommunication.h"
#import "GAI.h"

@implementation DBZ_AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Add registration for remote notifications
    //-- Set Notification
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50792115-1"];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingNotification:) name:@"ServerResponse" object:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //[DBZ_ServerCommunication checkToken];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[DBZ_ServerCommunication checkToken];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[DBZ_ServerCommunication checkToken];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [DBZ_ServerCommunication checkToken];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) incomingNotification:(NSNotification *)notification {
    NSMutableArray *incoming = [notification object];
    [DBZ_ServerCommunication processResponse:incoming];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
 {
    NSLog (@"APNS: notification received: %@", userInfo);
    NSNotification* notification = [NSNotification notificationWithName:@"Refresh" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    completionHandler(UIBackgroundFetchResultNewData);
    // We can determine whether an application is launched as a result of the user tapping the action
    // button or whether the notification was delivered to the already-running application by examining
    // the application state.
    /*
    if (application.applicationState == UIApplicationStateActive) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification"
                                                            message:[NSString stringWithFormat:@"The application received this remote notification while it was running:\n%@",
                                                                     [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
     */
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // You can send here, for example, an asynchronous HTTP request to your web-server to store this deviceToken remotely.
    NSLog(@"Did register for remote notifications: %@", deviceToken);
    [DBZ_ServerCommunication setupApns:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Fail to register for remote notifications: %@", error);
}


@end
