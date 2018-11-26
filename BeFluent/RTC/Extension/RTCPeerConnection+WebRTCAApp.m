//
//  RTCPeerConnection+WebRTCAApp.m
//  BeFluent
//
//  Created by alan on 2018/10/10.
//  Copyright © 2018 alan. All rights reserved.
//

#import "RTCPeerConnection+WebRTCAApp.h"

@implementation  RTCPeerConnection(WebRTCApp)

-(void)logRTCSignalingState
{
    NSString *desc = @"";
    
    if(self.signalingState == RTCSignalingStateStable){
        desc = @"RTCSignalingStateStable";
    }else if(self.signalingState == RTCSignalingStateHaveLocalOffer){
        desc = @"RTCSignalingStateHaveLocalOffer";
    }else if(self.signalingState == RTCSignalingStateHaveLocalPrAnswer){
        desc = @"RTCSignalingStateHaveLocalPrAnswer";
    }else if(self.signalingState == RTCSignalingStateHaveRemoteOffer){
        desc = @"RTCSignalingStateHaveRemoteOffer";
    }else if(self.signalingState == RTCSignalingStateHaveRemotePrAnswer){
        desc = @"RTCSignalingStateHaveRemotePrAnswer";
    }else if(self.signalingState == RTCSignalingStateClosed){
        desc = @"RTCSignalingStateClosed";
    }
    
    NSLog(@"Signaling state: %@", desc);
}

-(void)logRTCICEConnectionState
{
    NSString *desc = @"";
    
    if(self.iceConnectionState == RTCIceConnectionStateNew){
        desc = @"RTCICEConnectionNew";
    }else if(self.iceConnectionState == RTCIceConnectionStateChecking){
        desc = @"RTCICEConnectionChecking";
    }else if(self.iceConnectionState == RTCIceConnectionStateConnected){
        desc = @"RTCICEConnectionConnected";
    }else if(self.iceConnectionState == RTCIceConnectionStateCompleted){
        desc = @"RTCICEConnectionCompleted";
    }else if(self.iceConnectionState == RTCIceConnectionStateFailed){
        desc = @"RTCICEConnectionFailed";
    }else if(self.iceConnectionState == RTCIceConnectionStateDisconnected){
        desc = @"RTCICEConnectionDisconnected";
    }else if(self.iceConnectionState == RTCIceConnectionStateClosed){
        desc = @"RTCICEConnectionClosed";
    }else if(self.iceConnectionState == RTCIceConnectionStateCount){
        desc = @"RTCIceConnectionStateCount";
    }
    
    NSLog(@"ICE state: %@", desc);
}

-(void)logRTCICEGatheringState
{
    NSString *desc = @"";
    
    if(self.iceGatheringState == RTCIceGatheringStateNew){
        desc = @"RTCIceGatheringStateNew";
    }else if(self.iceGatheringState == RTCIceGatheringStateGathering){
        desc = @"RTCIceGatheringStateGathering";
    }else if(self.iceGatheringState == RTCIceGatheringStateComplete){
        desc = @"RTCIceGatheringStateComplete";
    }
    
    NSLog(@"ICE gathering state: %@", desc);
}

@end
