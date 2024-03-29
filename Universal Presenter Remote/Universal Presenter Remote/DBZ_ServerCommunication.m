//
//  DBZ_ServerCommunication.m
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/11/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import "DBZ_ServerCommunication.h"
#import "UPR-Swift.h"


@implementation DBZ_ServerCommunication

static NSString *serverAddress = @"https://universalpresenterremote.com";
static int uid = 10;
static int temptoken = 10;
static int controlmode = 0;
static int token = 0;
static bool serverAvailable = NO;
static bool enabled = NO;
static bool setup = NO;

static NSString *apns = @"";

+(NSString*)serverAddress { return serverAddress; }
+(int)uid { return uid; }
+(int)temptoken { return temptoken; }
+(int)controlmode { return controlmode; }
+(int)token { return token; }
+(bool)serverAvailable { return serverAvailable; }
+(bool)enabled { return enabled; }
+(bool)setup { return setup; }
+(NSString*)apns { return apns; }

+(void)getResponse:(NSString*)page withToken:(int)requestToken withHoldfor:(bool)holdfor withDeviceToken:(bool)devicetoken withTarget:(NSString*)targetToken {
    
    NSString *strURL= [NSString stringWithFormat:@"%@/%@", serverAddress, page];
    
    bool processRequest = true;
    
    if (requestToken > 99999) {
        strURL = [NSString stringWithFormat:@"%@?token=%d", strURL, requestToken];
    } else {
        if (![page  isEqual: @"NewSession"]) {
            [self getResponse:@"NewSession" withToken:0 withHoldfor:NO withDeviceToken:NO withTarget:nil];
            processRequest = false;
        }
    }
    
    if (holdfor) {
        strURL = [NSString stringWithFormat:@"%@&holdfor=%d", strURL, uid];
    }
    
    if (devicetoken) {
        strURL = [NSString stringWithFormat:@"%@&apnstoken=%@", strURL, apns];
    }
    
    if ((int)targetToken > 99999) {
        strURL = [NSString stringWithFormat:@"%@&target=%@", strURL, targetToken];
    }
    
    if (processRequest) {
        NSLog(@"%@", strURL);
        [DBZ_UniversalNetworking makeRequest:strURL page:page callback:^(NSMutableArray *array) {
            [self processResponse:array];
        }];
    }
    
}

+(void)processResponse:(NSMutableArray*)webResponse {
    // The one we want to switch on
    NSArray *items = @[@"Alive", @"NewSession", @"TempSession", @"JoinSession"];
    NSInteger item = [items indexOfObject:[webResponse objectAtIndex:0]];
    switch (item) {
        case 0:
            // Alive
            [self checkStatusCallback:[webResponse objectAtIndex:1]];
            break;
        case 1:
            // NewSession
            [self newTokenCallback:[webResponse objectAtIndex:1]];
            break;
        case 2:
            // TempSession
            [self checkTokenCallback:[webResponse objectAtIndex:1]];
            break;
        default:
            break;
    }
}

+(void)setupUid {
    NSUInteger r = arc4random_uniform(999999);
    uid = (int)r;
    temptoken = 10;
    setup = YES;
}

+(void)checkStatus {
    [self getResponse:@"Alive" withToken:0 withHoldfor:NO withDeviceToken:NO withTarget:nil];
}

+(void)checkStatusCallback:(NSString *)response {
    if ([response isEqualToString:@"Ready"]) {
        NSLog(@"Alive!");
        serverAvailable = YES;
        
    } else {
        NSLog(@"Dead :(");
        serverAvailable = NO;
        controlmode = 0;
        [self checkStatus];
    }
}

+(void)checkToken {
    int sendtoken = temptoken;
    [self getResponse:@"TempSession" withToken:sendtoken withHoldfor:YES withDeviceToken:YES withTarget:nil];
}

+(void)checkTokenCallback:(NSString*)response {
    int r = [response intValue];
    controlmode = r;
    
    if (controlmode == 0) {
        temptoken = 0;
    }
    
    if (temptoken == 0) {
        [self getResponse:@"NewSession" withToken:0 withHoldfor:NO withDeviceToken:NO withTarget:nil];
    }
    
    [self updateInterface];
}

+(void)newTokenCallback:(NSString*)response {
    int r = [response intValue];
    temptoken = r;
    [self checkToken];
}

+(void)updateInterface {
    NSNotification* notification = [NSNotification notificationWithName:@"UpdateInterface" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

+(void)setupApns:(NSString *)deviceToken {
    NSString *token = [[[[deviceToken description]stringByReplacingOccurrencesOfString:@"<"withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString: @" " withString: @""];
    apns = token;
    [self checkToken];
}

+(void)activateSession:(NSString*)targetToken {
    [self getResponse:@"StartQR" withToken:temptoken withHoldfor:NO withDeviceToken:NO withTarget:targetToken];
}

+(void)startSession {
    token = temptoken;
    enabled = YES;
}

+(void)endSession {
    [self setupUid];
    [self checkToken];
    enabled = NO;
}

@end
