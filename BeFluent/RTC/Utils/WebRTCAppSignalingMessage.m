//
//  WebRTCAppSignalingMessage.m
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "WebRTCAppSignalingMessage.h"
#import "WebRTCAppUtilities.m"

static NSString const *kSignalingMessageTypeKey = @"type";
static NSString const *kSignalingMessageSDPKey = @"sdp";
static NSString const *kSignalingMessageICEKey = @"ice";
static NSString const *kSignalingMessageMessageKey = @"message";
static NSString const *kSignalingMessageSenderKey = @"sender";

@implementation WebRTCAppSignalingMessage

+ (WebRTCAppSignalingMessage *)messageFromJSON:(NSDictionary *)json
{
    WebRTCAppSignalingMessage *msg = [[WebRTCAppSignalingMessage alloc] init];
    
    if(!json || ![json isKindOfClass:[NSDictionary class]])
        return msg;
    
    if(![[json allKeys] count])
        return msg;
    
    msg.payload = json;
    msg.sender = [msg.payload objectForKey:kSignalingMessageSenderKey];
    msg.message = [msg.payload objectForKey:kSignalingMessageMessageKey];
    msg.messageDictionary = [msg.message JSONParse];
    
    if(![msg.messageDictionary isKindOfClass:[NSDictionary class]])
        return msg;
    
    id ice = [msg.messageDictionary objectForKey:kSignalingMessageICEKey];
    id sdp = [msg.messageDictionary objectForKey:kSignalingMessageSDPKey];
    
    if([ice isKindOfClass:[NSDictionary class]]){
        msg.ice = ice;
    }

    if([sdp isKindOfClass:[NSDictionary class]]){
        msg.sdp = sdp;
        msg.sdpType = [msg.sdp objectForKey:kSignalingMessageTypeKey];
    }
    
    return msg;
}

+ (NSDictionary *)createIcePayloadWithSender:(NSString *)sender
                                   candidate:(NSDictionary *)candidate
{
    if(sender && candidate){
        id ice = @{kSignalingMessageICEKey:candidate};
        NSString *msgStr = [ice JSONSerialize];
        if(msgStr){
            return @{kSignalingMessageSenderKey:sender, kSignalingMessageMessageKey:msgStr};
        }
    }
    
    return @{};
}

+ (NSDictionary *)createSdpPayloadWithSender:(NSString *)sender
                                         sdp:(NSDictionary *)sdpInfo
{
    if(sender && sdpInfo){
        id sdp = @{kSignalingMessageSDPKey:sdpInfo};
        NSString *msgStr = [sdp JSONSerialize];
        if(msgStr){
            return @{kSignalingMessageSenderKey:sender, kSignalingMessageMessageKey:msgStr};
        }
    }
    
    return @{};
}

@end
