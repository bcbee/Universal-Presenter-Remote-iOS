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
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"BatmanForeverAlternate" size:35.0f]}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInterface:) name:@"UpdateInterface" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInterface:) name:@"Refresh" object:nil];
    [DBZ_ServerCommunication setupUid];
    [DBZ_ServerCommunication checkStatus];
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
    if ([[segue identifier] isEqualToString:@"ConnectSegue"])
    {
        [DBZ_ServerCommunication connectSetup];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"mplus-1c-regular" size:21],  NSFontAttributeName, nil]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
}

- (IBAction)refresh:(id)sender {
    [DBZ_ServerCommunication setupUid];
    [DBZ_ServerCommunication checkToken];
}
@end
