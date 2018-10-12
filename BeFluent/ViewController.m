//
//  ViewController.m
//  BeFluent
//
//  Created by alan on 2018/9/18.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "ViewController.h"
#import "WebRTCAppFirestoreManager.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import "WebRTCAppClient.h"

static NSString *userId = @"tester";
static NSString *roomId = @"30678";

@interface ViewController () <WebRTCAppClientDelegate>

@property (nonatomic,strong)WebRTCAppClient *connection;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    userId = [[NSUUID UUID].UUIDString substringWithRange:NSMakeRange(0,8)];
    [self layoutInit];
}

#pragma mark - Action

- (void)connectAsCallerAction
{
    if(self.connection){
        return;
    }

    // WebRTCAppClientStreamTypeAudio WebRTCAppClientStreamTypeVideo
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

- (void)closeAction
{
    [self removeStreamRender];
    [self.connection disconnect];
    self.connection = nil;
}


- (void)swapAction
{
    if( self.connection.cameraPosition == AVCaptureDevicePositionBack){
        self.connection.cameraPosition = AVCaptureDevicePositionFront;
    } else{
        self.connection.cameraPosition = AVCaptureDevicePositionBack;
    }
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
    
    
    self.localView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(10, 60, 150, 150)];
//        [self.localView setDelegate:self];
    [self.view addSubview:self.localView];
    
    self.remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(170, 60, 150, 150)];
    //    [self.localView setDelegate:self];
    [self.view addSubview:self.remoteView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, 500, 300, 50)];
    self.label.backgroundColor = [UIColor lightGrayColor];
    self.label.font = [UIFont systemFontOfSize:16];
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
    if (self.localVideoTrack) {
        [self.localVideoTrack removeRenderer:self.localView];
        self.localVideoTrack = nil;
        [self.localView renderFrame:nil];
    }
    
    if (self.remoteView) {
        [self.remoteVideoTrack removeRenderer:self.remoteView];
        self.remoteVideoTrack = nil;
        [self.remoteView renderFrame:nil];
    }
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

- (void)appClient:(WebRTCAppClient *)client didReceiveLocalStream:(RTCMediaStream *)localStream
{
    if (self.localVideoTrack) {
        [self.localVideoTrack removeRenderer:self.localView];
        self.localVideoTrack = nil;
        [self.localView renderFrame:nil];
    }
    self.localVideoTrack = localStream.videoTrack;
    [self.localVideoTrack addRenderer:self.localView];
    
    self.label.text = @"Did add localStream";
}

- (void)appClient:(WebRTCAppClient *)client didReceiveRemoteStream:(RTCMediaStream *)remoteStream
{
    if (self.remoteVideoTrack) {
        [self.remoteVideoTrack removeRenderer:self.remoteView];
        self.remoteVideoTrack = nil;
        [self.remoteView renderFrame:nil];
    }
    self.remoteVideoTrack = remoteStream.videoTrack;
    [self.remoteVideoTrack addRenderer:self.remoteView];
    
    self.label.text = @"Did add remoteStream";
}

- (void)appClient:(WebRTCAppClient *)client didError:(NSError *)error
{
    self.label.text = @"Error";
}


@end
