//
//  FSGridCell.h
//  Pods
//
//  Created by qbuser on 03/08/15.
//
//

#import <UIKit/UIKit.h>
#import "FSImage.h"

@interface FSGridCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) id<FSImage> image;

@end
