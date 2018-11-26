//
//  WebRTCAppSignalingMessage.m
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "WebRTCAppSignalingMessage.h"
#import "WebRTCAppUtilities.h"

static NSString  *kSignalingMessageSDPKey = @"sdp";
static NSString  *kSignalingMessageICEKey = @"ice";
static NSString  *kSignalingMessageBYEKey = @"bye";

static NSString  *kSignalingMessageTypeKey = @"type";
static NSString  *kSignalingMessageMessageKey = @"message";
static NSString  *kSignalingMessageSenderKey = @"sender";

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
    msg.type = [msg.payload objectForKey:kSignalingMessageTypeKey];
    msg.messageDictionary = [msg.message JSONParse];
    
    if([msg.type isEqualToString:kSignalingMessageICEKey]){
         msg.ice = msg.messageDictionary;
        if(![msg.ice isKindOfClass:[NSDictionary class]]){
            msg.ice = nil;
        }
    }
    
    if([msg.type isEqualToString:kSignalingMessageSDPKey]){
        msg.sdp = msg.messageDictionary;
        if([msg.sdp isKindOfClass:[NSDictionary class]]){
            msg.sdpType = [msg.sdp objectForKey:kSignalingMessageTypeKey];
        }
    }

    return msg;
}

+ (NSDictionary *)createIcePayloadWithSender:(NSString *)sender
                                   candidate:(NSDictionary *)candidate
{
    if(sender && candidate){
        NSString *msgStr = [candidate JSONSerialize];
        if(msgStr){
            return @{kSignalingMessageSenderKey:sender, kSignalingMessageMessageKey:msgStr, kSignalingMessageTypeKey:kSignalingMessageICEKey};
        }
        
        
    }
    
    return @{};
}

+ (NSDictionary *)createSdpPayloadWithSender:(NSString *)sender
                                         sdp:(NSDictionary *)sdpInfo
{
    if(sender && sdpInfo){
        NSString *msgStr = [sdpInfo JSONSerialize];
        if(msgStr){
            return @{kSignalingMessageSenderKey:sender, kSignalingMessageMessageKey:msgStr, kSignalingMessageTypeKey:kSignalingMessageSDPKey };
        }
    }
    
    return @{};
}

+ (NSDictionary *)createByebyeWithSender:(NSString *)sender
{
    if(sender){
        return @{kSignalingMessageSenderKey:sender, kSignalingMessageMessageKey:@"", kSignalingMessageTypeKey:kSignalingMessageBYEKey };
    }
    
    return @{};
}

- (BOOL)isBye
{
    return [self.type isEqualToString:kSignalingMessageBYEKey];
}

- (BOOL)isIce
{
    return [self.type isEqualToString:kSignalingMessageICEKey];
}

- (BOOL)isSDP
{
    return [self.type isEqualToString:kSignalingMessageSDPKey];
}


@end
