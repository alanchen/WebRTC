//
//  WebRTCAppSignalingMessage.h
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebRTCAppSignalingMessage : NSObject

@property (nonatomic,strong) NSDictionary *payload;
@property (nonatomic,strong) NSString *sender;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *type; // ice sdp bye

@property (nonatomic,strong) NSDictionary *messageDictionary;
@property (nonatomic,strong) NSDictionary *ice;
@property (nonatomic,strong) NSDictionary *sdp;
@property (nonatomic,strong) NSString *sdpType;

+ (WebRTCAppSignalingMessage *)messageFromJSON:(NSDictionary *)json;

+ (NSDictionary *)createIcePayloadWithSender:(NSString *)sender
                                   candidate:(NSDictionary *)candidate;

+ (NSDictionary *)createSdpPayloadWithSender:(NSString *)sender
                                         sdp:(NSDictionary *)sdp;

+ (NSDictionary *)createByebyeWithSender:(NSString *)sender;

- (BOOL)isBye;
- (BOOL)isIce;
- (BOOL)isSDP;



@end
