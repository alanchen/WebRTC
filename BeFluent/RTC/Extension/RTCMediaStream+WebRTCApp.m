//
//  RTCMediaStream+WebRTCApp.m
//  BeFluent
//
//  Created by alan on 2018/10/5.
//  Copyright © 2018 alan. All rights reserved.
//

#import "RTCMediaStream+WebRTCApp.h"

@implementation RTCMediaStream(WebRTCApp)

-(void)debugLog
{
    NSInteger vc= (unsigned long)self.videoTracks.count;
    NSInteger ac= (unsigned long)self.audioTracks.count;
    NSLog(@"Received %lu video tracks and %lu audio tracks", vc,ac);
}

-(RTCVideoTrack *)videoTrack
{
    if( ![self.videoTracks count])
        return nil;
    
    RTCVideoTrack *videoTrack = self.videoTracks[0];
    return videoTrack;
}

-(RTCAudioTrack *)audioTrack
{
    if( ![self.audioTracks count])
        return nil;
    
    RTCAudioTrack *audioTrack = self.audioTracks[0];
    return audioTrack;
}

@end
