//
//  DBZ_LoginView.h
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/16/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBZ_LoginView : UIViewController

- (void)updateInterface:(NSNotification*)notification;
- (void)refreshInterface:(NSNotification*)notification;
@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
- (IBAction)refresh:(id)sender;
@property (strong, nonatomic) IBOutlet UISegmentedControl *QRSelector;

@end
