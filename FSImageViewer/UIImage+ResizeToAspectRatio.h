//
//  UIImage+ResizeToAspectRatio.h
//  FreshBrix
//
//  Created by qbadmin on 20/06/14.
//  Copyright (c) 2014 HomeProLog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResizeToAspectRatio)

- (UIImage *)scaleToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;
- (CGSize)scalingSize;

@end
