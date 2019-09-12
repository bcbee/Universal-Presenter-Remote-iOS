//
//  DBZ_AppDelegate.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/16/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_AppDelegate.h"
#import "DBZ_ServerCommunication.h"
#import "UPR-Swift.h"
#import "DBZ_InfoView.h"
#import <AudioToolbox/AudioServices.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@implementation DBZ_AppDelegate

NSDictionary *preferences = nil;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //[[Fabric sharedSDK] setDebug: YES];
    [Fabric with:@[[Crashlytics class]]];
    
    //Google Analytics
    
    // Configure tracker from GoogleService-Info.plist.
    //NSError *configureError;
    //[[GGLContext sharedInstance] configureWithError:&configureError];
    //NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    //GAI *gai = [GAI sharedInstance];
    //gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    //gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
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
        NSString *controlMode = @"Swipe";
        
        preferences = [NSDictionary dictionaryWithObjectsAndKeys: instructions, @"Instructions", controlMode, @"ControlMode", nil];
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkIndicatorOn:) name:@"NetworkIndicatorOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkIndicatorOff:) name:@"NetworkIndicatorOff" object:nil];
    
    
    return YES;
    
    //End Push Notifications
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
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
    if ([DBZ_UPRGlobal hasTaptic]) {
        _feedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
        [_feedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
    } else {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // You can send here, for example, an asynchronous HTTP request to your web-server to store this deviceToken remotely.
    NSString* token = [self hexadecimalStringFromData:deviceToken];
    NSLog(@"Did register for remote notifications: %@", token);
    [DBZ_ServerCommunication setupApns:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Fail to register for remote notifications: %@", error);
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"Quick Launch Action!");
    DBZ_UPRGlobal.viewToOpen = shortcutItem.type;
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

- (NSString *)hexadecimalStringFromData:(NSData *)data
{
  NSUInteger dataLength = data.length;
  if (dataLength == 0) {
    return nil;
  }

  const unsigned char *dataBuffer = (const unsigned char *)data.bytes;
  NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
  for (int i = 0; i < dataLength; ++i) {
    [hexString appendFormat:@"%02x", dataBuffer[i]];
  }
  return [hexString copy];
}

@end
