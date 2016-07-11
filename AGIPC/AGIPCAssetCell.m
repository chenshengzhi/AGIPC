//
//  AGIPCAssetCell.m
//  MengDaa
//
//  Created by 陈圣治 on 15/11/26.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "AGIPCAssetCell.h"

@interface AGIPCAssetCell ()

@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIImageView *thumbnailImageView;

@end

@implementation AGIPCAssetCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.thumbnailImageView];
        
        CGRect checkmarkFrame = CGRectMake(frame.size.width - AGIPC_CHECKMARK_RIGHT_MARGIN*2 - AGIPC_CHECKMARK_WIDTH,
                                           0,
                                           AGIPC_CHECKMARK_WIDTH + AGIPC_CHECKMARK_RIGHT_MARGIN*2,
                                           AGIPC_CHECKMARK_HEIGHT + AGIPC_CHECKMARK_BOTTOM_MARGIN*2);
        self.checkButton = [[UIButton alloc] initWithFrame:checkmarkFrame];
        [self.checkButton addTarget:self action:@selector(tapCheckMark) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.checkButton];
    }
    return self;
}

- (void)setItem:(AGIPCAssetItem *)item {
    if (_item != item) {
        _item = item;
        self.thumbnailImageView.image = [UIImage imageWithCGImage:item.asset.thumbnail];
    }
    [self updateCheckButtonDisplay];
}

- (void)updateCheckButtonDisplay {
    UIImage *image = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetCell:checkButtonImageForItem:)]) {
        image = [self.delegate assetCell:self checkButtonImageForItem:self.item];
    }
    if (!image) {
        if (self.item.selected) {
            image = [UIImage imageNamed:@"AGIPC_check_selected"];
        } else {
            image = [UIImage imageNamed:@"AGIPC_check_default"];
        }
    }
    [self.checkButton setImage:image forState:UIControlStateNormal];
}

- (void)tapCheckMark {
    if (self.item.selected) {
        if (_delegate && [_delegate respondsToSelector:@selector(assetCell:didDeselect:)]) {
            self.item.selected = NO;
            [_delegate assetCell:self didDeselect:self.item];
        }
    } else {
        if (self.item.canSelect) {
            self.item.selected = YES;
            [_delegate assetCell:self didSelect:self.item];
        }
    }
    [self updateCheckButtonDisplay];
}

@end
