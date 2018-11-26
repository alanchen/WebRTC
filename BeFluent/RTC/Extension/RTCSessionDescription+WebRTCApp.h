//
//  RTCSessionDescription+WebRTCApp.h
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import <WebRTC/RTCSessionDescription.h>

@interface RTCSessionDescription(WebRTCApp)

+ (RTCSessionDescription *)descriptionFromJSONDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toJSONDictionary;

@end
