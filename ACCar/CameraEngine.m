//
//  CameraEngine.m
//  ACCar
//
//  Created by Andrew Cavanagh on 3/12/15.
//  Copyright (c) 2015 WeddingWire. All rights reserved.
//

#import "CameraEngine.h"

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )

@interface CameraEngine ()
@property (nonatomic, strong) AVCaptureSession *session;
@end

@implementation CameraEngine

+ (instancetype)sharedInstance {
    static CameraEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CameraEngine alloc] init];
    });
    return sharedInstance;
}

- (void)start {
    if (self.session) {
        return;
    }
    
    NSError *error = nil;
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset352x288;
    //session.sessionPreset = AVCaptureSessionPresetLow;
    //session.sessionPreset = AVCaptureSessionPreset640x480;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error) {
        NSLog(@"%@", error.description);
    }
    
    [session addInput:input];
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];
    
    dispatch_queue_t queue = dispatch_queue_create("videoQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    output.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
    
    [session startRunning];
    self.session = session;
}

- (void)stop {
    [self.session stopRunning];
    self.session = nil;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        
        
        
        //size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        uint8_t *baseAddressGray = (uint8_t *)malloc(width * height);
        //neon_asm_convert(baseAddressGray, baseAddress, width * height); 1ms
        neon_convert(baseAddressGray, baseAddress, (int)width * (int)height); //16ms
    
        CGColorSpaceRef colorSpaceGray = CGColorSpaceCreateDeviceGray();
        CGContextRef newContextGray = CGBitmapContextCreate(baseAddressGray, width, height, 8, width, colorSpaceGray, (CGBitmapInfo)kCGImageAlphaNone);
        CGImageRef grayImage = CGBitmapContextCreateImage(newContextGray);
        
        UIImage *image = [UIImage imageWithCGImage:grayImage scale:1.0 orientation:UIImageOrientationRight];
        
        int index = 0;
        uint8_t *imageBrightness = (uint8_t *)malloc(width * height);
        uint8_t *currentPixel = baseAddressGray;
        for (NSUInteger j = 0; j < height; j++) {
            for (NSUInteger i = 0; i < width; i++) {
                UInt32 color = *currentPixel;
                uint8_t brightness = (R(color)+G(color)+B(color))/3.0;
                //printf("%3.0f ", (R(color)+G(color)+B(color))/3.0);
                imageBrightness[index] = brightness;
                currentPixel++;
                index++;
            }
        }

        NSData *data = [NSData dataWithBytes:imageBrightness length:(width * height)];
        //NSData *data = [NSData dataWithBytes:baseAddress length:(width * height)];
        
        free(imageBrightness);
        free(baseAddressGray);
        CGColorSpaceRelease(colorSpaceGray);
        CGContextRelease(newContextGray);
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        if (self.delegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didCaptureFrame:data image:image];
            });
        }
    }
}

void neon_convert(uint8_t * __restrict dest, uint8_t * __restrict src, int numPixels) {
    int i;
    uint8x8_t rfac = vdup_n_u8 (77);
    uint8x8_t gfac = vdup_n_u8 (151);
    uint8x8_t bfac = vdup_n_u8 (28);
    int n = numPixels / 8;
    
    // Convert per eight pixels
    for (i=0; i < n; ++i) {
        uint16x8_t  temp;
        uint8x8x4_t rgb  = vld4_u8(src);
        uint8x8_t result;
        
        temp = vmull_u8(rgb.val[0],      bfac);
        temp = vmlal_u8(temp,rgb.val[1], gfac);
        temp = vmlal_u8(temp,rgb.val[2], rfac);
        
        result = vshrn_n_u16(temp, 8);
        vst1_u8(dest, result);
        src  += 8*4;
        dest += 8;
    }
}

//static void neon_asm_convert(uint8_t * __restrict dest, uint8_t * __restrict src, int numPixels)
//{
//    __asm__ volatile("lsr          %2, %2, #3      \n"
//                     "# build the three constants: \n"
//                     "mov         r4, #28          \n" // Blue channel multiplier
//                     "mov         r5, #151         \n" // Green channel multiplier
//                     "mov         r6, #77          \n" // Red channel multiplier
//                     "vdup.8      d4, r4           \n"
//                     "vdup.8      d5, r5           \n"
//                     "vdup.8      d6, r6           \n"
//                     "0:						   \n"
//                     "# load 8 pixels:             \n"
//                     "vld4.8      {d0-d3}, [%1]!   \n"
//                     "# do the weight average:     \n"
//                     "vmull.u8    q7, d0, d4       \n"
//                     "vmlal.u8    q7, d1, d5       \n"
//                     "vmlal.u8    q7, d2, d6       \n"
//                     "# shift and store:           \n"
//                     "vshrn.u16   d7, q7, #8       \n" // Divide q3 by 256 and store in the d7
//                     "vst1.8      {d7}, [%0]!      \n"
//                     "subs        %2, %2, #1       \n" // Decrement iteration count
//                     "bne         0b            \n" // Repeat unil iteration count is not zero
//                     :
//                     : "r"(dest), "r"(src), "r"(numPixels)
//                     : "r4", "r5", "r6"
//                     );
//}

@end
