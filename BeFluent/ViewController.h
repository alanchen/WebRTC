//
//  ViewController.h
//  BeFluent
//
//  Created by alan on 2018/9/18.
//  Copyright © 2018年 alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebRTCAppClient.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) RTCCameraPreviewView *localVideoView;
@property (strong, nonatomic) RTCEAGLVideoView <RTCVideoRenderer> *remoteVideoView;
@property (strong, nonatomic) UILabel *label;

@end

