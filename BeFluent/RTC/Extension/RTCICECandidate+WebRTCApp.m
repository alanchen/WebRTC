//
//  RTCICECandidate+WebRTCApp.m
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "RTCICECandidate+WebRTCApp.h"

static NSString const *kRTCICECandidateMidKey = @"sdpMid";
static NSString const *kRTCICECandidateMLineIndexKey = @"sdpMLineIndex";
static NSString const *kRTCICECandidateSdpKey = @"candidate";

@implementation RTCICECandidate(WebRTCApp)

+ (RTCICECandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary
{
    NSString *mid = dictionary[kRTCICECandidateMidKey];
    NSString *sdp = dictionary[kRTCICECandidateSdpKey];
    NSNumber *num = dictionary[kRTCICECandidateMLineIndexKey];
    NSInteger mLineIndex = [num integerValue];
    
    return [[RTCICECandidate alloc] initWithMid:mid index:mLineIndex sdp:sdp];
}

- (NSDictionary *)toJSONDictionary
{
    NSDictionary *json = @{kRTCICECandidateMLineIndexKey : @(self.sdpMLineIndex),
                           kRTCICECandidateMidKey : self.sdpMid,
                           kRTCICECandidateSdpKey : self.sdp};
    
    return json;
}

@end
