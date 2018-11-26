//
//  WebRTCAppVideoResolution.h
//  BeFluent
//
//  Created by alan on 2018/11/21.
//  Copyright © 2018 alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebRTCAppVideoResolution : NSObject

@property (nonatomic,strong)NSNumber *widthNum;
@property (nonatomic,strong)NSNumber *heightNum;

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;

+(WebRTCAppVideoResolution *)resolutionWithWidth:(NSInteger)w height:(NSInteger)h;
-(NSString *) string;

@end
