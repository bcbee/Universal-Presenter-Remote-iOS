//
//  DBZ_WKLoginView.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 3/15/15.
//  Copyright (c) 2015 DBZ Technology. All rights reserved.
//

#import "DBZ_WKLoginView.h"
#import "MMWormhole.h"
#import "UPR-Swift.h"

@interface DBZ_WKLoginView()

@end

@implementation DBZ_WKLoginView

NSTimer *checkInterfaceTimer;

bool firstTime = true;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.dbztech.Universal-Presenter-Remote.wormhole" optionalDirectory:@"wormhole"];
    
    NSDictionary *requst = @{@"request":@"Startup"};
    
    /*
    [DBZ_WKLoginView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"%@",[replyInfo objectForKey:@"response"]);
        }
        
    }];
     */
    
    if (firstTime) {
        requst = @{@"request":@"Refresh"};
        
        /*
        [DBZ_WKLoginView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
            
            if (error) {
                NSLog(@"%@", error);
            } else {
                
                NSLog(@"%@",[replyInfo objectForKey:@"response"]);
            }
            
        }];
        firstTime = false;
         */
    }
    
    
    
    // Become a listener for changes to the wormhole for the button message
    [self.wormhole listenForMessageWithIdentifier:@"UPRWatchData" listener:^(id messageObject) {
        // The number is identified with the buttonNumber key in the message object
        NSNumber *number = [messageObject valueForKey:@"token"];
        NSNumber *enabled = [messageObject valueForKey:@"connectEnabled"];
        NSString *title = [messageObject valueForKey:@"connectTitle"];
        if (![[number stringValue] isEqualToString:@"0"]) {
            if ([[number stringValue]  isEqual: @""]) {
                NSDictionary *requst = @{@"request":@"Refresh"};
                
                /*
                [DBZ_WKLoginView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
                    
                    if (error) {
                        NSLog(@"%@", error);
                    } else {
                        
                        NSLog(@"%@",[replyInfo objectForKey:@"response"]);
                    }
                    
                }];
                 */
            }
            _tokenLabel.text = [number stringValue];
        } else {
            _tokenLabel.text = @"...";
        }
        
        [_connectButton setTitle:title];
        if ([enabled isEqualToNumber:@(1)]) {
            [_connectButton setEnabled:YES];
        } else {
            [_connectButton setEnabled:NO];
        }
    }];
    
    //checkInterfaceTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(checkInterface:) userInfo:nil repeats:YES];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)checkInterface:(NSTimer*)timer {
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.dbztech.Universal-Presenter-Remote.wormhole" optionalDirectory:@"wormhole"];
    
    NSDictionary *requst = @{@"request":@"Startup"};
    
    /*
    [DBZ_WKLoginView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"%@",[replyInfo objectForKey:@"response"]);
        }
        
    }];
    */
}

- (IBAction)refreshToken {
    NSDictionary *requst = @{@"request":@"Refresh"};
    
    /*
    [DBZ_WKLoginView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"%@",[replyInfo objectForKey:@"response"]);
        }
        
    }];
     */
}

- (IBAction)openInstructions {
    NSLog(@"Open Instructions");
    [self presentControllerWithName:@"Instructions" context: nil];
}
@end



