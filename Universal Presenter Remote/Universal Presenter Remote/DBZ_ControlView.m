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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mediaButton:(id)sender {
    [DBZ_ServerCommunication getResponse:@"PlayMedia" withToken:[DBZ_ServerCommunication token] withHoldfor:YES withDeviceToken:NO];
}

- (IBAction)nextButton:(id)sender {
    [DBZ_ServerCommunication getResponse:@"SlideUp" withToken:[DBZ_ServerCommunication token] withHoldfor:YES withDeviceToken:NO];
}

- (IBAction)previousButton:(id)sender {
    [DBZ_ServerCommunication getResponse:@"SlideDown" withToken:[DBZ_ServerCommunication token] withHoldfor:YES withDeviceToken:NO];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [DBZ_ServerCommunication setupUid];
        [DBZ_ServerCommunication checkToken];
    }
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"BatmanForeverAlternate" size:35.0f]}];
    [super viewWillDisappear:animated];
}

@end
