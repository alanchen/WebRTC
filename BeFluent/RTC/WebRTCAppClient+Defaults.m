//
//  WebRTCAppClient+Defaults.m
//  BeFluent
//
//  Created by alan on 2018/9/28.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "WebRTCAppClient+Defaults.h"

@implementation WebRTCAppClient(Defaults)

- (RTCMediaConstraints *)defaultMediaAudioConstraints
{
    NSDictionary *mandatoryConstraints = @{};
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                                             optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
    NSDictionary *optionalConstraints = @{@"DtlsSrtpKeyAgreement":@"true"};
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:optionalConstraints];
    return constraints;
}

- (RTCIceServer *)defaultSTUNServer {
    return [[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302"]];
}

- (RTCMediaConstraints *)defaultOfferConstraints {
    NSDictionary *mandatoryConstraints = @{@"OfferToReceiveAudio":@"true",@"OfferToReceiveVideo":@"true"};
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                                             optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultOfferAudioOnlyConstraints {
    NSDictionary *mandatoryConstraints = @{@"OfferToReceiveAudio":@"true",@"OfferToReceiveVideo":@"false"};

    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                                             optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultAnswerConstraints {
    return [self defaultOfferConstraints];
}

- (RTCMediaConstraints *)defaultAnswerAudioOnlyConstraints {
    return [self defaultOfferAudioOnlyConstraints];
}


@end
