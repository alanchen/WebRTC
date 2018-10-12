//
//  FIRApp+WebRTCApp.h
//  BeFluent
//
//  Created by alan on 2018/10/12.
//  Copyright © 2018 alan. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;

@interface FIRApp(WebRTCApp)

+(FIROptions *)webRTCOptions;

+(FIRApp *)webRTCApp;

@end
