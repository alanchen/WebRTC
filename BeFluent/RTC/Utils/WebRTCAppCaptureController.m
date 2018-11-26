//
//  WebRTCAppCaptureController.m
//  BeFluent
//
//  Created by alan on 2018/11/21.
//  Copyright © 2018 alan. All rights reserved.
//

#import "WebRTCAppCaptureController.h"
const Float64 kFramerateLimit = 30.0;

@implementation WebRTCAppCaptureController{
    WebRTCAppVideoResolution *_resolution;
    BOOL _usingFrontCamera;
}

- (instancetype)initWithCapturer:(RTCCameraVideoCapturer *)capturer
                      resolution:(WebRTCAppVideoResolution *)resolution
{
    if (self = [super init]) {
        _capturer = capturer;
        _resolution = resolution;
        _usingFrontCamera = YES;
    }
    
    return self;
}

- (instancetype)initWithCapturer:(RTCCameraVideoCapturer *)capturer
{
    if (self = [super init]) {
        WebRTCAppVideoResolution *resolution = [WebRTCAppVideoResolution resolutionWithWidth:640 height:480];
        _capturer = capturer;
        _resolution = resolution;
        _usingFrontCamera = YES;
    }
    
    return self;
}

- (void)startCapture
{
    AVCaptureDevicePosition position = _usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    if (format == nil) {
        NSAssert(NO, @"");
        return;
    }
    
    NSInteger fps = [self selectFpsForFormat:format];
    [_capturer startCaptureWithDevice:device format:format fps:fps];
}

- (void)stopCapture {
    [_capturer stopCapture];
}

- (void)switchCamera {
    _usingFrontCamera = !_usingFrontCamera;
    [self startCapture];
}

#pragma mark - Private

- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position
{
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device
{
    NSArray<AVCaptureDeviceFormat *> *formats = [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    int targetWidth = [_resolution.widthNum intValue] ;
    int targetHeight = [_resolution.heightNum intValue] ;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        } else if (diff == currentDiff && pixelFormat == [_capturer preferredOutputPixelFormat]) {
            selectedFormat = format;
        }
    }
    
    return selectedFormat;
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat *)format
{
    Float64 maxSupportedFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxSupportedFramerate = fmax(maxSupportedFramerate, fpsRange.maxFrameRate);
    }
    return fmin(maxSupportedFramerate, kFramerateLimit);
}

#pragma mark -

+ (NSArray<WebRTCAppVideoResolution *>  *)availableVideoResolutions
{
    NSMutableSet<WebRTCAppVideoResolution *> *resolutions = [[NSMutableSet<WebRTCAppVideoResolution *> alloc] init];
    for (AVCaptureDevice *device in [RTCCameraVideoCapturer captureDevices]) {
        for (AVCaptureDeviceFormat *format in [RTCCameraVideoCapturer supportedFormatsForDevice:device]) {
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
            WebRTCAppVideoResolution *resolution = [[WebRTCAppVideoResolution alloc] init];
            resolution.widthNum = @(dimensions.width);
            resolution.heightNum = @(dimensions.height);
            [resolutions addObject:resolution];
        }
    }
    
    NSArray<WebRTCAppVideoResolution *> *sortedResolutions =
    [[resolutions allObjects] sortedArrayUsingComparator:^NSComparisonResult(WebRTCAppVideoResolution *obj1, WebRTCAppVideoResolution *obj2) {
        NSComparisonResult cmp = [obj1.widthNum compare:obj2.widthNum];
        if (cmp != NSOrderedSame) { return cmp; }
        return [obj1.heightNum compare:obj2.heightNum];
    }];
    
    return sortedResolutions;
}

@end
