//
//  DBZ_SettingsView.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 9/3/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_SettingsView.h"
#import <iAd/iAd.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface DBZ_SettingsView ()

@end

@implementation DBZ_SettingsView

NSDictionary *oldpreferences = nil;
NSDictionary *newpreferences = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.canDisplayBannerAds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInterface:) name:@"PreferenceUpdate" object:nil];
    [self updateInterface:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updatePreferences:(id)sender {
    NSString *firsttime = @"Enabled";
    NSString *swipe = @"Enabled";
    
    if ([self.instructionControl selectedSegmentIndex] == 0) {
        firsttime = @"Enabled";
    } else {
        firsttime = @"Disabled";
    }
    
    if ([self.swipeControl selectedSegmentIndex] == 0) {
        swipe = @"Enabled";
    } else {
        swipe = @"Disabled";
    }
    
    newpreferences = [NSDictionary dictionaryWithObjectsAndKeys: firsttime, @"Instructions", swipe, @"SwipeControl", nil];
    [self savePreferences];
}

- (void)savePreferences {
    // Save Local Copy
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:newpreferences forKey:@"preferences"];
    
    // Save To iCloud
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    
    if (store != nil) {
        [store setObject:newpreferences forKey:@"preferences"];
        NSLog(@"iCloud Saved");
        NSDictionary *clouddict = [store dictionaryRepresentation];
        for(NSString *key in [clouddict allKeys]) {
            NSLog(@"iCloud: %@",[clouddict objectForKey:key]);
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Settings"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)updateInterface:(NSNotification*)notification {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    oldpreferences = [ud objectForKey:@"preferences"];
    
    if ([[oldpreferences objectForKey:@"Instructions"] isEqualToString:@"Enabled"]) {
        self.instructionControl.selectedSegmentIndex = 0;
    } else {
        self.instructionControl.selectedSegmentIndex = 1;
    }
    
    if ([[oldpreferences objectForKey:@"SwipeControl"] isEqualToString:@"Enabled"]) {
        self.swipeControl.selectedSegmentIndex = 0;
    } else {
        self.swipeControl.selectedSegmentIndex = 1;
    }
    NSLog(@"Local: %@",oldpreferences);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
