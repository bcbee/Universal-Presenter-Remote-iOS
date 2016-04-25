//
//  DBZ_ControlView.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/17/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_ControlView.h"
#import "DBZ_ServerCommunication.h"
#import <iAd/iAd.h>

#import <Google/Analytics.h>

@interface DBZ_ControlView ()

@end

@implementation DBZ_ControlView

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
    // Do any additional setup after loading the view.
    self.canDisplayBannerAds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close:) name:@"WatchEndSession" object:nil];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mediaButton:(id)sender {
    [DBZ_ServerCommunication getResponse:@"PlayMedia" withToken:[DBZ_ServerCommunication token] withHoldfor:YES withDeviceToken:NO withTarget:nil];
}

- (IBAction)nextButton:(id)sender {
    [DBZ_ServerCommunication getResponse:@"SlideUp" withToken:[DBZ_ServerCommunication token] withHoldfor:YES withDeviceToken:NO withTarget:nil];
}

- (IBAction)previousButton:(id)sender {
    [DBZ_ServerCommunication getResponse:@"SlideDown" withToken:[DBZ_ServerCommunication token] withHoldfor:YES withDeviceToken:NO withTarget:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [DBZ_ServerCommunication endSession];
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Control"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)close:(NSNotification *)notification {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
