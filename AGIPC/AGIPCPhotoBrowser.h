//
//  AGIPCPhotoBrowser.h
//  AGIPCPhotoBrowserDemo
//
//  Created by 陈圣治 on 15/11/25.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AGIPCAssetItem.h"

@class AGIPCPhotoBrowser;

@protocol AGIPCPhotoBrowserDelegate <NSObject>

@required
- (NSUInteger)numberOfAssetItemInPhotoBrowser:(AGIPCPhotoBrowser *)photoBrowser;
- (AGIPCAssetItem *)photobrowser:(AGIPCPhotoBrowser *)photoBrowser assetItemAtIndex:(NSUInteger)index;

- (void)photobrowser:(AGIPCPhotoBrowser *)photoBrowser doneWithCurrentAssetItem:(AGIPCAssetItem *)assetItem;

@optional
- (void)photoBrowser:(AGIPCPhotoBrowser *)photoBrowser selectAssetItem:(AGIPCAssetItem *)assetItem;
- (void)photoBrowser:(AGIPCPhotoBrowser *)photoBrowser deselectAssetItem:(AGIPCAssetItem *)assetItem;

@end

@interface AGIPCPhotoBrowser : UIViewController

@property (nonatomic, weak) id<AGIPCPhotoBrowserDelegate>delegate;

@property (nonatomic) NSUInteger maximumNumberOfPhotosToBeSelected;

@property (nonatomic, strong) UIImage *checkButtonNormalImage;
@property (nonatomic, strong) UIImage *checkButtonSelectedImage;
@property (nonatomic, strong) UIColor *tintColor;

- (instancetype)initWithDelegate:(id<AGIPCPhotoBrowserDelegate>)delegate currentIndex:(NSInteger)index;

- (void)reloadData;

@end
