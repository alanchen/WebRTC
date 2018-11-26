//
//  RTCConfiguration+WebRTCApp.h
//  BeFluent
//
//  Created by alan on 2018/11/23.
//  Copyright © 2018 alan. All rights reserved.
//

#import <WebRTC/RTCConfiguration.h>

@interface RTCConfiguration(WebRTCApp)

+(RTCConfiguration *)configurationWithIceServers:(NSArray *)iceServers;

@end
