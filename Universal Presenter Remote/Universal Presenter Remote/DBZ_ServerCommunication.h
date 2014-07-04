//
//  DBZ_ServerCommunication.h
//  Universal Presenter Remote
//
//  Created by Brendan Boyle on 4/11/14.
//  Copyright (c) 2014 DBZ Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBZ_ServerCommunication : NSObject


+(NSString*)serverAddress;
+(int)uid;
+(int)temptoken;
+(int)controlmode;
+(int)token;
+(bool)serverAvailable;
+(bool)enabled;

+(void)getResponse:(NSString*)page withToken:(int)requestToken withHoldfor:(bool)holdfor withDeviceToken:(bool)devicetoken;
+(void)processResponse:(NSMutableArray*)webResponse;
+(void)setupUid;
+(void)checkStatus;
+(void)checkStatusCallback:(NSString*)response;
+(void)checkToken;
+(void)checkTokenCallback:(NSString*)response;
+(void)newTokenCallback:(NSString*)response;
+(void)updateInterface;
+(void)connectSetup;
+(void)setupApns:(NSString*)deviceToken;

@end
