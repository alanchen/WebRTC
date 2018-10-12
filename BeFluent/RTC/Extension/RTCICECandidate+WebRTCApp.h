//
//  RTCICECandidate+WebRTCApp.h
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "RTCICECandidate.h"

@interface RTCICECandidate(WebRTCApp)

+ (RTCICECandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toJSONDictionary;

@end
