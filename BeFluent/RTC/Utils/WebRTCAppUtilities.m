//
//  WebRTCAppUtilities.m
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "WebRTCAppUtilities.h"

@implementation NSDictionary (WebRTCAppUtilities)

+ (NSDictionary *)dictionaryWithJSONString:(NSString *)jsonString {
    NSParameterAssert(jsonString.length > 0);
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dict =
    [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
    }
    return dict;
}

+ (NSDictionary *)dictionaryWithJSONData:(NSData *)jsonData {
    NSError *error = nil;
    NSDictionary *dict =
    [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
    }
    return dict;
}

-(NSString *)JSONSerialize
{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return myString;
}

@end

@implementation NSString (WebRTCAppUtilities)

-(id)JSONParse
{
    NSError *err;
    NSDictionary * response;
    id data = [self dataUsingEncoding:NSUTF8StringEncoding];
    response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"Error parsing JSON: %@", err.localizedDescription);
    }
    return response;
}

@end

@implementation NSURLConnection (WebRTCAppUtilities)

+ (void)sendAsyncRequest:(NSURLRequest *)request
       completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completionHandler
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (completionHandler) {
            completionHandler(response, data, error);
        }
    }];
    
    [sessionDataTask resume];
}

@end
