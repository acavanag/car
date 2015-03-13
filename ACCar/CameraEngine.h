//
//  CameraEngine.h
//  ACCar
//
//  Created by Andrew Cavanagh on 3/12/15.
//  Copyright (c) 2015 WeddingWire. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <arm_neon.h>
@import AVFoundation;
@import UIKit;

@protocol CameraEngineDelegate <NSObject>
- (void)didCaptureFrame:(NSData *)pixelBrightness image:(UIImage *)image;
@end

@interface CameraEngine : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, weak) id delegate;
+ (instancetype)sharedInstance;
- (void)start;
- (void)stop;
@end
