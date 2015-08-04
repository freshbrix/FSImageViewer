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

#define MB_FILE_SIZE 1024*1024

@interface FSGridCell ()

@property (nonatomic, assign) NSInteger inProgressRequestCount;

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

- (void)awakeFromNib {
    // Initialization code
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
    }
}

- (void)prepareForReuse {
    
    _imageView.image = nil;
}

- (void)setImageURL:(NSURL *)imageURL {
    
    _inProgressRequestCount += 1;
    _imageView.image = nil;
    _imageURL = imageURL;
    __weak typeof(_imageView)weakImageView = _imageView;
    if ([imageURL isFileURL]) {
        
        NSError *error = nil;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[imageURL path] error:&error];
        NSInteger fileSize = [[attributes objectForKey:NSFileSize] integerValue];
        
        if (fileSize >= MB_FILE_SIZE) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                UIImage *image = nil;
                NSData *data = [NSData dataWithContentsOfURL:imageURL];
                if (!data) {
                    weakImageView.image = FSImageViewerErrorPlaceholderImage;
                } else {
                    image = [UIImage imageWithData:data];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _inProgressRequestCount -= 1;
                    if (image != nil && _inProgressRequestCount == 0) {
                        weakImageView.image = image;
                    }
                    
                });
            });
            
        }
        else {
            _inProgressRequestCount -= 1;
            if (_inProgressRequestCount == 0) {
                weakImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
            }
        }
        
    }
    else {
        [[FSImageLoader sharedInstance] loadImageForURL:imageURL image:^(UIImage *image, NSError *error) {
            _inProgressRequestCount -= 1;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (_inProgressRequestCount == 0) {
                    if (!error) {
                        weakImageView.image = image;
                    }
                    else {
                        weakImageView.image = FSImageViewerErrorPlaceholderImage;
                    }
                }
                
            });
            
        }];
    }
}

@end
