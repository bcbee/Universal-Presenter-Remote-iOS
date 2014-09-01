//
//  DBZ_InfoView.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/20/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_InfoView.h"
#import <iAd/iAd.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface DBZ_InfoView ()

@end

@implementation DBZ_InfoView

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
           value:@"Instructions"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
