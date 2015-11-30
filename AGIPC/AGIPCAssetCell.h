//
//  AGIPCAssetCell.h
//  MengDaa
//
//  Created by 陈圣治 on 15/11/26.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGIPCAssetItem.h"
#import "AGImagePickerControllerDefines.h"

@class AGImagePickerController;

@protocol AGIPCAssetCellDelegate;

@interface AGIPCAssetCell : UICollectionViewCell

@property (nonatomic, strong) AGIPCAssetItem *item;

@property (nonatomic, weak) id<AGIPCAssetCellDelegate>delegate;

@end


@protocol AGIPCAssetCellDelegate <NSObject>

@required
- (void)assetCell:(AGIPCAssetCell *)cell didSelect:(AGIPCAssetItem *)assetItem;

- (void)assetCell:(AGIPCAssetCell *)cell didDeselect:(AGIPCAssetItem *)assetItem;

@end