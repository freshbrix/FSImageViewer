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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FSImageSource.h"
#import "FSImageLoader.h"

@class FSImageScrollView, FSImageTitleView;

typedef void(^GirdSelectedCallBack)(CGRect fromRect);
typedef void(^SetDefaultImageCallBack)(NSURL *url);

typedef enum : int {
    
    FSImageViewModeImageOnly,
    FSImageViewModeImageAndTimeStamp,
    FSImageViewModeTimeStampAndCaption,
    FSImageViewModeAllDetailsReadOnly,
    FSImageViewModeAllDetails
} FSImageViewMode;

@protocol TextViewDelegate <NSObject>

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView withImageId:(NSString *)imageId;

@end

@interface FSImageView : UIView <UIScrollViewDelegate, CAAnimationDelegate, UITextViewDelegate>

@property(strong, nonatomic) id <FSImage> image;
@property(strong, nonatomic, readonly) UIImageView *imageView;
@property(strong, nonatomic, readonly) FSImageScrollView *scrollView;
@property(assign, nonatomic) BOOL loading;
@property(assign, nonatomic) BOOL isHiddenDetails;
@property(assign, nonatomic) BOOL enableSetAsDefault;
@property(strong, nonatomic) GirdSelectedCallBack gridSelectionCallBack;
@property(strong, nonatomic) SetDefaultImageCallBack setDefaultImageCallBack;
//View elements for showing details
@property(assign, nonatomic) FSImageViewMode imageViewMode;
@property(strong, nonatomic, readonly) UIView *overLayView;
@property(strong, nonatomic, readonly) UILabel *overlayLabel;
@property(strong, nonatomic, readonly) UIView *captionContainerView;
@property(strong, nonatomic, readonly) UIView *noteTextContainerView;
@property(strong, nonatomic, readonly) UIView *noteVisibilityView;
@property(strong, nonatomic, readonly) UITextView *noteTextView;
@property(strong, nonatomic) id <UITextViewDelegate, TextViewDelegate> textViewDelegate;
@property(strong, nonatomic, readonly) UIButton *checkButton;
@property(strong, nonatomic, readonly) UIButton *gridButton;
@property(strong, nonatomic, readonly) UIButton *noteClickButton;
@property(strong, nonatomic) UIView *defaultView;
@property(strong, nonatomic) UIView *setAsDefaultView;
@property (strong, nonatomic) NSURL *defaultImageUrl;

- (void)killScrollViewZoom;

- (void)layoutScrollViewAnimated:(BOOL)animated;

- (void)prepareForReuse;

- (void)changeBackgroundColor:(UIColor *)color;

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

///Method to show/hide image details, such as note and overlay
- (void)setDetailsHidden:(BOOL)hidden;

@end
