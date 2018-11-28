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
#import "WebRTCAppCaptureController.h"

static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";
static int const kKbpsMultiplier = 1000;

@interface WebRTCAppClient() <RTCPeerConnectionDelegate>
@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCVideoTrack *localVideoTrack;
@property (nonatomic, assign) BOOL isCaller;
@end

@implementation WebRTCAppClient

+(void)RTCInitialize
{
    NSDictionary *fieldTrials = @{};
    RTCInitFieldTrialDictionary(fieldTrials);
    RTCInitializeSSL();
    RTCSetupInternalTracer();
}

+(void)enableSpeaker
{
    [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeAudioSession
                                 block:^
     {
         RTCAudioSession *session = [RTCAudioSession sharedInstance];
         [session lockForConfiguration];
         NSError *error = nil;
         if (![session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error]) {
             RTCLogError(@"Error overriding output port: %@", error.localizedDescription);
         }
         [session unlockForConfiguration];
     }];
}

+(void)disableSpeaker
{
    [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeAudioSession
                                 block:^
     {
         RTCAudioSession *session = [RTCAudioSession sharedInstance];
         [session lockForConfiguration];
         NSError *error = nil;
         if (![session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error]) {
             RTCLogError(@"Error overriding output port: %@", error.localizedDescription);
         }
         [session unlockForConfiguration];
     }];
}

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
        
        RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
        RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
        RTCVideoCodecInfo *encodeInfo = [[RTCDefaultVideoEncoderFactory supportedCodecs] firstObject];
        if(encodeInfo) { encoderFactory.preferredCodec = encodeInfo; }
        _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory
                                                             decoderFactory:decoderFactory];
        _isCaller = NO;
    }
    
    return self;
}

- (void)dealloc
{
    RTCLog(@"WebRTCAppClient dealloc");
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
    if (!_userId || !_connectId) {
        return;
    }

    RTCLog(@"WebRTCApp Disconnect");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[WebRTCAppFIRDBManager sharedInstance] removeCurrentObserver];
    [[WebRTCAppFIRDBManager sharedInstance] deleteAllMessagesOfRoom:_connectId completion:nil];
    [self setConnectState:WebRTCAppClientStateDisconnected];
    [self sendBye];
    
    _connectId = nil;
    _userId = nil;
    _isCaller = NO;
    _delegate = nil;
    _localVideoTrack = nil;
    
    _peerConnection.delegate = nil;
    [_peerConnection close];
    _peerConnection = nil;
}

- (void)setMaxBitrateForPeerConnectionVideoSender:(NSInteger)maxBitrate
{
    for (RTCRtpSender *sender in _peerConnection.senders) {
        if (sender.track != nil) {
            if ([sender.track.kind isEqualToString:kARDVideoTrackKind]) {
                [self setMaxBitrate:@(maxBitrate) forVideoSender:sender];
            }
        }
    }
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
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disconnect)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [self setConnectState:WebRTCAppClientStateConnecting];
    
    __weak __typeof(self) weakSelf = self;
    [[WebRTCAppFIRDBManager sharedInstance] getIceServersWithCompletion:^(NSArray *servers) {
        NSLog(@"ice servers %@",servers);
        
        NSArray *iceServers = @[[weakSelf defaultSTUNServer]];
        if([servers count]){
            iceServers = [RTCIceServer serversFromJSONArray:servers];
        }
        
        /////////////////////////////////////////
        // Create peerConnection with ice server
        /////////////////////////////////////////
        RTCMediaConstraints *constraints = [weakSelf defaultPeerConnectionConstraints];
        RTCConfiguration *config = [RTCConfiguration configurationWithIceServers:iceServers];
        [weakSelf.factory peerConnectionWithConfiguration:config
                                          constraints:constraints
                                             delegate:weakSelf];
        weakSelf.peerConnection = [weakSelf.factory peerConnectionWithConfiguration:config constraints:constraints delegate:weakSelf];
        
        ////////////////////////////////////////
        // Create local stream
        /////////////////////////////////////////
        [weakSelf createMediaSenders];

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
    __weak __typeof(self) weakSelf = self;
    [[WebRTCAppFIRDBManager sharedInstance] observeThreadWithRoomId:self.connectId
                                                    didAddWithBlock:^(FIRDataSnapshot *snapshot)
     {
         [weakSelf processSignalingMessage:snapshot];
     }];
}
-(void)processSignalingMessage:(FIRDataSnapshot *)snapshot
{
    id data = snapshot.value;
    
    WebRTCAppSignalingMessage *msg = [WebRTCAppSignalingMessage messageFromJSON:data];
    NSLog(@"Process a message. type: %@", msg.type);

    if([msg.sender isEqualToString:self.userId]){
//      NSLog(@"Get a message belongs to me. IGNORE!");
        return;
    }
    
    if([msg isIce]){
        RTCIceCandidate *c = [RTCIceCandidate candidateFromJSONDictionary:msg.ice];
        [self.peerConnection addIceCandidate:c];
    }else if([msg isSDP]){
        RTCSessionDescription *d = [RTCSessionDescription descriptionFromJSONDictionary:msg.sdp];
        __weak __typeof(self) weakSelf = self;
        [self.peerConnection setRemoteDescription:d completionHandler:^(NSError * _Nullable error) {
            [weakSelf peerConnection:weakSelf.peerConnection didSetSessionDescriptionWithError:error];
        }];
    }else if([msg isBye]){
        [self disconnect];
    }
    
    [[WebRTCAppFIRDBManager sharedInstance] deleteDocRef:snapshot.ref];
}

-(void)createOffer
{
    RTCMediaConstraints *constraints = nil;
    if(self.mediaStreamType == WebRTCAppClientStreamTypeAudio){
        constraints = [self defaultOfferAudioOnlyConstraints];
    }else{
        constraints = [self defaultOfferConstraints];
    }
    
    __weak __typeof(self) weakSelf = self;
    [self.peerConnection offerForConstraints:constraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        [weakSelf peerConnection:weakSelf.peerConnection didCreateSessionDescription:sdp error:error];
    }];
}

-(void)createAnswer
{
    RTCMediaConstraints *constraints = nil;
    if(self.mediaStreamType == WebRTCAppClientStreamTypeAudio){
        constraints = [self defaultAnswerAudioOnlyConstraints];
    }else{
        constraints = [self defaultAnswerConstraints];
    }
    
    __weak __typeof(self) weakSelf = self;
    [self.peerConnection answerForConstraints:constraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        [weakSelf peerConnection:weakSelf.peerConnection didCreateSessionDescription:sdp error:error];
    }];
}

-(void)setConnectState:(WebRTCAppClientState) state;
{
    if(_state == state)
        return;
    
    _state = state;
    [self.delegate appClient:self didChangeState:_state];
}

-(void)sendBye
{
    if(_userId && _connectId){
        id byeMsg = [WebRTCAppSignalingMessage createByebyeWithSender:_userId];
        FIRDatabaseReference *ref = [[WebRTCAppFIRDBManager sharedInstance] sendMessage:byeMsg toRoom:_connectId];
        [[WebRTCAppFIRDBManager sharedInstance] deleteDocRef:ref];
    }
}

#pragma mark - MediaStream

- (RTCRtpTransceiver *)videoTransceiver
{
    for (RTCRtpTransceiver *transceiver in _peerConnection.transceivers) {
        if (transceiver.mediaType == RTCRtpMediaTypeVideo) {
            return transceiver;
        }
    }
    return nil;
}

- (RTCRtpTransceiver *)audioTransceiver
{
    for (RTCRtpTransceiver *transceiver in _peerConnection.transceivers) {
        if (transceiver.mediaType == RTCRtpMediaTypeAudio) {
            return transceiver;
        }
    }
    return nil;
}

- (RTCVideoTrack *)createLocalVideoTrack
{
    RTCVideoSource *source = [_factory videoSource];
    RTCCameraVideoCapturer *capturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:source];
    [_delegate appClient:self didCreateLocalCapturer:capturer];
    return [_factory videoTrackWithSource:source trackId:kARDVideoTrackId];
}

- (RTCAudioTrack *)createLocalAudioTrack
{
    RTCMediaConstraints *constraints = [self defaultMediaAudioConstraints];
    RTCAudioSource *source = [_factory audioSourceWithConstraints:constraints];
    RTCAudioTrack *track = [_factory audioTrackWithSource:source trackId:kARDAudioTrackId];
    return track;
}

- (void)createMediaSenders
{
    RTCAudioTrack *track = [self createLocalAudioTrack];
    if (track) {
        [_peerConnection addTrack:track streamIds:@[ kARDMediaStreamId ]];
        if([_delegate respondsToSelector:@selector(appClient:didReceiveLocalAudioTrack:)]){
            [_delegate appClient:self didReceiveLocalAudioTrack:track];
        }
    }
    
    if(self.mediaStreamType == WebRTCAppClientStreamTypeVideo){
        _localVideoTrack = [self createLocalVideoTrack];
        if (_localVideoTrack) {
            [_peerConnection addTrack:_localVideoTrack streamIds:@[ kARDMediaStreamId ]];
            if([_delegate respondsToSelector:@selector(appClient:didReceiveLocalVideoTrack:)]){
                [_delegate appClient:self didReceiveLocalVideoTrack:_localVideoTrack];
            }
            // We can set up rendering for the remote track right away since the transceiver already has an
            // RTCRtpReceiver with a track. The track will automatically get unmuted and produce frames
            // once RTP is received.
            RTCVideoTrack *track = (RTCVideoTrack *)([self videoTransceiver].receiver.track);
            [_delegate appClient:self didReceiveRemoteVideoTrack:track];

            RTCAudioTrack *track_a = (RTCAudioTrack *)([self audioTransceiver].receiver.track);
            if([_delegate respondsToSelector:@selector(appClient:didReceiveRemoteAudioTrack:)]){
                [_delegate appClient:self didReceiveRemoteAudioTrack:track_a];
            }
        }
    }
}

- (void)setMaxBitrate:(NSNumber *)maxBitrate forVideoSender:(RTCRtpSender *)sender {
    if (maxBitrate.intValue <= 0) {
        return;
    }
    
    RTCRtpParameters *parametersToModify = sender.parameters;
    for (RTCRtpEncodingParameters *encoding in parametersToModify.encodings) {
        encoding.maxBitrateBps = @(maxBitrate.intValue * kKbpsMultiplier);
    }
    [sender setParameters:parametersToModify];
}

#pragma mark - RTCSessionDescriptionDelegate

// Called when creating a session.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error
{
    RTCLog(@"Did Create SDP: %@", [RTCSessionDescription stringForType:sdp.type]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error || !sdp) {
            RTCLog(@"Failed to create session description. Error: %@", error);
            [self.delegate appClient:self didError:[NSError errorCreateSDP]];
            [self disconnect];
            return;
        }
        __weak __typeof(self) weakSelf = self;
        [self.peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
            [weakSelf peerConnection:weakSelf.peerConnection didSetSessionDescriptionWithError:error];
        }];
        
        id msg = [WebRTCAppSignalingMessage createSdpPayloadWithSender:self.userId sdp:[sdp toJSONDictionary]];
        [[WebRTCAppFIRDBManager sharedInstance] sendMessage:msg toRoom:self.connectId];
        [self setMaxBitrateForPeerConnectionVideoSender:1000]; // 1 mb
    });
}

// Called when setting a local or remote description.
- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error
{
    RTCLog(@"Did Set SDP");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            RTCLog(@"Failed to set session description. Error: %@", error);
            [self.delegate appClient:self didError:[NSError errorSetSDP]];
            [self disconnect];
            return;
        }
        
        // If we're answering and we've just set the remote offer we need to create
        // an answer and set the local description.
        if (!self.isCaller && !self.peerConnection.localDescription) {
            [self createAnswer];
        }
    });
}

#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged
{
    RTCLog(@"Signaling state changed: %ld", (long)stateChanged);
    [peerConnection logRTCSignalingState];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection  didAddStream:(RTCMediaStream *)stream
{
    RTCLog(@"Stream with %lu video tracks and %lu audio tracks was added.",
           (unsigned long)stream.videoTracks.count,
           (unsigned long)stream.audioTracks.count);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream
{
    RTCLog(@"Stream was removed.");
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection
{
    RTCLog(@"WARNING: Renegotiation needed but unimplemented.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didStartReceivingOnTransceiver:(RTCRtpTransceiver *)transceiver
{
    RTCMediaStreamTrack *track = transceiver.receiver.track;
    RTCLog(@"Now receiving %@ on track %@.", track.kind, track.trackId);
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection didOpenDataChannel:(RTCDataChannel*)dataChannel
{
    RTCLog(@"didOpenDataChannel");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState
{
    RTCLog(@"ICE state changed: %ld", (long)newState);
    [peerConnection logRTCICEConnectionState];
    
    if(peerConnection.iceConnectionState == RTCIceConnectionStateConnected ||
       peerConnection.iceConnectionState == RTCIceConnectionStateCompleted) {
        [self setConnectState:WebRTCAppClientStateConnected];
    }else  if(peerConnection.iceConnectionState == RTCIceConnectionStateFailed ||
              peerConnection.iceConnectionState == RTCIceConnectionStateDisconnected ||
              peerConnection.iceConnectionState == RTCIceConnectionStateClosed) {
        [self disconnect];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(appClient:didChangeConnectionState:)]){
            [self.delegate appClient:self didChangeConnectionState:newState];
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState
{
    RTCLog(@"ICE gathering state changed: %ld", (long)newState);
    [peerConnection logRTCICEGatheringState];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    dispatch_async(dispatch_get_main_queue(), ^{
        id msg = [WebRTCAppSignalingMessage createIcePayloadWithSender:self.userId candidate:[candidate toJSONDictionary]];
        [[WebRTCAppFIRDBManager sharedInstance] sendMessage:msg toRoom:self.connectId];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates
{
    RTCLog(@"didRemoveIceCandidates");
}

@end
