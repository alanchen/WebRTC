//
//  RTCEAGLVideoView+WebRTCApp.h
//  BeFluent
//
//  Created by alan on 2018/11/26.
//  Copyright © 2018 alan. All rights reserved.
//

#import <WebRTC/RTCEAGLVideoView.h>

@interface RTCEAGLVideoView(WebRTCApp)

-(void)fitVideoSize:(CGSize)size withAspectRatioToTheView:(UIView *)view;

@end
