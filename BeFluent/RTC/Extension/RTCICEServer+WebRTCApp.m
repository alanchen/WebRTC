//
//  RTCICEServer+WebRTCApp.m
//  BeFluent
//
//  Created by alan on 2018/10/5.
//  Copyright © 2018 alan. All rights reserved.
//

#import "RTCICEServer+WebRTCApp.h"

@implementation RTCIceServer(WebRTCApp)

+ (RTCIceServer *)serverFromJSONDictionary:(NSDictionary *)dictionary
{
    NSString *url = dictionary[@"url"];
    NSString *credential = dictionary[@"credential"]?: @"";
    NSString *username = dictionary[@"username"]?: @"";
    if(!url || [url length] ==0){
        return nil;
    }

    return [[RTCIceServer alloc] initWithURLStrings:@[url] username:username credential:credential];
}

+ (NSArray *)serversFromJSONArray:(NSArray *)arr
{
    NSMutableArray *result = [@[] mutableCopy];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RTCIceServer *server = [RTCIceServer serverFromJSONDictionary:obj];
        if(server)  [result addObject:server];
    }];
    
    return  result;
}

@end
