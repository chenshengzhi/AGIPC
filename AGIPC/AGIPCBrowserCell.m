//
//  AGIPCBrowserCell.m
//  AGIPCPhotoBrowserDemo
//
//  Created by 陈圣治 on 15/11/25.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "AGIPCBrowserCell.h"

@interface AGIPCBrowserCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *zoomingScrollView;
@property (nonatomic, strong) UIImageView *photoImageView;

@end

@implementation AGIPCBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zoomingScrollView];
        [self photoImageView];
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleTapGesture];
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        [self addGestureRecognizer:doubleTapGesture];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.photoImageView.image = nil;
    _assetItem = nil;
}

#pragma mark - set -
- (void)setAssetItem:(AGIPCAssetItem *)assetItem {
    if (_assetItem != assetItem) {
        _assetItem = assetItem;
        [self displayImage];
    }
}

- (void)displayImage {
    self.zoomingScrollView.maximumZoomScale = 1;
    self.zoomingScrollView.minimumZoomScale = 1;
    self.zoomingScrollView.zoomScale = 1;
    self.zoomingScrollView.contentSize = CGSizeMake(0, 0);
    
    self.zoomingScrollView.frame = CGRectMake(10, 0, self.frame.size.width-20, self.frame.size.height);
    
    UIImage *img = [UIImage imageWithCGImage:[[self.assetItem.asset defaultRepresentation] fullScreenImage]];
    self.photoImageView.image = img;
    self.photoImageView.hidden = NO;
    CGRect photoImageViewFrame;
    photoImageViewFrame.origin = CGPointZero;
    photoImageViewFrame.size = img.size;
    self.photoImageView.frame = photoImageViewFrame;
    self.zoomingScrollView.contentSize = photoImageViewFrame.size;
            
    [self setMaxMinZoomScalesForCurrentBounds];
}


#pragma mark - get -
- (UIImageView *)photoImageView {
    if (nil == _photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.contentMode = UIViewContentModeCenter;
        _photoImageView.backgroundColor = [UIColor clearColor];
        [self.zoomingScrollView addSubview:_photoImageView];
    }
    return _photoImageView;
}

- (UIScrollView *)zoomingScrollView {
    if (nil == _zoomingScrollView) {
        _zoomingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width-20, self.frame.size.height)];
        _zoomingScrollView.delegate = self;
        _zoomingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
        _zoomingScrollView.showsHorizontalScrollIndicator = NO;
        _zoomingScrollView.showsVerticalScrollIndicator = NO;
        _zoomingScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
            [self addSubview:_zoomingScrollView];
    }
    return _zoomingScrollView;
}

#pragma mark - Setup -
- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.zoomingScrollView.minimumZoomScale;
    CGSize boundsSize = self.zoomingScrollView.bounds.size;
    CGSize imageSize = self.photoImageView.image.size;
    CGFloat boundsAR = boundsSize.width / boundsSize.height;
    CGFloat imageAR = imageSize.width / imageSize.height;
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    if (ABS(boundsAR - imageAR) < 0.17) {
        zoomScale = MAX(xScale, yScale);
        zoomScale = MIN(MAX(self.zoomingScrollView.minimumZoomScale, zoomScale), self.zoomingScrollView.maximumZoomScale);
    }
    return zoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    self.zoomingScrollView.maximumZoomScale = 1;
    self.zoomingScrollView.minimumZoomScale = 1;
    self.zoomingScrollView.zoomScale = 1;
    
    if (_photoImageView.image == nil) return;
    
    CGSize boundsSize = self.zoomingScrollView.bounds.size;
    CGSize imageSize = _photoImageView.image.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    CGFloat maxScale = 2;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maxScale = 4;
    }
    
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    self.zoomingScrollView.maximumZoomScale = maxScale;
    self.zoomingScrollView.minimumZoomScale = minScale;
    
    self.zoomingScrollView.zoomScale = [self initialZoomScaleWithMinScale];
    
    if (self.zoomingScrollView.zoomScale > minScale) {
        self.zoomingScrollView.contentOffset = CGPointMake((imageSize.width * self.zoomingScrollView.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.zoomingScrollView.zoomScale - boundsSize.height) / 2.0);
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Layout -

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize boundsSize = self.zoomingScrollView.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter)) {
        _photoImageView.frame = frameToCenter;
    }
}

#pragma mark - UIScrollViewDelegate -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.zoomingScrollView.scrollEnabled = YES; // reset
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection -
- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    if (_delegate && [_delegate respondsToSelector:@selector(browserCellSingleTap:)]) {
        [_delegate browserCellSingleTap:self];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    CGPoint touchPoint = [gesture locationInView:self.photoImageView];
    if (self.zoomingScrollView.zoomScale != self.zoomingScrollView.minimumZoomScale && self.zoomingScrollView.zoomScale != [self initialZoomScaleWithMinScale]) {
        [self.zoomingScrollView setZoomScale:self.zoomingScrollView.minimumZoomScale animated:YES];
    } else {
        CGFloat newZoomScale = ((self.zoomingScrollView.maximumZoomScale + self.zoomingScrollView.minimumZoomScale) / 2);
        CGFloat xsize = self.zoomingScrollView.bounds.size.width / newZoomScale;
        CGFloat ysize = self.zoomingScrollView.bounds.size.height / newZoomScale;
        [self.zoomingScrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

@end
