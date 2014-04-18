//
//  DBZ_ControlView.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/17/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_ControlView.h"
#import "DBZ_ServerCommunication.h"

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

- (IBAction)mediaButton:(id)sender {
    [DBZ_ServerCommunication getResponse:@"PlayMedia" withToken:[DBZ_ServerCommunication token] withHoldfor:YES];
}

- (IBAction)nextButton:(id)sender {
    [DBZ_ServerCommunication getResponse:@"SlideUp" withToken:[DBZ_ServerCommunication token] withHoldfor:YES];
}

- (IBAction)previousButton:(id)sender {
    [DBZ_ServerCommunication getResponse:@"SlideDown" withToken:[DBZ_ServerCommunication token] withHoldfor:YES];
}

@end
