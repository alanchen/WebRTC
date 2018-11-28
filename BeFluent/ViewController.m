//
//  ViewController.m
//  BeFluent
//
//  Created by alan on 2018/9/18.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "ViewController.h"
#import "WebRTCAppFIRDBManager.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import "WebRTCAppClient.h"
#import "WebRTCAppCaptureController.h"

static NSString *userId = @""; // random
static NSString *roomId = @"30678";

@interface ViewController () <WebRTCAppClientDelegate, RTCVideoViewDelegate>
@property (nonatomic, strong) RTCVideoTrack *remoteVideoTrack;
@property (nonatomic,strong) WebRTCAppClient *connection;
@property (nonatomic,strong) WebRTCAppCaptureController *captureController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    userId = [[NSUUID UUID].UUIDString substringWithRange:NSMakeRange(0,8)];
    [self layoutInit];
    [[WebRTCAppFIRDBManager sharedInstance] signInWithToken:nil completion:nil];
}

#pragma mark - Action

- (void)connectAsCallerAction
{
    if(self.connection){
        return;
    }

    self.connection = [[WebRTCAppClient alloc] initWithDelegate:self
                                                           type:WebRTCAppClientStreamTypeVideo
                                                      connectId:roomId
                                                         userId:userId];
    
    [self.connection connectAsCaller];
}

- (void)connectAsCalleeAction
{
    if(self.connection){
        return;
    }
    
    self.connection = [[WebRTCAppClient alloc] initWithDelegate:self
                                                           type:WebRTCAppClientStreamTypeVideo
                                                      connectId:roomId
                                                         userId:userId];
    [self.connection connectAsCallee];
}

- (void)audioCallerAction
{
    if(self.connection){
        return;
    }
    
    self.connection = [[WebRTCAppClient alloc] initWithDelegate:self
                                                           type:WebRTCAppClientStreamTypeAudio
                                                      connectId:roomId
                                                         userId:userId];
    
    [self.connection connectAsCaller];
}

- (void)audioCalleeAction
{
    if(self.connection){
        return;
    }
    
    self.connection = [[WebRTCAppClient alloc] initWithDelegate:self
                                                           type:WebRTCAppClientStreamTypeAudio
                                                      connectId:roomId
                                                         userId:userId];
    [self.connection connectAsCallee];
}

- (void)closeAction
{
    [self removeStreamRender];
    [self.connection disconnect];
    self.connection = nil;
}

- (void)swapAction
{
    [self.captureController switchCamera];
}

-(void)speakerON
{
    [WebRTCAppClient enableSpeaker];
}

-(void)speakerOFF
{
    [WebRTCAppClient disableSpeaker];
}

#pragma mark - Private

-(UIButton *)btnWithName:(NSString *)title x:(CGFloat)x y:(CGFloat)y action:(SEL)action
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
//    [b setAdjustsImageWhenHighlighted:YES];
    b.frame = CGRectMake(x, y, 150, 50);
    [b setTitle:title forState:UIControlStateNormal];
    [b setShowsTouchWhenHighlighted:YES];
    [b setBackgroundColor:[UIColor redColor]];
    [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    b.alpha = 0.3;
    return b;
}

-(void)layoutInit
{
    UIButton *connectBtn = [self btnWithName:@"connect caller" x:10 y:250 action:@selector(connectAsCallerAction)];
    [self.view addSubview:connectBtn];
    
    UIButton *calleeBtn = [self btnWithName:@"connect callee" x:10 y:310 action:@selector(connectAsCalleeAction)];
    [self.view addSubview:calleeBtn];
    
    UIButton *swapBtn = [self btnWithName:@"swap" x:10 y:370 action:@selector(swapAction)];
    [self.view addSubview:swapBtn];
    
    UIButton *closeBtn = [self btnWithName:@"close" x:10 y:430 action:@selector(closeAction)];
    [self.view addSubview:closeBtn];
    
    UIButton *audioCallerBtn = [self btnWithName:@"audio caller" x:170 y:250 action:@selector(audioCallerAction)];
    [self.view addSubview:audioCallerBtn];
    
    UIButton *audioCalleeBtn = [self btnWithName:@"audio callee" x:170 y:310 action:@selector(audioCalleeAction)];
    [self.view addSubview:audioCalleeBtn];
    
    UIButton *speakerONBtn = [self btnWithName:@"speaker on" x:170 y:370 action:@selector(speakerON)];
    [self.view addSubview:speakerONBtn];
    
    UIButton *speakerOFFBtn = [self btnWithName:@"speaker off" x:170 y:430 action:@selector(speakerOFF)];
    [self.view addSubview:speakerOFFBtn];
    
    self.localVideoView = [[RTCCameraPreviewView alloc] initWithFrame:CGRectMake(10, 60, 150, 150)];
    self.localVideoView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.localVideoView];
    
    RTCEAGLVideoView *remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectZero];
    remoteView.delegate = self;
    [self.view insertSubview:remoteView belowSubview:connectBtn];
    self.remoteVideoView = remoteView;
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, 500, 300, 50)];
    self.label.backgroundColor = [UIColor lightGrayColor];
    self.label.font = [UIFont systemFontOfSize:16];
    self.label.alpha = 0.3;
    [self.view addSubview:self.label];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 60)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.text= userId;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
}

-(void)removeStreamRender
{
    if (self.captureController) {
        [self.captureController.capturer stopCapture];
        self.localVideoView.captureSession = nil;
    }
    
//    if (self.remoteVideoTrack) {
//        [self.remoteVideoTrack removeRenderer:self.remoteVideoView];
//        [self.remoteVideoView renderFrame:nil];
//        self.remoteVideoTrack = nil;
//        [self.remoteVideoView renderFrame:nil];
//    }
}
#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size
{
    [self.remoteVideoView fitVideoSize:size withAspectRatioToTheView:self.view];
}

#pragma mark -  WebRTCAppClientDelegate

- (void)appClient:(WebRTCAppClient *)client didChangeState:(WebRTCAppClientState)state
{
    if(state == WebRTCAppClientStateDisconnected){
        [self removeStreamRender];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(state == WebRTCAppClientStateDisconnected){
            self.label.text = @"Not Connected";
        } else if(state == WebRTCAppClientStateConnecting){
            self.label.text = @"Connecting";
        }else{
            self.label.text = @"Connect OK";
        }
    });
}

- (void)appClient:(WebRTCAppClient *)client didError:(NSError *)error
{
    self.label.text = @"Error";
}

- (void)appClient:(WebRTCAppClient *)client didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer
{
    self.localVideoView.captureSession = localCapturer.captureSession;
    self.captureController = [[WebRTCAppCaptureController alloc] initWithCapturer:localCapturer];
    [self.captureController startCapture];
}

- (void)appClient:(WebRTCAppClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack
{
    if (self.remoteVideoTrack == remoteVideoTrack) {
        return;
    }
    
    [self.remoteVideoTrack removeRenderer:self.remoteVideoView];
    self.remoteVideoTrack = nil;
    [self.remoteVideoView renderFrame:nil];
    
    self.remoteVideoTrack = remoteVideoTrack;
    [self.remoteVideoTrack addRenderer:self.remoteVideoView];
}

@end
