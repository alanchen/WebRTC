//
//  WebRTCAppClient+Defaults.h
//  BeFluent
//
//  Created by alan on 2018/9/28.
//  Copyright © 2018年 alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRTCAppClient.h"

@interface WebRTCAppClient(Defaults)

- (RTCMediaConstraints *)defaultMediaAudioConstraints;
- (RTCMediaConstraints *)defaultPeerConnectionConstraints;
- (RTCIceServer *)defaultSTUNServer;

- (RTCMediaConstraints *)defaultAnswerConstraints;
- (RTCMediaConstraints *)defaultAnswerAudioOnlyConstraints;

- (RTCMediaConstraints *)defaultOfferConstraints;
- (RTCMediaConstraints *)defaultOfferAudioOnlyConstraints;

@end


