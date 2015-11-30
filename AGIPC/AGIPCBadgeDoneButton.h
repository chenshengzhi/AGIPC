//
//  AGIPCBadgeDoneButton.h
//  AGIPCPhotoBrowserDemo
//
//  Created by 陈圣治 on 15/11/25.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGIPCBadgeDoneButton : UIView

@property (nonatomic, copy) NSString *badgeValue;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addTaget:(id)target action:(SEL)action;

@end
