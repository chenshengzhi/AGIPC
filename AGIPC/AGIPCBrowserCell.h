//
//  AGIPCBrowserCell.h
//  AGIPCPhotoBrowserDemo
//
//  Created by 陈圣治 on 15/11/25.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AGIPCAssetItem.h"

@protocol AGIPCBrowserCellDelegate;

@interface AGIPCBrowserCell : UICollectionViewCell

@property (nonatomic, weak) id<AGIPCBrowserCellDelegate>delegate;

@property (nonatomic, strong) AGIPCAssetItem *assetItem;

@end


@protocol AGIPCBrowserCellDelegate <NSObject>

- (void)browserCellSingleTap:(AGIPCBrowserCell *)cell;

@end