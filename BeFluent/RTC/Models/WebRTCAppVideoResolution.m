//
//  WebRTCAppVideoResolution.m
//  BeFluent
//
//  Created by alan on 2018/11/21.
//  Copyright © 2018 alan. All rights reserved.
//

#import "WebRTCAppVideoResolution.h"

@implementation WebRTCAppVideoResolution

+(WebRTCAppVideoResolution *)resolutionWithWidth:(NSInteger)w height:(NSInteger)h
{
    WebRTCAppVideoResolution *resolution = [[WebRTCAppVideoResolution alloc] init];
    resolution.widthNum  =@(w);
    resolution.heightNum  =@(h);
    return  resolution;
}

-(void)setWidthNum:(NSNumber *)widthNum{
    _widthNum = widthNum;
    _width = [_widthNum integerValue];
}

-(void)setHeightNum:(NSNumber *)heightNum{
    _heightNum = heightNum;
    _height = [_heightNum integerValue];
}

-(NSString *) string
{
    NSString *resolutionString = [NSString stringWithFormat:@"%zdx%zd", self.width, self.height];
    return resolutionString;
}

- (BOOL)isEqual: (WebRTCAppVideoResolution *)other{
    return self.width == other.width && self.height == other.height;
}

- (NSUInteger)hash {
    return [[self.widthNum stringValue] hash] ^ [[self.heightNum stringValue] hash];
}

@end
