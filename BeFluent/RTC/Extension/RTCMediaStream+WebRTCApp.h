//
//  RTCMediaStream+WebRTCApp.h
//  BeFluent
//
//  Created by alan on 2018/10/5.
//  Copyright © 2018 alan. All rights reserved.
//

#import <WebRTC/RTCMediaStream.h>

@interface RTCMediaStream(WebRTCApp)

-(void)debugLog;

-(RTCVideoTrack *)videoTrack;

-(RTCAudioTrack *)audioTrack;

@end
