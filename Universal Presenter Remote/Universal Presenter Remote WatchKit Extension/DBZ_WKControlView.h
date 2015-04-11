//
//  DBZ_WKControlView.h
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 3/15/15.
//  Copyright (c) 2015 DBZ Technology. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "MMWormhole.h"

@interface DBZ_WKControlView : WKInterfaceController

@property (nonatomic, strong) MMWormhole *wormhole;



@end
