//
//  WebRTCAppUtilities.h
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (WebRTCAppUtilities)

+ (NSDictionary *)dictionaryWithJSONString:(NSString *)jsonString;
+ (NSDictionary *)dictionaryWithJSONData:(NSData *)jsonData;
- (NSString *)JSONSerialize;

@end

@interface NSString (WebRTCAppUtilities)

- (id)JSONParse;

@end

@interface NSURLConnection (WebRTCAppUtilities)

+ (void)sendAsyncRequest:(NSURLRequest *)request
       completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completionHandler;

@end
