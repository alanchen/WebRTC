//
//  FIRApp+WebRTCApp.m
//  BeFluent
//
//  Created by alan on 2018/10/12.
//  Copyright © 2018 alan. All rights reserved.
//

#import "FIRApp+WebRTCApp.h"

@implementation FIRApp(WebRTCApp)

+(FIROptions *)webRTCOptions
{
    FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:@"" GCMSenderID:@""];
    options.bundleID = @"";
    options.APIKey = @"";
    options.clientID = @"";
    options.databaseURL = @"";
    options.storageBucket = @"";
    options.storageBucket = @"";
    options.projectID = @"";
    return options;
}

+(FIRApp *)webRTCApp
{
    [FIRApp configureWithOptions:[self webRTCOptions]];
    return [FIRApp defaultApp];
}

@end
