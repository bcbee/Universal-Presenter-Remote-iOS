//
//  DBZ_SettingsView.h
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 9/3/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBZ_SettingsView : UIViewController

- (IBAction)close:(id)sender;
- (IBAction)updatePreferences:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *instructionControl;
@property (weak, nonatomic) IBOutlet UISwitch *swipeControl;

@end
