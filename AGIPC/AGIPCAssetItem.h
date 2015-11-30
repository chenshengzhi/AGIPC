//
//  AGIPCAssetItem.h
//  MengDaa
//
//  Created by 陈圣治 on 15/11/26.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AGIPCAssetItem : NSObject

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, strong) ALAsset *asset;

+ (NSUInteger)numberOfSelections;

+ (void)setNumberOfSelections:(NSUInteger)number;

+ (void)setMaximumNumberOfPhotosToBeSelected:(NSUInteger)maxNumber;

- (instancetype)initWithAsset:(ALAsset *)asset;

- (BOOL)canSelect;

@end
