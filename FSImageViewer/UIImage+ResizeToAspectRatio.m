//
//  UIImage+ResizeToAspectRatio.m
//  FreshBrix
//
//  Created by qbadmin on 20/06/14.
//  Copyright (c) 2014 HomeProLog. All rights reserved.
//

#import "UIImage+ResizeToAspectRatio.h"

@implementation UIImage (ResizeToAspectRatio)

- (UIImage *)scaleToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = self.size.width;
    CGFloat oldHeight = self.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:self scaledToSize:newSize];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (CGSize)scalingSize {
    CGFloat actualDeviceWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat actualDeviceHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat actualImageWidth = [self size].width;
    CGFloat actualImageHeight = [self size].height;
    CGFloat actualImageRatio = actualImageHeight / actualImageWidth;
    CGSize expectedSize;
    
    if (actualImageWidth > actualImageHeight) {
        expectedSize.width = actualDeviceHeight;
        expectedSize.height = actualImageRatio * actualImageWidth;
    } else {
        expectedSize.width = actualDeviceWidth;
        expectedSize.height = actualImageRatio * actualImageWidth;
    }
    return expectedSize;
}


@end
