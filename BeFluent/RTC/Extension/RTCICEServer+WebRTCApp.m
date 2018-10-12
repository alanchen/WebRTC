//
//  RTCICEServer+WebRTCApp.m
//  BeFluent
//
//  Created by alan on 2018/10/5.
//  Copyright © 2018 alan. All rights reserved.
//

#import "RTCICEServer+WebRTCApp.h"

@implementation RTCICEServer(WebRTCApp)

+ (RTCICEServer *)serverFromJSONDictionary:(NSDictionary *)dictionary
{
    NSString *url = dictionary[@"url"];
    NSString *credential = dictionary[@"credential"];
    NSString *username = dictionary[@"username"];
    if(!url || [url length] ==0){
        return nil;
    }

    return [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:url] username:username password:credential];
}

+ (NSArray *)serversFromJSONArray:(NSArray *)arr
{
    NSMutableArray *result = [@[] mutableCopy];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RTCICEServer *server = [RTCICEServer serverFromJSONDictionary:obj];
        if(server)  [result addObject:server];
    }];
    
    return  result;
}

@end
