//  FSImageViewer
//
//  Created by Felix Schulze on 8/26/2013.
//  Copyright 2013 Felix Schulze. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "FSImageView.h"
#import "FSPlaceholderImages.h"
#import "FSImageScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define ZOOM_VIEW_TAG 0x101
#define MB_FILE_SIZE 1024*1024

static CGFloat const kNoteViewHeightMax = 100;
static CGFloat const kNoteViewHeightMin = 70;
static CGFloat const kCommonHeight = 30;
static CGFloat const kPaddingMin = 5;
static CGFloat const kSpacing = 3;
static CGFloat const kFontSize = 13;
static CGFloat const kGridButtonWidth = 60;
static CGFloat const kGridButtonHeight = 40;
static NSString *const kFontNormal = @"Arial";
static NSString *const kFontBold = @"Arial-BoldMT";
static NSString *const kFontItalic = @"Arial-BoldItalicMT";
static NSString *const kFontNormalItalic = @"Arial-ItalicMT";
static NSString *const kGridIconName = @"grid_icon";

#define kDefaultTextColor [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1]
#define kInActiveTextColor [UIColor colorWithRed:207/255.0 green:207/255.0 blue:207/255.0 alpha:1]

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface RotateGesture : UIRotationGestureRecognizer {
}
@end

@implementation RotateGesture
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)gesture {
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return YES;
}
@end

@implementation FSImageView {
    UIActivityIndicatorView *activityView;
    CGFloat beginRadians;
    UILabel *descLabel;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = YES;
        
        FSImageScrollView *scrollView = [[FSImageScrollView alloc] initWithFrame:self.bounds];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.opaque = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        _scrollView = scrollView;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.opaque = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = ZOOM_VIEW_TAG;
        [_scrollView addSubview:imageView];
        _imageView = imageView;
        
        UIImageView *videoIndicatorView = [[UIImageView alloc] initWithFrame:self.bounds];
        videoIndicatorView.image = [UIImage imageNamed:@"Video_Preview_Icon"];
        videoIndicatorView.contentMode = UIViewContentModeCenter;
        [_scrollView addSubview:videoIndicatorView];
        _videoIndicator = videoIndicatorView;
        
        ///Adding image details elements initialisation
        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(imageView.frame) - kCommonHeight, CGRectGetWidth(imageView.frame), kCommonHeight)];
        overlay.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0/255.0 alpha:0.7];
        _overLayView = overlay;
        [self addSubview:overlay];
        
        CGRect labelFrame = overlay.bounds;
        labelFrame.origin.x = kPaddingMin;
        labelFrame.size.width -= 2*kPaddingMin;
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:labelFrame];
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.font = [UIFont fontWithName:kFontItalic size:kFontSize];
        [overlay addSubview:dateLabel];
        _overlayLabel = dateLabel;
        
        CGFloat buttonY = (CGRectGetHeight(_overLayView.bounds) - (kGridButtonHeight))/2;
        CGFloat buttonX = CGRectGetWidth(_overLayView.bounds) - kGridButtonWidth;
        CGRect buttonFrame = CGRectMake(buttonX, buttonY, kGridButtonWidth, kGridButtonHeight);
        UIButton *gridIcon = [[UIButton alloc] initWithFrame:buttonFrame];
        [gridIcon setImage:[UIImage imageNamed:kGridIconName] forState:UIControlStateNormal];
        [gridIcon addTarget:self action:@selector(girdButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [overlay addSubview:gridIcon];
        _gridButton = gridIcon;
        
        UIView *noteView = [[UIView alloc] initWithFrame:self.bounds];
        noteView.backgroundColor = [UIColor whiteColor];
        _captionContainerView = noteView;
        
        UIView *noteTextContainerView = [[UIView alloc] initWithFrame:noteView.bounds];
        noteTextContainerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        noteTextContainerView.layer.borderWidth = 1;
        noteTextContainerView.layer.cornerRadius = 2.0;
        noteTextContainerView.layer.borderColor = [UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:1].CGColor;
        _noteTextContainerView = noteTextContainerView;
        [noteView addSubview:noteTextContainerView];
        
        UITextView *noteText = [[UITextView alloc] initWithFrame:noteView.bounds];
        noteText.font = [UIFont fontWithName:kFontNormal size:kFontSize];
        noteText.textColor = kDefaultTextColor;
        //        noteText.editable = NO;
        noteText.backgroundColor = [UIColor clearColor];
        [noteTextContainerView addSubview:noteText];
        _noteTextView = noteText;
        
        
        UIView *noteVissibilityView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(noteView.frame) - kCommonHeight, CGRectGetWidth(noteView.frame), kCommonHeight)];
        noteVissibilityView.backgroundColor = [UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:1];
        [noteView addSubview:noteVissibilityView];
        _noteVisibilityView = noteVissibilityView;
        [self addSubview:noteView];
        
        UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 8, 14, 14)];
        [checkButton setImage:[UIImage imageNamed:@"check_box_selected"] forState:UIControlStateSelected];
        [checkButton setImage:[UIImage imageNamed:@"check_box_unselected"] forState:UIControlStateNormal];
        [checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        [noteVissibilityView addSubview:checkButton];
        _checkButton = checkButton;
        
        descLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(checkButton.frame) + 2*kPaddingMin, 0, CGRectGetWidth(noteVissibilityView.frame) - kCommonHeight, kCommonHeight)];
        descLabel.textColor = [UIColor whiteColor];
        descLabel.text = @"Make the image visible to others";
        descLabel.font = [UIFont fontWithName:kFontBold size:kFontSize];
        [noteVissibilityView addSubview:descLabel];
        
        UIButton *clickButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(noteVissibilityView.frame))];
        [clickButton setBackgroundColor:[UIColor clearColor]];
        [clickButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        _noteClickButton = clickButton;
        [noteVissibilityView addSubview:clickButton];
        
        self.overLayView.hidden = YES;
        self.captionContainerView.hidden = YES;
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake((CGRectGetWidth(self.frame) / 2) - 11.0f, CGRectGetHeight(self.frame) / 2, 22.0f, 22.0f);
        activityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:activityView];
        
        //Adding default label view
        _defaultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 104, 30)];
        _defaultView.backgroundColor = [UIColor clearColor];
        
        UIImageView *defaultArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        defaultArrowImageView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0/255.0 alpha:0.7];
        defaultArrowImageView.image = [self imageNamed:@"check_default"];
        defaultArrowImageView.contentMode = UIViewContentModeCenter;
        
        UILabel *defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, 72, 30)];
        defaultLabel.text = @"Default";
        defaultLabel.font = [UIFont fontWithName:@"Arial-MT" size:14.0];
        defaultLabel.textColor = [UIColor whiteColor];
        defaultLabel.textAlignment = NSTextAlignmentCenter;
        defaultLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0/255.0 alpha:0.7];
        [_defaultView addSubview:defaultArrowImageView];
        [_defaultView addSubview:defaultLabel];
        [self addSubview:_defaultView];
        /****/
        
        //Adding set as default view
        _setAsDefaultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(imageView.frame), kCommonHeight)];
        _setAsDefaultView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0/255.0 alpha:0.7];
        _setAsDefaultView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        
        UILabel *setAsDefaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, CGRectGetWidth(imageView.frame), 16)];
        setAsDefaultLabel.textAlignment = NSTextAlignmentCenter;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Tap here to make this image default"];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:64.0/255.0 green:155.0/255.0 blue:224.0/255.0 alpha:1.0] range:NSMakeRange(0, 8)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(8, attributedString.length - 8)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-ItalicMT" size:14.0] range:NSMakeRange(0, attributedString.length)];
        setAsDefaultLabel.attributedText = attributedString;
        setAsDefaultLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        UIButton *setAsDefaultButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(imageView.frame), kCommonHeight)];
        [setAsDefaultButton addTarget:self action:@selector(tappedOnSetAsDefaultButton:) forControlEvents:UIControlEventTouchUpInside];
        setAsDefaultButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_setAsDefaultView addSubview:setAsDefaultLabel];
        [_setAsDefaultView addSubview:setAsDefaultButton];
        [self addSubview:_setAsDefaultView];
        
        RotateGesture *gesture = [[RotateGesture alloc] initWithTarget:self action:@selector(rotate:)];
        [self addGestureRecognizer:gesture];
        
    }
    return self;
}

- (void)dealloc {
    if (_image) {
        [[FSImageLoader sharedInstance] cancelRequestForUrl:self.image.URL];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_scrollView.zoomScale == 1.0f) {
        [self layoutScrollViewAnimated:YES];
    }
    
}

- (UIImage *)imageNamed:(NSString *)imageName {
    NSString *resourceBundlePath = [[NSBundle bundleForClass:[FSImageView class]] pathForResource:@"FRResources" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    NSString *imageFilePath = [resourceBundle pathForResource:imageName ofType:@"png"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
        return [UIImage imageWithContentsOfFile:imageFilePath];
    } else {
        return nil;
    }
}

- (void)setImage:(id <FSImage>)aImage {
    
    if (!aImage) {
        return;
    }
    if ([aImage isEqual:_image]) {
        return;
    }
    if (_image != nil) {
        [[FSImageLoader sharedInstance] cancelRequestForUrl:_image.URL];
    }
    
    _image = aImage;
    [self updateImageDetails];
    
//    else {
    if (_image.mediaType == TypeVideo) {
        descLabel.text = @"Make the Video visible to others";
        NSString *urlString = [_image.URL absoluteString];
        [_imageView sd_setImageWithURL:[NSURL URLWithString:[urlString stringByAppendingString:@"_thumbnail"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                _image.image = image;
                [self setupImageViewWithImage:image];
            } else {
                if (_image.image) {
                    _imageView.image = _image.image;
                    [self setupImageViewWithImage:_image.image];
                } else {
                    _image.image = [UIImage imageNamed:@"attachment_vedio_thumpnail"];
                    [self setupImageViewWithImage:[UIImage imageNamed:@"attachment_vedio_thumpnail"]];
                }
            }
        }];
    } else {
        if (_image.image) {
            _imageView.image = _image.image;
        }else {
            [_imageView sd_setImageWithURL:_image.URL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!error) {
                    _image.image = image;
                    [self setupImageViewWithImage:image];
                }
                else {
                    [self handleFailedImage];
                }
            }];
        }
    }
        //        if ([_image.URL isFileURL]) {
        //
        //            NSError *error = nil;
        //            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_image.URL path] error:&error];
        //            NSInteger fileSize = [[attributes objectForKey:NSFileSize] integerValue];
        //
        //            if (fileSize >= MB_FILE_SIZE) {
        //
        //                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //
        //                    UIImage *image = nil;
        //                    NSData *data = [NSData dataWithContentsOfURL:self.image.URL];
        //                    if (!data) {
        //                        [self handleFailedImage];
        //                    } else {
        //                        image = [UIImage imageWithData:data];
        //                    }
        //
        //                    dispatch_async(dispatch_get_main_queue(), ^{
        //
        //                        if (image != nil) {
        //                            [self setupImageViewWithImage:image];
        //                        }
        //
        //                    });
        //                });
        //
        //            }
        //            else {
        //                self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.image.URL]];
        //            }
        //
        //        }
        //        else {
        //            [[FSImageLoader sharedInstance] loadImageForURL:_image.URL image:^(UIImage *image, NSError *error) {
        //                if (!error) {
        //                    _image.image = image;
        //                    [self setupImageViewWithImage:image];
        //                }
        //                else {
        //                    [self handleFailedImage];
        //                }
        //            }];
        //        }
        
//    }
    
    if (_imageView.image) {
        
        [activityView stopAnimating];
        self.userInteractionEnabled = YES;
        _loading = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFSImageViewerDidFinishedLoadingNotificationKey object:@{
                                                                                                                            @"image" : self.image,
                                                                                                                            @"failed" : @(NO)
                                                                                                                            }];
        
    } else {
        _loading = YES;
        [activityView startAnimating];
        self.userInteractionEnabled = NO;
    }
    [self layoutScrollViewAnimated:NO];
}

/// method to update the frame of image details elements
- (void)updateImageDetails {
    
    self.overLayView.frame = CGRectMake(0, CGRectGetHeight(self.imageView.frame) - kCommonHeight, CGRectGetWidth(self.frame), kCommonHeight);
    self.captionContainerView.frame = CGRectMake(0, CGRectGetHeight(self.scrollView.frame), CGRectGetWidth(self.frame), [self noteViewHeight]);
    CGFloat noteViewHeight = ([_image isEditable])? CGRectGetHeight(self.captionContainerView.frame) - kCommonHeight : CGRectGetHeight(self.captionContainerView.frame);
    if (_image.shouldDelete == NO) {
        if ([_image isEditable] == YES) {
            self.noteTextView.editable = YES;
        } else {
            self.noteTextView.editable = NO;
        }
    } else if (_image.shouldDelete == YES) {
        self.noteTextView.editable = YES;
    } else {
        self.noteTextView.editable = NO;
    }
    self.noteTextView.delegate = self;
    self.noteTextContainerView.frame = CGRectMake(kSpacing, kSpacing, CGRectGetWidth(self.captionContainerView.frame) - 2*kSpacing, noteViewHeight - 2*kSpacing);
    self.noteTextView.frame = CGRectMake(0, 0, CGRectGetWidth(self.captionContainerView.frame), CGRectGetHeight(self.noteTextContainerView.frame));
    self.noteVisibilityView.frame = CGRectMake(0, CGRectGetHeight(self.captionContainerView.frame) - kCommonHeight, CGRectGetWidth(self.captionContainerView.frame), kCommonHeight);
    CGFloat buttonY = (CGRectGetHeight(_overLayView.bounds) - (kGridButtonHeight))/2;
    CGFloat buttonX = CGRectGetWidth(_overLayView.bounds) - kGridButtonWidth;
    CGRect buttonFrame = CGRectMake(buttonX, buttonY, kGridButtonWidth, kGridButtonHeight);
    self.gridButton.frame = buttonFrame;
    [self bringSubviewToFront:self.captionContainerView];
    [self.noteVisibilityView setHidden:![_image isEditable]];
    [self.overlayLabel setText:_image.overlayString];
    [self.noteTextView setText:_image.notes];
    self.checkButton.selected = !_image.isPrivate;
    [self updateViewsAccordingToViewMode];
}

- (void)updateDefaultViews:(BOOL)hidden {
    if (hidden == YES) {
        [self.defaultView setHidden:YES];
        [self.setAsDefaultView setHidden:YES];
    } else {
        [self.defaultView setHidden:!_image.isDefaultImage];
        if (!_image.isDefaultImage) {
            if (self.enableSetAsDefault) {
                [self.setAsDefaultView setHidden:NO];
            } else {
                [self.setAsDefaultView setHidden:YES];
            }
        } else {
            [self.setAsDefaultView setHidden:YES];
        }
    }
}

- (void)updateViewsAccordingToViewMode {
    
    if (![self.image isImageHaveDetails]) {
        self.imageViewMode = FSImageViewModeImageAndTimeStamp;
    }
    
    if ([self.image.URL isEqual:self.defaultImageUrl]) {
        self.imageViewMode = FSImageViewModeImageOnly;
    }
    
    if (!self.isHiddenDetails) {
        switch (self.imageViewMode) {
            case FSImageViewModeImageOnly:
                [self.defaultView setHidden:YES];
                [self.setAsDefaultView setHidden:YES];
                [self.captionContainerView setHidden:YES];
                [self.overLayView setHidden:YES];
                break;
            case FSImageViewModeImageAndTimeStamp:
                [self updateDefaultViews:NO];
                [self.captionContainerView setHidden:YES];
                [self.overLayView setHidden:NO];
                break;
            case FSImageViewModeTimeStampAndCaption:
                [self updateDefaultViews:NO];
                [self.captionContainerView setHidden:NO];
                [self.overLayView setHidden:NO];
                [self.noteVisibilityView setHidden:YES];
                break;
            case FSImageViewModeAllDetailsReadOnly:
                [self updateDefaultViews:YES];
                _image.editable = NO;
                _image.shouldDelete = NO;
                [self.captionContainerView setHidden:NO];
                [self.overLayView setHidden:NO];
                break;
            case FSImageViewModeAllDetails:
                [self updateDefaultViews:NO];
                [self.captionContainerView setHidden:NO];
                [self.overLayView setHidden:NO];
                break;
        }
    }
    //    if ([_image.overlayString length] == 0) {
    //        [self.overLayView setHidden:YES];
    //
    //    }
    if ([_image.notes length] == 0)  {
        self.noteTextView.font = [UIFont fontWithName:kFontNormalItalic size:kFontSize];
        self.noteTextView.textColor = kInActiveTextColor;
        self.noteTextView.text = @"Add a Caption";
        //        [self.noteTextContainerView setHidden:YES];
        //        self.noteVisibilityView.frame = CGRectMake(0, 0, CGRectGetWidth(self.captionContainerView.frame), kCommonHeight);
    } else {
        if ([_image.notes isEqualToString:@"Add a Caption"]) {
            self.noteTextView.font = [UIFont fontWithName:kFontNormalItalic size:kFontSize];
            self.noteTextView.textColor = kInActiveTextColor;
        } else {
            self.noteTextView.font = [UIFont fontWithName:kFontNormal size:kFontSize];
            self.noteTextView.textColor = kDefaultTextColor;
        }
        //        [self.noteTextContainerView setHidden:NO];
        //        self.noteVisibilityView.frame = CGRectMake(0, CGRectGetHeight(self.captionContainerView.frame) - kCommonHeight, CGRectGetWidth(self.captionContainerView.frame), kCommonHeight);
    }
    if (_loading) {
        [self.captionContainerView setHidden:YES];
        [self.overLayView setHidden:YES];
        [self.defaultView setHidden:YES];
        [self.setAsDefaultView setHidden:YES];
    }
}

- (void)setupImageViewWithImage:(UIImage *)aImage {
    if (!aImage) {
        return;
    }
    
    _loading = NO;
    [activityView stopAnimating];
    _imageView.image = aImage;
    [self layoutScrollViewAnimated:NO];
    
    [[self layer] addAnimation:[self fadeAnimation] forKey:@"opacity"];
    self.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFSImageViewerDidFinishedLoadingNotificationKey object:@{
                                                                                                                        @"image" : self.image,
                                                                                                                        @"failed" : @(NO)
                                                                                                                        }];
}

- (void)prepareForReuse {
    self.tag = -1;
}

- (void)changeBackgroundColor:(UIColor *)color {
    self.backgroundColor = color;
    self.imageView.backgroundColor = color;
    self.scrollView.backgroundColor = color;
}

- (void)setDetailsHidden:(BOOL)hidden {
    
    self.isHiddenDetails = hidden;
    [self.captionContainerView setHidden:hidden];
    [self.overLayView setHidden:hidden];
    [self updateDefaultViews:hidden];
    [self layoutScrollViewAnimated:NO];
}

- (void)handleFailedImage {
    
    _imageView.image = FSImageViewerErrorPlaceholderImage;
    _image.failed = YES;
    [self layoutScrollViewAnimated:NO];
    self.userInteractionEnabled = NO;
    [activityView stopAnimating];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFSImageViewerDidFinishedLoadingNotificationKey object:@{
                                                                                                                        @"image" : self.image,
                                                                                                                        @"failed" : @(YES)
                                                                                                                        }];
}

- (void)resetBackgroundColors {
    self.backgroundColor = [UIColor whiteColor];
    self.superview.backgroundColor = self.backgroundColor;
    self.superview.superview.backgroundColor = self.backgroundColor;
}

- (CGFloat)noteViewHeight {
    
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat height = kNoteViewHeightMin;
    if (!(IS_IPAD)) {//Keep same height for ipad
        if (viewHeight > viewWidth) {
            //Portrait
            height = kNoteViewHeightMax;
        } else {
            //Landscape
            height = kNoteViewHeightMin;
        }
    }
    if (_image && ![_image isEditable]) {
        //If the image is not editable, visibility change view will
        //be hidden.
        height -= kCommonHeight;
    }
    return height;
}

#pragma mark - Action Methods

- (IBAction)checkAction:(UIButton *)sender {
    self.checkButton.selected = !self.checkButton.selected;
    _image.privateImage = !self.checkButton.selected;
}

- (IBAction)girdButtonClicked:(UIButton *)sender {
    
    CGRect frame = [self convertRect:sender.frame fromView:self.overLayView];
    if (self.gridSelectionCallBack) {
        
        self.gridSelectionCallBack (frame);
    }
}

- (IBAction)tappedOnSetAsDefaultButton:(UIButton *)sender {
    if (self.setDefaultImageCallBack) {
        self.setDefaultImageCallBack(self.image.URL);
    }
}

#pragma mark - Layout

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation {
    
    if (self.scrollView.zoomScale > 1.0f) {
        
        CGFloat height, width;
        height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
        width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));
        self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
        
    } else {
        
        [self layoutScrollViewAnimated:NO];
        
    }
}

- (void)layoutScrollViewAnimated:(BOOL)animated {
    
    if (!_imageView.image) {
        [self.overLayView setHidden:YES];
        return;
    }
    //    [self.overLayView setHidden:NO];
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.0010];
    }
    
    CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
    CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
    
    CGFloat factor = MAX(hfactor, vfactor);
    
    CGFloat newWidth = (int) (self.imageView.image.size.width / factor);
    CGFloat newHeight = (int) (self.imageView.image.size.height / factor);
    
    CGFloat leftOffset = (int) ((self.frame.size.width - newWidth) / 2);
    CGFloat topOffset = (int) ((self.frame.size.height - newHeight) / 2);
    CGFloat positionY = self.bounds.size.height / 2;
    if (!self.isHiddenDetails && self.imageViewMode != FSImageViewModeImageOnly) {
        
        //update the yposition to top if image is not viewing in full view or the
        //view is image only
        CGFloat value = CGRectGetHeight(self.frame) - newHeight;
        CGFloat noteViewHeight = [self noteViewHeight];
        if (value < noteViewHeight) {
            newHeight -= noteViewHeight - value;
        }
        positionY = newHeight / 2;
    }
    self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    self.scrollView.layer.position = CGPointMake(self.bounds.size.width / 2, positionY);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    self.imageView.frame = self.scrollView.bounds;
    self.videoIndicator.frame = self.scrollView.bounds;
    
    [self updateImageDetails];
    
    if (animated) {
        [UIView commitAnimations];
    }
}

#pragma mark - Animation

- (CABasicAnimation *)fadeAnimation {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.duration = .3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return animation;
}

#pragma mark - UIScrollViewDelegate

- (void)killZoomAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if ([finished boolValue]) {
        
        [self.scrollView setZoomScale:1.0f animated:NO];
        self.imageView.frame = self.scrollView.bounds;
        [self layoutScrollViewAnimated:NO];
        
    }
    
}

- (void)killScrollViewZoom {
    
    if (!(self.scrollView.zoomScale > 1.0f)) return;
    
    if (!self.imageView.image) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(killZoomAnimationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    
    
    CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
    CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
    
    CGFloat factor = MAX(hfactor, vfactor);
    
    CGFloat newWidth = (int) (self.imageView.image.size.width / factor);
    CGFloat newHeight = (int) (self.imageView.image.size.height / factor);
    
    CGFloat leftOffset = (int) ((self.frame.size.width - newWidth) / 2);
    CGFloat topOffset = (int) ((self.frame.size.height - newHeight) / 2);
    if (!self.isHiddenDetails) {
        topOffset = 0;
    }
    self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    self.imageView.frame = self.scrollView.bounds;
    
    [UIView commitAnimations];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self.scrollView viewWithTag:ZOOM_VIEW_TAG];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    
    [self setDetailsHidden:YES];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    if (scrollView.zoomScale > 1.0f) {
        
        CGFloat height, width;
        height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
        width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));
        
        
        if (CGRectGetMaxX(self.imageView.frame) > self.bounds.size.width) {
            width = CGRectGetWidth(self.bounds);
        } else {
            width = CGRectGetMaxX(self.imageView.frame);
        }
        
        if (CGRectGetMaxY(self.imageView.frame) > self.bounds.size.height) {
            height = CGRectGetHeight(self.bounds);
        } else {
            height = CGRectGetMaxY(self.imageView.frame);
        }
        
        CGRect frame = self.scrollView.frame;
        self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
        self.scrollView.layer.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        if (!CGRectEqualToRect(frame, self.scrollView.frame)) {
            
            CGFloat offsetY, offsetX;
            
            if (frame.origin.y < self.scrollView.frame.origin.y) {
                offsetY = self.scrollView.contentOffset.y - (self.scrollView.frame.origin.y - frame.origin.y);
            } else {
                offsetY = self.scrollView.contentOffset.y - (frame.origin.y - self.scrollView.frame.origin.y);
            }
            
            if (frame.origin.x < self.scrollView.frame.origin.x) {
                offsetX = self.scrollView.contentOffset.x - (self.scrollView.frame.origin.x - frame.origin.x);
            } else {
                offsetX = self.scrollView.contentOffset.x - (frame.origin.x - self.scrollView.frame.origin.x);
            }
            
            if (offsetY < 0) offsetY = 0;
            if (offsetX < 0) offsetX = 0;
            
            self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
            self.scrollView.scrollEnabled = YES;
        }
        
    } else {
        [self layoutScrollViewAnimated:YES];
        self.scrollView.scrollEnabled = NO;
    }
}

#pragma mark - RotateGesture

- (void)rotate:(UIRotationGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.layer removeAllAnimations];
        beginRadians = gesture.rotation;
        self.layer.transform = CATransform3DMakeRotation(beginRadians, 0.0f, 0.0f, 1.0f);
        
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        self.layer.transform = CATransform3DMakeRotation((beginRadians + gesture.rotation), 0.0f, 0.0f, 1.0f);
    }
    else {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation.duration = 0.3f;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        [animation setValue:[NSNumber numberWithInt:202] forKey:@"AnimationType"];
        [self.layer addAnimation:animation forKey:@"RotateAnimation"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (flag) {
        if ([[anim valueForKey:@"AnimationType"] integerValue] == 101) {
            [self resetBackgroundColors];
        } else if ([[anim valueForKey:@"AnimationType"] integerValue] == 202) {
            self.layer.transform = CATransform3DIdentity;
        }
    }
}

#pragma mark - Bars

- (void)toggleBars {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFSImageViewerToogleBarsNotificationKey object:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        if (self.image.mediaType == TypeVideo) {
            [self.imageViewDelegate playMovieWithURL:self.image.URL];
        } else {
            [self setDetailsHidden:YES];
            [self performSelector:@selector(toggleBars) withObject:nil afterDelay:.2];
        }
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([_textViewDelegate respondsToSelector:@selector(textViewShouldBeginEditing:withImageId:)]) {
        return [_textViewDelegate textViewShouldBeginEditing:textView withImageId:self.image.imageId];
    } else {
        return YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([_textViewDelegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        return [_textViewDelegate textViewDidEndEditing:textView];
    }
}

@end
