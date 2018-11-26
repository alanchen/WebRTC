//
//  RTCICECandidate+WebRTCApp.h
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import <WebRTC/RTCIceCandidate.h>

@interface RTCIceCandidate(WebRTCApp)

+ (RTCIceCandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toJSONDictionary;

@end
