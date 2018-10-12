//
//  NSError+WebRTCApp.h
//  BeFluent
//
//  Created by alan on 2018/10/1.
//  Copyright © 2018 alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError(WebRTCApp)

+(NSError *)errorSetSDP;
+(NSError *)errorCreateSDP;
+(NSError *)errorUnknown;
+(NSError *)errorNetwork;


@end
