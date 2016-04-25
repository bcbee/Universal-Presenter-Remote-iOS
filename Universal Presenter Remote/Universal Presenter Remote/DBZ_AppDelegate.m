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
#import "GAIDictionaryBuilder.h"
#import "MMWormhole.h"
#import <AudioToolbox/AudioServices.h>

@implementation DBZ_AppDelegate

NSDictionary *preferences = nil;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    //Google Analytics
    
    // Add registration for remote notifications
    //-- Set Notification
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50792115-1"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    //End Google Aanlytics
    
    
    /////////////////////////
    
    
    //iCloud
    
    // Register the preference defaults early.
    NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKVStoreItems:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:store];
    [store synchronize];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    bool firstime = NO;
    
    if ([ud objectForKey:@"preferences"] != nil) {
        NSLog(@"Preferences Loaded");
        preferences = [ud objectForKey:@"preferences"];
    } else {
        NSLog(@"New Preferences Generated");
        NSString *instructions = @"Disabled";
        NSString *swipe = @"Enabled";
        
        preferences = [NSDictionary dictionaryWithObjectsAndKeys: instructions, @"Instructions", swipe, @"SwipeControl", nil];
        [self savePreferences];
        
        firstime = YES;
        
    }
    
    if ([[preferences objectForKey:@"Instructions"] isEqualToString:@"Enabled"] || firstime) {
        NSLog(@"Display Instructions");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to Universal Presenter Remote" message:@"Would you like to see setup instructions?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:@"Yes"];
        [alert show];
        
    } else {
        NSLog(@"Instructions Dismissed");
    }
    
    
    
    
    //End iCloud
    
    
    /////////////////////////
    
    
    //Push Notifications
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkIndicatorOn:) name:@"NetworkIndicatorOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkIndicatorOff:) name:@"NetworkIndicatorOff" object:nil];
    
    
    return YES;
    
    //End Push Notifications
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [DBZ_ServerCommunication checkToken];
    NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
    [store synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog (@"APNS: notification received: %@", userInfo);
    NSNotification* notification = [NSNotification notificationWithName:@"Refresh" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    completionHandler(UIBackgroundFetchResultNewData);
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // You can send here, for example, an asynchronous HTTP request to your web-server to store this deviceToken remotely.
    NSLog(@"Did register for remote notifications: %@", deviceToken);
    [DBZ_ServerCommunication setupApns:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Fail to register for remote notifications: %@", error);
}

- (void)updateKVStoreItems:(NSNotification*)notification {
    NSLog(@"iCloud Sync!");
    // Get the list of keys that changed.
    NSDictionary* userInfo = [notification userInfo];
    NSNumber* reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    NSInteger reason = -1;
    
    // If a reason could not be determined, do not update anything.
    if (!reasonForChange)
        return;
    
    // Update only for changes from the server.
    reason = [reasonForChange integerValue];
    if ((reason == NSUbiquitousKeyValueStoreServerChange) ||
        (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
        // If something is changing externally, get the changes
        // and update the corresponding keys locally.
        NSArray* changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
        NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        // This loop assumes you are using the same key names in both
        // the user defaults database and the iCloud key-value store
        for (NSString* key in changedKeys) {
            NSLog(@"Value for key %@ changed", key);
            id value = [store objectForKey:key];
            [userDefaults setObject:value forKey:key];
        }
        
        preferences = [userDefaults objectForKey:@"preferences"];
        
        NSNotification* notification = [NSNotification notificationWithName:@"PreferenceUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)savePreferences {
    // Save Local Copy
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:preferences forKey:@"preferences"];
    
    // Save To iCloud
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    
    if (store != nil) {
        [store setObject:preferences forKey:@"preferences"];
    }
}

- (void)resetDefaults {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSNotification* notification = [NSNotification notificationWithName:@"OpenInstructions" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)networkIndicatorOn:(NSNotification *)notification {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)networkIndicatorOff:(NSNotification *)notification {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

/*
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply{
    
    NSLog(@"containing app received message from watch");
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"Startup"]) {
        
        NSDictionary *response = @{@"response" : @"Application Started from Watch"};
        NSNotification* notification = [NSNotification notificationWithName:@"UpdateInterface" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"apple_watch" action:@"watch_event" label:@"wk_startup" value:nil] build]];
        
        reply(response);
    }
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"ConnectSession"]) {
        
        NSDictionary *response = @{@"response" : @"Session Connected from Watch"};
        NSNotification* notification = [NSNotification notificationWithName:@"WatchConnectSession" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        reply(response);
    }
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"EndSession"]) {
        
        NSDictionary *response = @{@"response" : @"Session Ended from Watch"};
        NSNotification* notification = [NSNotification notificationWithName:@"WatchEndSession" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        reply(response);
    }
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"ChangeSlideUp"]) {
        
        NSDictionary *response = @{@"response" : @"Slide Changed from Watch"};
        [DBZ_ServerCommunication getResponse:@"SlideUp" withToken:[DBZ_ServerCommunication token] withHoldfor:YES withDeviceToken:NO withTarget:nil];
        reply(response);
    }
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"ChangeSlideDown"]) {
        
        NSDictionary *response = @{@"response" : @"Slide Changed from Watch"};
        [DBZ_ServerCommunication getResponse:@"SlideDown" withToken:[DBZ_ServerCommunication token] withHoldfor:YES withDeviceToken:NO withTarget:nil];
        reply(response);
    }
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"ChangeSlideMedia"]) {
        
        NSDictionary *response = @{@"response" : @"Slide Changed from Watch"};
        [DBZ_ServerCommunication getResponse:@"PlayMedia" withToken:[DBZ_ServerCommunication token] withHoldfor:YES withDeviceToken:NO withTarget:nil];
        reply(response);
    }
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"Refresh"]) {
        
        NSDictionary *response = @{@"response" : @"Token Refreshed"};
        NSNotification* notification = [NSNotification notificationWithName:@"WatchRefreshSession" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        reply(response);
    }
    
}
 */

@end
