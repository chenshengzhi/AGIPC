//
//  AGImagePickerControllerDefines.h
//  AGImagePickerController
//
//  Created by Artur Grigor on 28.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#pragma mark ARC

#if __has_feature(objc_arc_weak)
    #define ag_weak weak
    #define __ag_weak __weak
#elif __has_feature(objc_arc)
    #define ag_weak unsafe_unretained
    #define __ag_weak __unsafe_unretained
#else
    #define ag_weak
    #define __ag_weak
#endif

#pragma mark - Utilities -

#define IS_IPAD()                                                               ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && \
[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#pragma mark - Constants -

#define SHOULD_CHANGE_STATUS_BAR_STYLE                                          1
#define SHOULD_DISPLAY_SELECTION_INFO                                           1
#define SHOULD_SHOW_SAVED_PHOTOS_ON_TOP                                         1

#define AGIPC_CHECKMARK_WIDTH                                                   28.f
#define AGIPC_CHECKMARK_HEIGHT                                                  28.f
#define AGIPC_CHECKMARK_RIGHT_MARGIN                                            4.f
#define AGIPC_CHECKMARK_BOTTOM_MARGIN                                           4.f

#define AGIPC_ITEMS_PER_ROW_IPHONE_PORTRAIT                                     4
#define AGIPC_ITEMS_PER_ROW_IPHONE_LANDSCAPE                                    6
#define AGIPC_ITEMS_PER_ROW_IPAD_PORTRAIT                                       8
#define AGIPC_ITEMS_PER_ROW_IPAD_LANDSCAPE                                      12

#pragma mark - Types -

typedef void (^AGIPCDidFinish)(NSArray *info);
typedef void (^AGIPCDidFail)(NSError *error);

typedef NS_ENUM(NSUInteger, AGDeviceType) {
    AGDeviceTypeiPad,
    AGDeviceTypeiPhone
};

typedef NS_ENUM(NSUInteger, AGImagePickerControllerSelectionMode) {
    AGImagePickerControllerSelectionModeSingle,
    AGImagePickerControllerSelectionModeMultiple
};
