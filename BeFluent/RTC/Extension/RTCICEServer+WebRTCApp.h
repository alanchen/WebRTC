//
//  RTCICEServer+WebRTCApp.h
//  BeFluent
//
//  Created by alan on 2018/10/5.
//  Copyright © 2018 alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCICEServer.h"

@interface RTCICEServer(WebRTCApp)

+ (RTCICEServer *)serverFromJSONDictionary:(NSDictionary *)dictionary;

+ (NSArray *)serversFromJSONArray:(NSArray *)arr;

@end
