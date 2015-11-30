//
//  AGImagePickerController+Helper.h
//  AGImagePickerController Demo
//
//  Created by Artur Grigor on 06.02.2013.
//  Copyright (c) 2013 Artur Grigor. All rights reserved.
//

#import "AGImagePickerController.h"

@interface AGImagePickerController (Helper)

- (NSUInteger)defaultNumberOfItemsPerRow;
- (NSUInteger)numberOfItemsPerRow;

- (BOOL)shouldDisplaySelectionInformation;

- (AGDeviceType)deviceType;

@end

@interface NSInvocation (Addon)

+ (id)invocationWithProtocol:(Protocol *)targetProtocol selector:(SEL)selector andRequiredFlag:(BOOL)isMethodRequired;

@end