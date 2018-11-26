//
//  WebRTCAppClient.h
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "WebRTCAppHeader.h"
#import "WebRTCAppUtilities.h"
#import "RTCICECandidate+WebRTCApp.h"
#import "RTCSessionDescription+WebRTCApp.h"
#import "RTCICEServer+WebRTCApp.h"
#import "RTCMediaStream+WebRTCApp.h"
#import "WebRTCAppSignalingMessage.h"
#import "NSError+WebRTCApp.h"
#import "RTCPeerConnection+WebRTCAApp.h"
#import "RTCConfiguration+WebRTCApp.h"


typedef NS_ENUM(NSInteger, WebRTCAppClientState){
    WebRTCAppClientStateDisconnected,
    WebRTCAppClientStateConnecting,
    WebRTCAppClientStateConnected
};

typedef NS_ENUM(NSInteger, WebRTCAppClientStreamType){
    WebRTCAppClientStreamTypeAudio,
    WebRTCAppClientStreamTypeVideo
};

@class WebRTCAppClient;

@protocol WebRTCAppClientDelegate <NSObject>
@required
- (void)appClient:(WebRTCAppClient *)client didChangeState:(WebRTCAppClientState)state;
- (void)appClient:(WebRTCAppClient *)client didError:(NSError *)error;
- (void)appClient:(WebRTCAppClient *)client didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer;
- (void)appClient:(WebRTCAppClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

@optional
- (void)appClient:(WebRTCAppClient *)client didReceiveRemoteAudioTrack:(RTCAudioTrack *)remoteAudioTrack;
- (void)appClient:(WebRTCAppClient *)client didReceiveLocalAudioTrack:(RTCAudioTrack *)localAudioTrack;
- (void)appClient:(WebRTCAppClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;
- (void)appClient:(WebRTCAppClient *)client didChangeConnectionState:(RTCIceConnectionState)state;

@end

@interface WebRTCAppClient : NSObject

@property(nonatomic, readonly) WebRTCAppClientState state;
@property(nonatomic, readonly) WebRTCAppClientStreamType mediaStreamType;
@property(nonatomic, weak) id <WebRTCAppClientDelegate> delegate;

@property(nonatomic,strong,readonly) NSString *userId;
@property(nonatomic,strong,readonly) NSString *connectId; // As roomId.

+ (void)RTCInitialize;
+ (void)enableSpeaker;
+ (void)disableSpeaker;

- (instancetype)initWithDelegate:(id<WebRTCAppClientDelegate>)delegate
                            type:(WebRTCAppClientStreamType)type
                       connectId:(NSString *)connectId
                          userId:(NSString *)userId;

-(void)connectAsCaller;
-(void)connectAsCallee;
-(void)disconnect;

@end
