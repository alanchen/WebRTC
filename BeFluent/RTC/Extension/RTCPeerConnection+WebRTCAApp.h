//
//  RTCPeerConnection+WebRTCAApp.h
//  BeFluent
//
//  Created by alan on 2018/10/10.
//  Copyright © 2018 alan. All rights reserved.
//

#import "RTCPeerConnection.h"

@interface RTCPeerConnection(WebRTCApp)

-(void)logRTCSignalingState;

-(void)logRTCICEConnectionState;

-(void)logRTCICEGatheringState;

-(BOOL)isBadConnectState;

@end
