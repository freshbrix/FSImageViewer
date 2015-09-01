//
//  FSGridCell.m
//  Pods
//
//  Created by qbuser on 03/08/15.
//
//

#import "FSGridCell.h"
#import "FSImageLoader.h"
#import "FSImageViewer.h"
#import "UIImageView+AFNetworking.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define MB_FILE_SIZE 1024*1024

static NSString *const kPlaceholderImageName = @"repair_placeholder";

@interface FSGridCell()


@end

@implementation FSGridCell

- (id)initWithFrame:(CGRect)aRect {
    
    self = [super initWithFrame:aRect];
    if (self) {
        if (!_imageView) {
            
            _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            [_imageView setClipsToBounds:YES];
            [self.contentView addSubview:_imageView];
        }
    }
    return self;
}

- (void)prepareForReuse {
    
    _imageView.image = [UIImage imageNamed:kPlaceholderImageName];
}

- (void)awakeFromNib {
    // Initialization code
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
    }
}

- (void)setImage:(id<FSImage>)image {
    
    if (image.URL) {
        self.imageURL = image.URL;
    } else if (image.image) {
        self.imageView.image = image.image;
    } else {
        _imageView.image = [UIImage imageNamed:kPlaceholderImageName];
        
    }
}

- (void)setImageURL:(NSURL *)imageURL {
    
    _imageURL = imageURL;
    __weak typeof(self)weakSelf = self;
    [_imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:kPlaceholderImageName] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            [weakSelf.imageView setImage:FSImageViewerErrorPlaceholderImage];
        }
    }];
    
}

@end
