//
//  AGIPCDemoCell.h
//  AGIPCDemo
//
//  Created by 陈圣治 on 15/11/27.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGIPCAssetItem.h"

@interface AGIPCDemoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) AGIPCAssetItem *assetItem;

@end
