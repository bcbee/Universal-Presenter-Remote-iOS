//
//  DBZ_WKTest.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 3/15/15.
//  Copyright (c) 2015 DBZ Technology. All rights reserved.
//

#import "DBZ_WKTest.h"
#import "MMWormhole.h"


@interface DBZ_WKTest()
@property (strong, nonatomic) IBOutlet WKInterfaceSwitch *switchTest;
@property (nonatomic, strong) MMWormhole *wormhole;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *numberLabel;

@end


@implementation DBZ_WKTest

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.dbztech.Universal-Presenter-Remote.wormhole"
                                                         optionalDirectory:@"wormhole"];
    
    // Become a listener for changes to the wormhole for the button message
    [self.wormhole listenForMessageWithIdentifier:@"UPRWatchData" listener:^(id messageObject) {
        // The number is identified with the buttonNumber key in the message object
        NSNumber *number = [messageObject valueForKey:@"token"];
        NSNumber *enabled = [messageObject valueForKey:@"connectEnabled"];
        NSString *title = [messageObject valueForKey:@"connectTitle"];
        self.numberLabel.text = [number stringValue];
    }];
    
    [_switchTest setOn:NO];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



