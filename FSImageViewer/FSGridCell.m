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

#define MB_FILE_SIZE 1024*1024

static NSString *const kPlaceholderImageName = @"repair_placeholder";

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

- (void)setImageURL:(NSURL *)imageURL {
    
    _imageURL = imageURL;
    if ([imageURL isFileURL]) {
        
        NSError *error = nil;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[imageURL path] error:&error];
        NSInteger fileSize = [[attributes objectForKey:NSFileSize] integerValue];
        
        if (fileSize >= MB_FILE_SIZE) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                UIImage *image = nil;
                NSData *data = [NSData dataWithContentsOfURL:imageURL];
                if (!data) {
                    _imageView.image = FSImageViewerErrorPlaceholderImage;
                } else {
                    image = [UIImage imageWithData:data];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (image != nil) {
                        _imageView.image = image;
                    }
                    
                });
            });
            
        }
        else {
            self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        }
        
    }
    else {
        [_imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:kPlaceholderImageName]];
    }
}

@end
