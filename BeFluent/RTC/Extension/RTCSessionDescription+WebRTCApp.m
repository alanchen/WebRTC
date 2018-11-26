//
//  RTCSessionDescription+WebRTCApp.m
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "RTCSessionDescription+WebRTCApp.h"

static NSString const *kRTCSessionDescriptionTypeKey = @"type";
static NSString const *kRTCSessionDescriptionSdpKey = @"sdp";

@implementation RTCSessionDescription(WebRTCApp)

+ (RTCSessionDescription *)descriptionFromJSONDictionary:(NSDictionary *)dictionary
{
    NSString *typeString = dictionary[kRTCSessionDescriptionTypeKey];
    RTCSdpType type = [[self class] typeForString:typeString];
    NSString *sdp = dictionary[kRTCSessionDescriptionSdpKey];

    return [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
}

- (NSDictionary *)toJSONDictionary
{
    NSString *type = [[self class] stringForType:self.type];

    NSDictionary *json = @{kRTCSessionDescriptionSdpKey : self.sdp,
                           kRTCSessionDescriptionTypeKey : type};
    
    return json;
}

@end
