//
//  AGIPCBadgeDoneButton.m
//  AGIPCPhotoBrowserDemo
//
//  Created by 陈圣治 on 15/11/25.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "AGIPCBadgeDoneButton.h"
#import "UIView+AGIPCPhotoBrowser.h"

static CGFloat const kDoneButtonTextWitdh = 38.0f;

@interface AGIPCBadgeDoneButton ()

@property (nonatomic, strong) UILabel *badgeValueLabel;
@property (nonatomic, strong) UIView *backGroudView;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation AGIPCBadgeDoneButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, 58, 26);
        [self setupViews];
        self.badgeValue = @"0";
    }
    return self;
}

- (void)setupViews {
    _backGroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _backGroudView.centerY = self.centerY;
    _backGroudView.backgroundColor = [UIColor colorWithRed:0.243 green:0.643 blue:0.212 alpha:1.000];
    _backGroudView.layer.cornerRadius = _backGroudView.height/2;
    [self addSubview:_backGroudView];
    
    _badgeValueLabel = [[UILabel alloc] initWithFrame:_backGroudView.frame];
    _badgeValueLabel.backgroundColor = [UIColor clearColor];
    _badgeValueLabel.textColor = [UIColor whiteColor];
    _badgeValueLabel.font = [UIFont systemFontOfSize:15.0f];
    _badgeValueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_badgeValueLabel];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(0, 0, self.width, self.height);
    [_doneButton setTitle:NSLocalizedString(@"确定", nil)
                 forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor colorWithRed:0.243 green:0.643 blue:0.212 alpha:1.000] forState:UIControlStateNormal];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    _doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    _doneButton.backgroundColor = [UIColor clearColor];
    [self addSubview:_doneButton];
}

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue;
    if (_badgeValue.integerValue <= 0) {
        [self hideBadgeValue];
    } else {
        CGRect rect = [_badgeValue boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)
                                                options:NSStringDrawingTruncatesLastVisibleLine
                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                                context:nil];
        self.badgeValueLabel.frame = CGRectMake(self.badgeValueLabel.left, self.badgeValueLabel.top, (rect.size.width + 9) > 20?(rect.size.width + 9):20, 20);
        self.backGroudView.width = self.badgeValueLabel.width;
        self.backGroudView.height = self.badgeValueLabel.height;
        
        self.doneButton.width = self.badgeValueLabel.width + kDoneButtonTextWitdh;
        self.width = self.doneButton.width;
        
        self.badgeValueLabel.text = _badgeValue;
        
        [self showBadgeValue];
        self.backGroudView.transform =CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:0.2 animations:^{
            self.backGroudView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.1 animations:^{
                self.backGroudView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }];
    }
}

- (void)showBadgeValue {
    self.badgeValueLabel.hidden = NO;
    self.backGroudView.hidden = NO;
}

- (void)hideBadgeValue {
    self.badgeValueLabel.hidden = YES;
    self.backGroudView.hidden = YES;
    self.doneButton.adjustsImageWhenDisabled = YES;
}


- (void)addTaget:(id)target action:(SEL)action {
    [self.doneButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
