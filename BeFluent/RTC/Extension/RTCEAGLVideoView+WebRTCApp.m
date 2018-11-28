//
//  RTCEAGLVideoView+WebRTCApp.m
//  BeFluent
//
//  Created by alan on 2018/11/26.
//  Copyright © 2018 alan. All rights reserved.
//

#import "RTCEAGLVideoView+WebRTCApp.h"

@implementation RTCEAGLVideoView(WebRTCApp)

-(void)fitVideoSize:(CGSize)size withAspectRatioToTheView:(UIView *)view
{
    CGRect bounds = view.bounds;
    if (size.width > 0 && size.height > 0) {
        // Aspect fill remote video into bounds.
        CGRect selfFrame = AVMakeRectWithAspectRatioInsideRect(size, bounds);
        CGFloat scale = 1;
        if (selfFrame.size.width > selfFrame.size.height) {
            // Scale by height.
            scale = bounds.size.height / selfFrame.size.height;
        } else {
            // Scale by width.
            scale = bounds.size.width / selfFrame.size.width;
        }
        selfFrame.size.height *= scale;
        selfFrame.size.width *= scale;
        self.frame = selfFrame;
        self.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    } else {
        self.frame = bounds;
    }
}

@end
