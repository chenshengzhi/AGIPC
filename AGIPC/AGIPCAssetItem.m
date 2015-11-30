//
//  AGIPCAssetItem.m
//  MengDaa
//
//  Created by 陈圣治 on 15/11/26.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "AGIPCAssetItem.h"

static NSUInteger _numberOfSelectedItems = 0;
static NSUInteger _maximumNumberOfPhotosToBeSelected = 0;

@implementation AGIPCAssetItem

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
        if (_selected) {
            _numberOfSelectedItems++;
        } else {
            _numberOfSelectedItems--;
        }
    }
}

+ (NSUInteger)numberOfSelections {
    return _numberOfSelectedItems;
}

+ (void)setNumberOfSelections:(NSUInteger)number {
    _numberOfSelectedItems = number;
}

+ (void)setMaximumNumberOfPhotosToBeSelected:(NSUInteger)maxNumber {
    _maximumNumberOfPhotosToBeSelected = maxNumber;
}

- (instancetype)initWithAsset:(ALAsset *)asset {
    if (self = [super init]) {
        self.asset = asset;
    }
    return self;
}

- (BOOL)canSelect {
    if (_maximumNumberOfPhotosToBeSelected == 1) {
        return YES;
    } else {
        if (_maximumNumberOfPhotosToBeSelected > 1) {
            return ([AGIPCAssetItem numberOfSelections] < _maximumNumberOfPhotosToBeSelected);
        } else {
            return YES;
        }
    }
}

- (BOOL)isEqual:(id)object {
    if (object && [object isKindOfClass:[AGIPCAssetItem class]]) {
        AGIPCAssetItem *another = (AGIPCAssetItem *)object;
        return [self.asset isEqual:another.asset];
    }
    return NO;
}

@end
