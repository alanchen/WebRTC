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
    NSString *type = dictionary[kRTCSessionDescriptionTypeKey];
    NSString *sdp = dictionary[kRTCSessionDescriptionSdpKey];
    
    return [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
}

- (NSDictionary *)toJSONDictionary
{
    NSDictionary *json = @{kRTCSessionDescriptionSdpKey : self.description,
                           kRTCSessionDescriptionTypeKey : self.type};
    
    return json;
}

@end
