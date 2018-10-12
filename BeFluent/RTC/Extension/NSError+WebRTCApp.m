//
//  NSError+WebRTCApp.m
//  BeFluent
//
//  Created by alan on 2018/10/1.
//  Copyright © 2018 alan. All rights reserved.
//

#import "NSError+WebRTCApp.h"

static NSString *kAppClientErrorDomain = @"WebRTCAppClient";
static NSInteger kAppClientErrorUnknown = -1;
static NSInteger kAppClientErrorCreateSDP = -3;
static NSInteger kAppClientErrorSetSDP = -4;
static NSInteger kAppClientErrorNetwork = -5;


@implementation NSError(WebRTCApp)

+(NSError *)errorSetSDP
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Failed to set session description." };
    NSError *error =  [[NSError alloc] initWithDomain:kAppClientErrorDomain
                                                 code:kAppClientErrorSetSDP
                                             userInfo:userInfo];
    return error;
}

+(NSError *)errorCreateSDP
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Failed to create session description." };
    NSError *error =  [[NSError alloc] initWithDomain:kAppClientErrorDomain
                                                 code:kAppClientErrorCreateSDP
                                             userInfo:userInfo];
    return error;
}

+(NSError *)errorUnknown
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Unknown error." };
    NSError *error =  [[NSError alloc] initWithDomain:kAppClientErrorDomain
                                                 code:kAppClientErrorUnknown
                                             userInfo:userInfo];
    return error;
}

+(NSError *)errorNetwork
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Netowrk error." };
    NSError *error =  [[NSError alloc] initWithDomain:kAppClientErrorDomain
                                                 code:kAppClientErrorNetwork
                                             userInfo:userInfo];
    return error;
}



@end
