//
//  WebRTCAppCaptureController.h
//  BeFluent
//
//  Created by alan on 2018/11/21.
//  Copyright © 2018 alan. All rights reserved.
//

#import <WebRTC/RTCCameraVideoCapturer.h>
#import "WebRTCAppVideoResolution.h"

@interface WebRTCAppCaptureController : NSObject

@property (nonatomic,strong) RTCCameraVideoCapturer *capturer;

- (instancetype)initWithCapturer:(RTCCameraVideoCapturer *)capturer; // 640 480

- (instancetype)initWithCapturer:(RTCCameraVideoCapturer *)capturer
                      resolution:(WebRTCAppVideoResolution *)resolution;
- (void)startCapture;
- (void)stopCapture;
- (void)switchCamera;
- (void)switchToResolution:(WebRTCAppVideoResolution *) r;

+ (NSArray<WebRTCAppVideoResolution *>  *)availableVideoResolutions;

@end
