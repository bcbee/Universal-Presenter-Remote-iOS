//
//  DBZ_WKControlView.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 3/15/15.
//  Copyright (c) 2015 DBZ Technology. All rights reserved.
//

#import "DBZ_WKControlView.h"
#import "DBZ_ServerCommunication.h"

@interface DBZ_WKControlView()

@end


@implementation DBZ_WKControlView

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    //self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.dbztech.Universal-Presenter-Remote.wormhole" optionalDirectory:@"wormhole"];
    
    NSDictionary *requst = @{@"request":@"ConnectSession"};
    
    /*
    [DBZ_WKControlView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"%@",[replyInfo objectForKey:@"response"]);
        }
    }];
     
    
    // Become a listener for changes to the wormhole for the button message
    [self.wormhole listenForMessageWithIdentifier:@"UPRWatchAction" listener:^(id messageObject) {
        // The number is identified with the buttonNumber key in the message object
        NSString *action = [messageObject valueForKey:@"action"];
        if ([action  isEqual: @"EndSession"]) {
            [self popToRootController];
        }
    }];
     */
    
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    
    NSDictionary *requst = @{@"request":@"EndSession"};
    
    /*
    [DBZ_WKControlView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"%@",[replyInfo objectForKey:@"response"]);
        }
        
    }];
     */
}

- (IBAction)mediaPressed {
    //[self.wormhole passMessageObject:@{@"token" : @(3)} identifier:@"UPRWatchAction"];
    NSDictionary *requst = @{@"request":@"ChangeSlideMedia"};
    
    /*
    [DBZ_WKControlView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"%@",[replyInfo objectForKey:@"response"]);
        }
        
    }];
     */
}

- (IBAction)nextPressed {
    NSDictionary *requst = @{@"request":@"ChangeSlideUp"};
    
    /*
    [DBZ_WKControlView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"%@",[replyInfo objectForKey:@"response"]);
        }
        
    }];
     */
    
}

- (IBAction)previousPressed {
    NSDictionary *requst = @{@"request":@"ChangeSlideDown"};
    
    /*
    [DBZ_WKControlView openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            NSLog(@"%@",[replyInfo objectForKey:@"response"]);
        }
        
    }];
     */
}

@end



