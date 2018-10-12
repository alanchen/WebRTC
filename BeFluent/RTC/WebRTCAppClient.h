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
- (void)appClient:(WebRTCAppClient *)client didChangeState:(WebRTCAppClientState)state;
- (void)appClient:(WebRTCAppClient *)client didReceiveLocalStream:(RTCMediaStream *)localStream;
- (void)appClient:(WebRTCAppClient *)client didReceiveRemoteStream:(RTCMediaStream *)remoteStream;
- (void)appClient:(WebRTCAppClient *)client didError:(NSError *)error;
@end

@interface WebRTCAppClient : NSObject

@property(nonatomic, readonly) WebRTCAppClientState state;
@property(nonatomic, readonly) WebRTCAppClientStreamType mediaStreamType;
@property(nonatomic, weak) id< WebRTCAppClientDelegate> delegate;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

@property(nonatomic,strong,readonly) NSString *userId;
@property(nonatomic,strong,readonly) NSString *connectId; // As roomId.

- (instancetype)initWithDelegate:(id<WebRTCAppClientDelegate>)delegate
                            type:(WebRTCAppClientStreamType)type
                       connectId:(NSString *)connectId
                          userId:(NSString *)userId;

-(void)connectAsCaller;
-(void)connectAsCallee;
-(void)disconnect;

-(void)enableSpeaker;
-(void)disableSpeaker;

@end
