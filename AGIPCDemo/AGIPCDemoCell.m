//
//  AGIPCDemoCell.m
//  AGIPCDemo
//
//  Created by 陈圣治 on 15/11/27.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "AGIPCDemoCell.h"

@implementation AGIPCDemoCell

- (void)setAssetItem:(AGIPCAssetItem *)assetItem {
    if (_assetItem != assetItem) {
        _assetItem = assetItem;
        self.imageView.image = [UIImage imageWithCGImage:[_assetItem.asset thumbnail]];
    }
}

@end
