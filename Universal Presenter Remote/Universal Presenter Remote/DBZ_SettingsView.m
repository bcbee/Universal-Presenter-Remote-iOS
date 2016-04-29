//
//  DBZ_SettingsView.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 9/3/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_SettingsView.h"
#import <iAd/iAd.h>

#import <Google/Analytics.h>

@interface DBZ_SettingsView ()

@end

@implementation DBZ_SettingsView

NSDictionary *oldpreferences = nil;
NSDictionary *newpreferences = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.canDisplayBannerAds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInterface:) name:@"PreferenceUpdate" object:nil];
    [self updateInterface:nil];
    
    [self.swipeControl setEnabled:[self has3DTouch] forSegmentAtIndex:2];
    
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
    NSString *controlMode = @"Swipe";
    
    if ([self.instructionControl selectedSegmentIndex] == 0) {
        firsttime = @"Enabled";
    } else {
        firsttime = @"Disabled";
    }
    
    
    switch ([self.swipeControl selectedSegmentIndex]) {
        case 0:
            controlMode = @"Swipe";
            break;
        case 1:
            controlMode = @"Buttons";
            break;
        case 2:
            controlMode = @"3D Touch";
            break;
        default:
            controlMode = @"Swipe";
            break;
    }
    
    newpreferences = [NSDictionary dictionaryWithObjectsAndKeys: firsttime, @"Instructions", controlMode, @"ControlMode", nil];
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
    
    NSNotification* notification = [NSNotification notificationWithName:@"PreferenceUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Settings"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)updateInterface:(NSNotification*)notification {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    oldpreferences = [ud objectForKey:@"preferences"];
    
    if ([[oldpreferences objectForKey:@"Instructions"] isEqualToString:@"Enabled"]) {
        self.instructionControl.selectedSegmentIndex = 0;
    } else {
        self.instructionControl.selectedSegmentIndex = 1;
    }
    
    if ([[oldpreferences objectForKey:@"ControlMode"] isEqualToString:@"Swipe"]) {
        self.swipeControl.selectedSegmentIndex = 0;
    } else if ([[oldpreferences objectForKey:@"ControlMode"] isEqualToString:@"3D Touch"] && [self has3DTouch]) {
        self.swipeControl.selectedSegmentIndex = 2;
    } else {
        self.swipeControl.selectedSegmentIndex = 1;
    }
    NSLog(@"Local: %@",oldpreferences);
}

- (bool)has3DTouch {
    return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
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
