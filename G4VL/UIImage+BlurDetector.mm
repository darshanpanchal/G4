//
//  UIImage+BlurDetector.m
//  G4VL
//
//  Created by Foamy iMac7 on 03/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

#import "UIImage+BlurDetector.h"


@implementation UIImage (BlurDetector)

- (BOOL)isImageBlurry {
    // converting UIImage to OpenCV format - Mat
    cv::Mat matImage = [self convertUIImageToCVMat:self];
    cv::Mat matImageGrey;
    // converting image's color space (RGB) to grayscale
    cv::cvtColor(matImage, matImageGrey, CV_BGR2GRAY);
    
    cv::Mat dst2 = [self convertUIImageToCVMat:self];
    cv::Mat laplacianImage;
    dst2.convertTo(laplacianImage, CV_8UC1);
    
    // applying Laplacian operator to the image
    cv::Laplacian(matImageGrey, laplacianImage, CV_8U);
    cv::Mat laplacianImage8bit;
    laplacianImage.convertTo(laplacianImage8bit, CV_8UC1);
    
    unsigned char *pixels = laplacianImage8bit.data;
    
    // 16777216 = 256*256*256
    int maxLap = -16777216;
    for (int i = 0; i < ( laplacianImage8bit.elemSize()*laplacianImage8bit.total()); i++) {
        if (pixels[i] > maxLap) {
            maxLap = pixels[i];
        }
    }
    // one of the main parameters here: threshold sets the sensitivity for the blur check
    // smaller number = less sensitive; default = 180
    int threshold = 180;
    
    return (maxLap <= threshold);
}


- (cv::Mat)convertUIImageToCVMat:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

@end
