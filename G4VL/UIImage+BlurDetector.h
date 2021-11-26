//
//  UIImage+BlurDetector.h
//  G4VL
//
//  Created by Foamy iMac7 on 03/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//


#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#import <UIKit/UIKit.h>


@interface UIImage (BlurDetector)

- (BOOL)isImageBlurry;

@end
