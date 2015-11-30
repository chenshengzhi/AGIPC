//
//  AGImagePickerController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGImagePickerController.h"

#import "AGIPCAlbumsController.h"
#import "AGIPCAssetItem.h"

static AGImagePickerController *_sharedInstance = nil;

@interface AGImagePickerController ()

@end

@implementation AGImagePickerController

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static ALAssetsLibrary *assetsLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) { }];
    });
    
    return assetsLibrary;
}

+ (AGImagePickerController *)sharedInstance:(id)delegate {
    if (nil == _sharedInstance){
        @synchronized(self) {
            if (nil == _sharedInstance){
                _sharedInstance  = [AGImagePickerController imagePickerWithDelegate:nil];
            }
        }
    }
    _sharedInstance.delegate = delegate;
    return _sharedInstance;
}

+ (AGImagePickerController *)imagePickerWithDelegate:(id<AGImagePickerControllerDelegate, NSObject>)delegate {
    AGImagePickerController *picker = [[AGImagePickerController alloc] initWithDelegate:delegate];
    
    picker.shouldShowSavedPhotosOnTop = YES;
    picker.shouldChangeStatusBarStyle = YES;
    picker.maximumNumberOfPhotosToBeSelected = 5;

    return picker;
}

#pragma mark - Properties -

- (AGImagePickerControllerSelectionMode)selectionMode {
    return (self.maximumNumberOfPhotosToBeSelected == 1 ? AGImagePickerControllerSelectionModeSingle : AGImagePickerControllerSelectionModeMultiple);
}

- (void)setPickerDelegate:(id<AGImagePickerControllerDelegate>)pickerDelegate {
    _pickerDelegate = pickerDelegate;
    
    _pickerFlags.delegateNumberOfItemsPerRowForDevice = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:numberOfItemsPerRowForDevice:andInterfaceOrientation:)];
    _pickerFlags.delegateShouldDisplaySelectionInformationInSelectionMode = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:shouldDisplaySelectionInformationInSelectionMode:)];
    _pickerFlags.delegateShouldShowToolbarForManagingTheSelectionInSelectionMode = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:shouldShowToolbarForManagingTheSelectionInSelectionMode:)];
    _pickerFlags.delegateDidFinishPickingMediaWithInfo = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:didFinishPickingMediaWithInfo:)];
    _pickerFlags.delegateDidFail = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:didFail:)];
}

- (void)setShouldChangeStatusBarStyle:(BOOL)shouldChangeStatusBarStyle {
    if (_shouldChangeStatusBarStyle != shouldChangeStatusBarStyle)
    {
        _shouldChangeStatusBarStyle = shouldChangeStatusBarStyle;
        
        if (_shouldChangeStatusBarStyle) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:_oldStatusBarStyle animated:YES];
        }
    }
}

- (void)setMaximumNumberOfPhotosToBeSelected:(NSUInteger)maximumNumberOfPhotosToBeSelected {
    _maximumNumberOfPhotosToBeSelected = maximumNumberOfPhotosToBeSelected;
    [AGIPCAssetItem setMaximumNumberOfPhotosToBeSelected:maximumNumberOfPhotosToBeSelected];
}

#pragma mark - Object Lifecycle -

- (id)init {
    return [self initWithDelegate:nil failureBlock:nil successBlock:nil maximumNumberOfPhotosToBeSelected:0 shouldChangeStatusBarStyle:SHOULD_CHANGE_STATUS_BAR_STYLE toolbarItemsForManagingTheSelection:nil andShouldShowSavedPhotosOnTop:SHOULD_SHOW_SAVED_PHOTOS_ON_TOP];
}

- (id)initWithDelegate:(id)delegate {
    return [self initWithDelegate:delegate failureBlock:nil successBlock:nil maximumNumberOfPhotosToBeSelected:0 shouldChangeStatusBarStyle:SHOULD_CHANGE_STATUS_BAR_STYLE toolbarItemsForManagingTheSelection:nil andShouldShowSavedPhotosOnTop:SHOULD_SHOW_SAVED_PHOTOS_ON_TOP];
}

- (id)initWithFailureBlock:(AGIPCDidFail)failureBlock
           andSuccessBlock:(AGIPCDidFinish)successBlock {
    return [self initWithDelegate:nil failureBlock:failureBlock successBlock:successBlock maximumNumberOfPhotosToBeSelected:0 shouldChangeStatusBarStyle:SHOULD_CHANGE_STATUS_BAR_STYLE toolbarItemsForManagingTheSelection:nil andShouldShowSavedPhotosOnTop:SHOULD_SHOW_SAVED_PHOTOS_ON_TOP];
}

- (id)initWithDelegate:(id)delegate
          failureBlock:(AGIPCDidFail)failureBlock
          successBlock:(AGIPCDidFinish)successBlock
maximumNumberOfPhotosToBeSelected:(NSUInteger)maximumNumberOfPhotosToBeSelected
shouldChangeStatusBarStyle:(BOOL)shouldChangeStatusBarStyle
toolbarItemsForManagingTheSelection:(NSArray *)toolbarItemsForManagingTheSelection
andShouldShowSavedPhotosOnTop:(BOOL)shouldShowSavedPhotosOnTop {
    self = [super init];
    if (self)
    {
        _oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        
        self.shouldChangeStatusBarStyle = shouldChangeStatusBarStyle;
        self.shouldShowSavedPhotosOnTop = shouldShowSavedPhotosOnTop;
        
        self.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationBar.translucent = YES;
        self.toolbar.barStyle = UIBarStyleDefault;
        self.toolbar.translucent = YES;
        
        self.selection = nil;
        self.maximumNumberOfPhotosToBeSelected = maximumNumberOfPhotosToBeSelected;
        self.pickerDelegate = delegate;
        
        self.didFailBlock = failureBlock;
        self.didFinishBlock = successBlock;
        
        self.viewControllers = @[[[AGIPCAlbumsController alloc] initWithImagePickerController:self]];
    }
    
    return self;
}

- (void)showAssetsControllerWithName:(NSString *)name {
    AGIPCAlbumsController *albumsCtl = (AGIPCAlbumsController *)[self.viewControllers firstObject];
    if (0 == [name length]) {
        if ([albumsCtl respondsToSelector:@selector(pushFirstAssetsController)]) {
            [albumsCtl pushFirstAssetsController];
        }
    } else {
        if ([albumsCtl respondsToSelector:@selector(pushAssetsControllerWithName:)]) {
            [albumsCtl pushAssetsControllerWithName:name];
        }
    }
}

- (void)showFirstAssetsController {
    [self showAssetsControllerWithName:nil];
}

#pragma mark - View lifecycle -
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Private -

- (void)didFinishPickingAssets:(NSArray *)selectedAssets {
    self.userIsDenied = NO;
    
    [AGIPCAssetItem setNumberOfSelections:0];
    
    if (self.didFinishBlock)
        self.didFinishBlock(selectedAssets);
    
	if (_pickerFlags.delegateDidFinishPickingMediaWithInfo)
    {
        [self.pickerDelegate agImagePickerController:self didFinishPickingMediaWithInfo:selectedAssets];
	}
}

- (void)didCancelPickingAssets {
    [AGIPCAssetItem setNumberOfSelections:0];
    
    if (self.didFailBlock) {
        self.didFailBlock(nil);
    }
    
    if (_pickerFlags.delegateDidFail)
    {
        [self.pickerDelegate agImagePickerController:self didFail:nil];
	}
}

- (void)didFail:(NSError *)error {
    if (nil != error) {
        self.userIsDenied = YES;
    }
    
    [self popToRootViewControllerAnimated:NO];
    
    [AGIPCAssetItem setNumberOfSelections:0];
    
    if (self.didFailBlock)
        self.didFailBlock(error);
    
    if (_pickerFlags.delegateDidFail)
    {
        [self.pickerDelegate agImagePickerController:self didFail:error];
	}
}

@end
