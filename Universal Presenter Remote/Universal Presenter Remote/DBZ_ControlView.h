//
//  DBZ_ControlView.h
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/17/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBZ_ControlView : UIViewController
- (IBAction)mediaButton:(id)sender;
- (IBAction)nextButton:(id)sender;
- (IBAction)previousButton:(id)sender;
- (void)close:(NSNotification*)notification;

@end
