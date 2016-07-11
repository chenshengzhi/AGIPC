//
//  UIImage+TintColor.m
//  AGIPCDemo
//
//  Created by 陈圣治 on 16/7/11.
//  Copyright © 2016年 shengzhichen. All rights reserved.
//

#import "UIImage+TintColor.h"

@implementation UIImage (TintColor)

- (UIImage *)imageWithTintColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:rect];
    [tintColor set];
    UIRectFillUsingBlendMode(rect, kCGBlendModeColor);
    [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1];
    UIImage *tintImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintImage;
}

@end
