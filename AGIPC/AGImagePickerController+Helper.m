//
//  AGImagePickerController+Helper.m
//  AGImagePickerController Demo
//
//  Created by Artur Grigor on 06.02.2013.
//  Copyright (c) 2013 Artur Grigor. All rights reserved.
//

#import "AGImagePickerController.h"
#import "AGImagePickerController+Helper.h"

#import <objc/runtime.h>

@implementation AGImagePickerController (Helper)

#pragma mark - Configuring Rows -

- (NSUInteger)numberOfItemsPerRow {
    if (_pickerFlags.delegateNumberOfItemsPerRowForDevice)
    {
        AGDeviceType deviceType = self.deviceType;
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (nil != self.pickerDelegate && [self.pickerDelegate respondsToSelector:@selector(agImagePickerController:numberOfItemsPerRowForDevice:andInterfaceOrientation:)]) {
            return [self.pickerDelegate agImagePickerController:self numberOfItemsPerRowForDevice:deviceType andInterfaceOrientation:interfaceOrientation];
        }
        return self.defaultNumberOfItemsPerRow;
    } else {
        return self.defaultNumberOfItemsPerRow;
    }
}

- (NSUInteger)defaultNumberOfItemsPerRow {
    NSUInteger numberOfItemsPerRow = 0;
    
    if (IS_IPAD())
    {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            numberOfItemsPerRow = AGIPC_ITEMS_PER_ROW_IPAD_PORTRAIT;
        } else
        {
            numberOfItemsPerRow = AGIPC_ITEMS_PER_ROW_IPAD_LANDSCAPE;
        }
    } else
    {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            numberOfItemsPerRow = AGIPC_ITEMS_PER_ROW_IPHONE_PORTRAIT;
            
        } else
        {
            numberOfItemsPerRow = AGIPC_ITEMS_PER_ROW_IPHONE_LANDSCAPE;
        }
    }
    
    return numberOfItemsPerRow;
}

#pragma mark - Appearance Configuration -

- (BOOL)shouldDisplaySelectionInformation {
    if (_pickerFlags.delegateShouldDisplaySelectionInformationInSelectionMode)
    {
        AGImagePickerControllerSelectionMode selectionMode = self.selectionMode;
        
        if (nil != self.pickerDelegate && [self.pickerDelegate respondsToSelector:@selector(agImagePickerController:shouldDisplaySelectionInformationInSelectionMode:)]) {
            return [self.pickerDelegate agImagePickerController:self shouldDisplaySelectionInformationInSelectionMode:selectionMode];
        }
        return SHOULD_DISPLAY_SELECTION_INFO;
    } else {
        return SHOULD_DISPLAY_SELECTION_INFO;
    }
}

#pragma mark - Others -

- (AGDeviceType)deviceType {
    return (IS_IPAD() ? AGDeviceTypeiPad : AGDeviceTypeiPhone);
}

@end

@implementation NSInvocation (Addon)

#pragma mark - Invocation -

+ (id)invocationWithProtocol:(Protocol *)targetProtocol selector:(SEL)selector andRequiredFlag:(BOOL)isMethodRequired {
	struct objc_method_description desc;
	desc = protocol_getMethodDescription(targetProtocol, selector, isMethodRequired, YES);
	if (desc.name == NULL)
		return nil;
	
	NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:desc.types];
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
	[inv setSelector:selector];
	return inv;
}

@end
