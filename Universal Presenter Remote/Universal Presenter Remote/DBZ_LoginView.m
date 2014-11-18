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

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface DBZ_LoginView ()

@end

@implementation DBZ_LoginView

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
    [DBZ_ServerCommunication setupUid];
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice.model rangeOfString:@"Simulator"].location != NSNotFound) {
        // running in Simulator
        [DBZ_ServerCommunication setupUid];
        [DBZ_ServerCommunication checkToken];
    }
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
            break;
        case 1:
            [_connectButton setEnabled:NO];
            [_connectButton setTitle:@"Waiting..." forState:UIControlStateDisabled];
            break;
        case 2:
            [_connectButton setEnabled:YES];
            [_connectButton setTitle:@"Begin" forState:UIControlStateNormal];
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
    if ([[segue identifier] isEqualToString:@"ControlSegue"] || [[segue identifier] isEqualToString:@"SwipeControlSegue"] || [[segue identifier] isEqualToString:@"SettingsSegue"])
    {
        [DBZ_ServerCommunication connectSetup];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"mplus-1c-regular" size:21],  NSFontAttributeName, nil]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    
}

- (IBAction)refresh:(id)sender {
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) {
        //running on device
        [DBZ_ServerCommunication setupUid];
        [DBZ_ServerCommunication checkToken];
    } else {
        // running in Simulator
        [self connectSession:nil];
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
           value:@"Login"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    _QRSelector.selectedSegmentIndex = 0;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"BatmanForeverAlternate" size:35.0f]}];
}

- (void)openInstructions:(NSNotification*)notification {
    [self performSegueWithIdentifier:@"InstructionSegue" sender:self];
}

- (IBAction)connectSession:(id)sender {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *preferences = [ud objectForKey:@"preferences"];
    
    if ([[preferences objectForKey:@"SwipeControl"] isEqualToString:@"Enabled"]) {
        [self performSegueWithIdentifier:@"SwipeControlSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"ControlSegue" sender:self];
    }
}

@end
