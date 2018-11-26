//
//  RTCConfiguration+WebRTCApp.m
//  BeFluent
//
//  Created by alan on 2018/11/23.
//  Copyright © 2018 alan. All rights reserved.
//

#import "RTCConfiguration+WebRTCApp.h"

@implementation RTCConfiguration(WebRTCApp)

+(RTCConfiguration *)configurationWithIceServers:(NSArray *)iceServers
{
    RTCConfiguration *config = [[RTCConfiguration alloc] init];
    RTCCertificate *pcert = [RTCCertificate generateCertificateWithParams:@{@"expires" : @100000,
                                                                            @"name" : @"RSASSA-PKCS1-v1_5"}];
    config.iceServers = iceServers;
    config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
    config.certificate = pcert;
    
    return  config;
}

@end
