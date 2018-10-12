//
//  ViewController.h
//  BeFluent
//
//  Created by alan on 2018/9/18.
//  Copyright © 2018年 alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Firebase;

#import <AVFoundation/AVFoundation.h>
#import "WebRTCAppClient.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) RTCEAGLVideoView *localView;
@property (strong, nonatomic) RTCEAGLVideoView *remoteView;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;

@property (strong, nonatomic) UILabel *label;


@end

