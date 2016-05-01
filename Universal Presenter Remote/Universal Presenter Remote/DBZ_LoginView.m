//
//  DBZ_LoginView.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/16/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_LoginView.h"
#import "DBZ_ServerCommunication.h"
#import <iAd/iAd.h>

#import <Google/Analytics.h>

@interface DBZ_LoginView ()

@end

@implementation DBZ_LoginView

NSTimer *refreshTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.canDisplayBannerAds = YES;
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"BatmanForeverAlternate" size:35.0f]}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInterface:) name:@"UpdateInterface" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInterface:) name:@"Refresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openInstructions:) name:@"OpenInstructions" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetQR:) name:@"ResetQR" object:nil];
    
    [DBZ_ServerCommunication setupUid];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(localRefresh) userInfo:nil repeats:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateInterface:(NSNotification *)notification {
    int inttoken = [DBZ_ServerCommunication temptoken];
    if (inttoken > 10) {
        [_tokenLabel setText:[NSString stringWithFormat:@"%d",inttoken]];
    }
    switch ([DBZ_ServerCommunication controlmode]) {
        case 0:
            [_connectButton setEnabled:NO];
            [_connectButton setTitle:@"Connecting..." forState:UIControlStateDisabled];
            //[self updateWatchLogin:inttoken withConnectEnabled:NO withConnectText:@"Connecting..."];
            break;
        case 1:
            [_connectButton setEnabled:NO];
            [_connectButton setTitle:@"Waiting..." forState:UIControlStateDisabled];
            //[self updateWatchLogin:inttoken withConnectEnabled:NO withConnectText:@"Waiting..."];
            break;
        case 2:
            [_connectButton setEnabled:YES];
            [_connectButton setTitle:@"Begin" forState:UIControlStateNormal];
            //[self updateWatchLogin:inttoken withConnectEnabled:YES withConnectText:@"Begin"];
            break;
            
        default:
            break;
    }
}

- (void)refreshInterface:(NSNotification *)notification {
    [DBZ_ServerCommunication checkToken];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ControlSegue"] || [[segue identifier] isEqualToString:@"SettingsSegue"])
    {
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"mplus-1c-regular" size:21],  NSFontAttributeName, nil]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    
}

- (IBAction)refresh:(id)sender {
    [DBZ_ServerCommunication setupUid];
    [DBZ_ServerCommunication checkToken];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"BatmanForeverAlternate" size:35.0f]}];
    
    [self resetQR:nil];
}

- (void)openInstructions:(NSNotification*)notification {
    [self performSegueWithIdentifier:@"InstructionSegue" sender:self];
}

- (void)resetQR:(NSNotification *)notification {
    _QRSelector.selectedSegmentIndex = 0;
}

- (void)localRefresh {
    if ([DBZ_ServerCommunication.apns isEqual: @""]) {
        // running in Simulator
        [DBZ_ServerCommunication checkToken];
    } else {
        [refreshTimer invalidate];
    }
}

@end
