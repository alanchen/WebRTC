//
//  WebRTCAppClient.m
//  BeFluent
//
//  Created by alan on 2018/9/27.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "WebRTCAppClient.h"
#import "WebRTCAppClient+Defaults.h"
#import "WebRTCAppFIRDBManager.h"

@interface WebRTCAppClient() <RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate>

@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, assign) BOOL isCaller;
@property (nonatomic, assign) BOOL isSpeakerEnabled;

@end

@implementation WebRTCAppClient

- (instancetype)initWithDelegate:(id<WebRTCAppClientDelegate>)delegate
                            type:(WebRTCAppClientStreamType)type
                       connectId:(NSString *)connectId
                          userId:(NSString *)userId
{
    if (self = [super init]) {
        _delegate = delegate;
        _mediaStreamType = type;
        _connectId = connectId;
        _userId = userId;
        
        _factory = [[RTCPeerConnectionFactory alloc] init];
        _cameraPosition = AVCaptureDevicePositionFront;
        _isCaller = NO;
        _isSpeakerEnabled = NO;
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc");
    [self disconnect];
}

#pragma mark - Public

-(void)connectAsCaller
{
    self.isCaller = YES;
    [self connect];
}

-(void)connectAsCallee
{
    self.isCaller = NO;
    [self connect];
}

- (void)disconnect
{
    NSLog(@"WebRTCApp Disconnect");
    if (!_userId || !_connectId) {
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [weakSelf setConnectState:WebRTCAppClientStateDisconnected];

    [[WebRTCAppFIRDBManager sharedInstance] removeObserverThreadWithRoomId:_connectId];
    [[WebRTCAppFIRDBManager sharedInstance] deleteAllMessagesOfRoom:_connectId completion:nil];

    _connectId = nil;
    _userId = nil;
    _isCaller = NO;
    _delegate = nil;

    _peerConnection.delegate = nil;
    [_peerConnection close];
    _peerConnection = nil;
}

- (void)enableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    _isSpeakerEnabled = YES;
}

- (void)disableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    _isSpeakerEnabled = NO;
}

#pragma mark - Private

-(void)connect
{
    if (!_userId || !_connectId) {
        NSAssert(NO, @"No user ID or connect ID");
        return;
    }
    if (_state != WebRTCAppClientStateDisconnected) {
        return;
    }
    
    [self setConnectState:WebRTCAppClientStateConnecting];
    __weak __typeof(self) weakSelf = self;
    [[WebRTCAppFIRDBManager sharedInstance] getIceServersWithCompletion:^(NSArray *servers) {
        NSLog(@"ice servers %@",servers);
        
        NSArray *iceServers = @[[weakSelf defaultSTUNServer]];
        if([servers count]){
            iceServers = [RTCICEServer serversFromJSONArray:servers];
        }
        
        /////////////////////////////////////////
        // Create peerConnection with ice server
        /////////////////////////////////////////
        RTCMediaConstraints *constraints = [weakSelf defaultPeerConnectionConstraints];
        weakSelf.peerConnection = [weakSelf.factory peerConnectionWithICEServers:iceServers constraints:constraints delegate:weakSelf];
        
        ////////////////////////////////////////
        // Create local stream
        /////////////////////////////////////////
        RTCMediaStream* localStream = [weakSelf.factory mediaStreamWithLabel:@"ARDAMS"];
        if(weakSelf.mediaStreamType == WebRTCAppClientStreamTypeVideo){
            RTCVideoTrack *localVideoTrack = [weakSelf createLocalVideoTrackWithCameraPosition:weakSelf.cameraPosition];
            if (localVideoTrack) {
                [localStream addVideoTrack:localVideoTrack];
            }
        }
        
        RTCAudioTrack *localAudioTrack = [weakSelf createLocalAudioTrack];
        if (localAudioTrack) {
            [localStream addAudioTrack:localAudioTrack];
        }
        
        [weakSelf.peerConnection addStream:localStream];
        [weakSelf.delegate appClient:weakSelf didReceiveLocalStream:localStream];
        
        ////////////////////////////////////////
        // Process signaling messages
        /////////////////////////////////////////
        if(weakSelf.isCaller){
            // Clean messages in the queue.
            [[WebRTCAppFIRDBManager sharedInstance] deleteAllMessagesOfRoom:weakSelf.connectId completion:^{
                NSLog(@"Delete all FIR messages.");
                [weakSelf addSignalingMessagesObserver];
                [weakSelf createOffer];
            }];
        }else{
            [[WebRTCAppFIRDBManager sharedInstance] getAllMessagesOfRoom:weakSelf.connectId completion:^(NSEnumerator<FIRDataSnapshot *> *list) {
                NSLog(@"Get all FIR messages.");
                [list.allObjects enumerateObjectsUsingBlock:^(FIRDataSnapshot * _Nonnull snapshot, NSUInteger idx, BOOL * _Nonnull stop) {
                    WebRTCAppSignalingMessage *msg = [WebRTCAppSignalingMessage messageFromJSON:snapshot.value];
                    if([msg.sender isEqualToString:weakSelf.userId]){
                        [[WebRTCAppFIRDBManager sharedInstance] deleteDocRef:snapshot.ref];
                    }else{
                        [weakSelf processSignalingMessage:snapshot];
                    }
                }];

                [weakSelf addSignalingMessagesObserver];
            }];

        }
    }];
}

-(void)addSignalingMessagesObserver
{
    [[WebRTCAppFIRDBManager sharedInstance] observeThreadWithRoomId:self.connectId didAddWithBlock:^(FIRDataSnapshot *snapshot) {
        [self processSignalingMessage:snapshot];
    }];
}
-(void)processSignalingMessage:(FIRDataSnapshot *)snapshot
{
    id data = snapshot.value;
//    NSLog(@"Get a message %@",data);
    
    WebRTCAppSignalingMessage *msg = [WebRTCAppSignalingMessage messageFromJSON:data];
    if([msg.sender isEqualToString:self.userId]){
//      NSLog(@"Get a message belongs to me. IGNORE!");
        return ;
    }
    
    if(msg.ice){
        NSLog(@"Get an ICE message");
        RTCICECandidate *c = [RTCICECandidate candidateFromJSONDictionary:msg.ice];
        [self.peerConnection addICECandidate:c];
    }else if(msg.sdp){
        NSLog(@"Get a SDP message: %@", msg.sdpType);
        RTCSessionDescription *d = [RTCSessionDescription descriptionFromJSONDictionary:msg.sdp];
        [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:d];
    }
    
    [[WebRTCAppFIRDBManager sharedInstance] deleteDocRef:snapshot.ref];
}

-(void)createOffer
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.peerConnection createOfferWithDelegate:self constraints:[self defaultOfferConstraints]];
    });
}

-(void)createAnswer
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.peerConnection createAnswerWithDelegate:self constraints:[self defaultAnswerConstraints]];
    });
}

-(void)setConnectState:(WebRTCAppClientState) state;
{
    if(_state == state)
        return;
    
    _state = state;
    [self.delegate appClient:self didChangeState:_state];
}

#pragma mark - MediaStream

- (RTCAudioTrack *)createLocalAudioTrack
{
    RTCAudioTrack *localAudioTrack = [self.factory audioTrackWithID:@"ARDAMSa0"];
    return localAudioTrack;
}

- (RTCVideoTrack *)createLocalVideoTrackWithCameraPosition:(AVCaptureDevicePosition)position
{
    RTCVideoTrack *localVideoTrack = nil;
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_IPHONE
    NSArray *deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera];
    AVCaptureDeviceDiscoverySession *session =
    [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes
                                                           mediaType:AVMediaTypeVideo
                                                            position:position];
    NSString *cameraID = nil;
    for (AVCaptureDevice *captureDevice in [session devices]) {
        if (captureDevice.position == position) {
            cameraID = [captureDevice localizedName];
            break;
        }
    }
    NSAssert(cameraID, @"Unable to get the camera id");
    RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:cameraID];
    RTCMediaConstraints *mediaConstraints = [self defaultMediaStreamConstraints];
    RTCVideoSource *videoSource = [_factory videoSourceWithCapturer:capturer constraints:mediaConstraints];
    localVideoTrack = [_factory videoTrackWithID:@"ARDAMSv0" source:videoSource];
#endif
    return localVideoTrack;
}

-(void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition
{
    if(_mediaStreamType != WebRTCAppClientStreamTypeVideo)
        return;
    
    if(_cameraPosition == cameraPosition)
        return;
    
    if([_peerConnection.localStreams count] == 0)
        return;

    RTCMediaStream *localStream = _peerConnection.localStreams[0];
    if([localStream.videoTracks count] == 0)
        return;
    
    _cameraPosition = cameraPosition;
    [localStream removeVideoTrack:localStream.videoTracks[0]];
    RTCVideoTrack *localVideoTrack = [self createLocalVideoTrackWithCameraPosition:_cameraPosition];
    if (localVideoTrack) {
        [localStream addVideoTrack:localVideoTrack];
    }
    
    [_peerConnection removeStream:localStream];
    [_peerConnection addStream:localStream];
    
    [_delegate appClient:self didReceiveLocalStream:localStream];
}

#pragma mark - RTCSessionDescriptionDelegate

// Called when creating a session.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error
{
    NSLog(@"Did Create SDP: %@", sdp.type);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error || !sdp) {
            NSLog(@"Failed to create session description. Error: %@", error);
            [self.delegate appClient:self didError:[NSError errorCreateSDP]];
            [self disconnect];
            return;
        }
        [self.peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdp];
    });
}

// Called when setting a local or remote description.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error
{
    NSLog(@"Did Set SDP");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSLog(@"Failed to set session description. Error: %@", error);
            [self.delegate appClient:self didError:[NSError errorSetSDP]];
            [self disconnect];
            return;
        }
        
        if (peerConnection.signalingState == RTCSignalingHaveRemoteOffer){
            [self createAnswer];
        }else if (peerConnection.signalingState == RTCSignalingHaveLocalPrAnswer){
            
        }else if (peerConnection.signalingState == RTCSignalingHaveLocalOffer){
            RTCSessionDescription *sdp = peerConnection.localDescription;
            if(sdp){
                id msg = [WebRTCAppSignalingMessage createSdpPayloadWithSender:self.userId sdp:[sdp toJSONDictionary]];
                [[WebRTCAppFIRDBManager sharedInstance] sendMessage:msg toRoom:self.connectId];
            }
        }else if (peerConnection.signalingState == RTCSignalingHaveRemotePrAnswer){
            
        }else if (peerConnection.signalingState == RTCSignalingStable) {
            RTCSessionDescription *sdp = peerConnection.localDescription;
            if( [sdp.type isEqualToString:@"answer"] ){
                id msg = [WebRTCAppSignalingMessage createSdpPayloadWithSender:self.userId sdp:[sdp toJSONDictionary]];
                [[WebRTCAppFIRDBManager sharedInstance] sendMessage:msg toRoom:self.connectId];
            }
        }
    });
}

#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged
{
    NSLog(@"Signaling state changed: %d", stateChanged);
    [peerConnection logRTCSignalingState];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [stream debugLog];
        [weakSelf.delegate appClient:weakSelf didReceiveRemoteStream:stream];
    });
    
    if (self.isSpeakerEnabled)
        [self enableSpeaker];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream
{
    NSLog(@"Stream was removed.");
}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{
//    NSLog(@"WARNING: Renegotiation needed but unimplemented.");
//    NSLog(@"PCO onRenegotiationNeeded - ignoring because AppRTC has a "
//          "predefined negotiation strategy");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState
{
    NSLog(@"ICE state changed: %d", newState);
    [peerConnection logRTCICEConnectionState];
    
    if([peerConnection isBadConnectState]){
        [self disconnect];
    }else if(peerConnection.iceConnectionState == RTCICEConnectionConnected ||
             peerConnection.iceConnectionState == RTCICEConnectionCompleted){
        [self setConnectState:WebRTCAppClientStateConnected];
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState
{
    NSLog(@"ICE gathering state changed: %d", newState);
    [peerConnection logRTCICEGatheringState];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        id msg = [WebRTCAppSignalingMessage createIcePayloadWithSender:self.userId candidate:[candidate toJSONDictionary]];
        [[WebRTCAppFIRDBManager sharedInstance] sendMessage:msg toRoom:self.connectId];
    });
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection didOpenDataChannel:(RTCDataChannel*)dataChannel
{
    
}

@end
