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
    
    if(self.signalingState == RTCSignalingStable){
        desc = @"RTCSignalingStable";
    }else if(self.signalingState == RTCSignalingHaveLocalOffer){
        desc = @"RTCSignalingHaveLocalOffer";
    }else if(self.signalingState == RTCSignalingHaveLocalPrAnswer){
        desc = @"RTCSignalingHaveLocalPrAnswer";
    }else if(self.signalingState == RTCSignalingHaveRemoteOffer){
        desc = @"RTCSignalingHaveRemoteOffer";
    }else if(self.signalingState == RTCSignalingHaveRemotePrAnswer){
        desc = @"RTCSignalingHaveRemotePrAnswer";
    }else if(self.signalingState == RTCSignalingClosed){
        desc = @"RTCSignalingClosed";
    }
    
    NSLog(@"Signaling state: %@", desc);
}

-(void)logRTCICEConnectionState
{
    NSString *desc = @"";
    
    if(self.iceConnectionState == RTCICEConnectionNew){
        desc = @"RTCICEConnectionNew";
    }else if(self.iceConnectionState == RTCICEConnectionChecking){
        desc = @"RTCICEConnectionChecking";
    }else if(self.iceConnectionState == RTCICEConnectionConnected){
        desc = @"RTCICEConnectionConnected";
    }else if(self.iceConnectionState == RTCICEConnectionCompleted){
        desc = @"RTCICEConnectionCompleted";
    }else if(self.iceConnectionState == RTCICEConnectionFailed){
        desc = @"RTCICEConnectionFailed";
    }else if(self.iceConnectionState == RTCICEConnectionDisconnected){
        desc = @"RTCICEConnectionDisconnected";
    }else if(self.iceConnectionState == RTCICEConnectionClosed){
        desc = @"RTCICEConnectionClosed";
    }else if(self.iceConnectionState == RTCICEConnectionMax){
        desc = @"RTCICEConnectionMax";
    }
    
    NSLog(@"ICE state: %@", desc);
}

-(void)logRTCICEGatheringState
{
    NSString *desc = @"";
    
    if(self.iceGatheringState == RTCICEGatheringNew){
        desc = @"RTCICEGatheringNew";
    }else if(self.iceGatheringState == RTCICEGatheringGathering){
        desc = @"RTCICEGatheringGathering";
    }else if(self.iceGatheringState == RTCICEGatheringComplete){
        desc = @"RTCICEGatheringComplete";
    }
    
    NSLog(@"ICE gathering state: %@", desc);
}

-(BOOL)isBadConnectState
{
    if(self.iceConnectionState == RTCICEConnectionFailed ||
       self.iceConnectionState == RTCICEConnectionDisconnected ||
       self.iceConnectionState == RTCICEConnectionClosed){
        return YES;
    }
    
    return NO;
}

@end
