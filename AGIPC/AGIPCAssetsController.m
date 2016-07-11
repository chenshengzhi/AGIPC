//
//  AGIPCAssetsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCAssetsController.h"
#import "AGImagePickerController+Helper.h"
#import "AGIPCPhotoBrowser.h"
#import "AGIPCAssetCell.h"

@interface AGIPCAssetsController () <AGIPCPhotoBrowserDelegate, AGIPCAssetCellDelegate> {
    UIInterfaceOrientation lastOrientation;
}

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *selectedAssets;

@end

@interface AGIPCAssetsController (Private)

- (void)changeSelectionInformation;

- (void)didChangeLibrary:(NSNotification *)notification;

- (void)loadAssets;
- (void)reloadData;

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)doneAction:(id)sender;
- (void)selectAllAction:(id)sender;
- (void)deselectAllAction:(id)sender;

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

@end

@implementation AGIPCAssetsController

#pragma mark - Properties -

- (void)setAssetsGroup:(ALAssetsGroup *)theAssetsGroup {
    if (_assetsGroup != theAssetsGroup) {
        _assetsGroup = theAssetsGroup;
        [_assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    }
}

#pragma mark - Object Lifecycle -

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController andAssetsGroup:(ALAssetsGroup *)assetsGroup {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    NSUInteger numberOfItemsPerRow = [imagePickerController numberOfItemsPerRow];
    CGFloat width = fmin([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - (numberOfItemsPerRow-1) * layout.minimumInteritemSpacing;
    layout.itemSize = CGSizeMake(floor(width/numberOfItemsPerRow), floor(width/numberOfItemsPerRow));
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.assetsGroup = assetsGroup;
        _assets = [[NSMutableArray alloc] init];
        _selectedAssets = [[NSMutableArray alloc] init];
        
        self.imagePickerController = imagePickerController;
        
        self.title = NSLocalizedString(@"加载...", nil);
        self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        
        [self loadAssets];
    }
    
    return self;
}

- (void)dealloc {
    [self unregisterFromNotifications];
}

#pragma mark - View Lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[AGIPCAssetCell class] forCellWithReuseIdentifier:@"cell"];
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    doneButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [self reloadData];
    
    [self registerForNotifications];
    
    [AGIPCAssetItem setNumberOfSelections:0];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self unregisterFromNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (lastOrientation != [UIApplication sharedApplication].statusBarOrientation) {
        [self reloadData];
    }
    
    [self.collectionView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (! self.imagePickerController) return 0;

    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AGIPCAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.item = self.assets[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    AGIPCPhotoBrowser *browser = [[AGIPCPhotoBrowser alloc] initWithDelegate:self currentIndex:indexPath.row];
    browser.checkButtonNormalImage = self.imagePickerController.checkButtonNormalImage;
    browser.checkButtonSelectedImage = self.imagePickerController.checkButtonSelectedImage;
    browser.delegate = self;
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - AGIPCAssetCellDelegate -
- (void)assetCell:(AGIPCAssetCell *)cell didSelect:(AGIPCAssetItem *)assetItem {
    [self selectItem:assetItem];
}

- (void)assetCell:(AGIPCAssetCell *)cell didDeselect:(AGIPCAssetItem *)assetItem {
    [self deselectItem:assetItem];
}

- (UIImage *)assetCell:(AGIPCAssetCell *)cell checkButtonImageForItem:(AGIPCAssetItem *)assetItem {
    if (assetItem.selected) {
        return self.imagePickerController.checkButtonSelectedImage;
    } else {
        return self.imagePickerController.checkButtonNormalImage;
    }
}

#pragma mark - AGIPCPhotoBrowserDelegate -
- (NSUInteger)numberOfAssetItemInPhotoBrowser:(AGIPCPhotoBrowser *)photoBrowser {
    return self.assets.count;
}

- (AGIPCAssetItem *)photobrowser:(AGIPCPhotoBrowser *)photoBrowser assetItemAtIndex:(NSUInteger)index {
    return self.assets[index];
}

- (void)photobrowser:(AGIPCPhotoBrowser *)photoBrowse doneWithCurrentAssetItem:(AGIPCAssetItem *)assetItem {
    [self.imagePickerController didFinishPickingAssets:self.selectedAssets];
}

- (void)photoBrowser:(AGIPCPhotoBrowser *)photoBrowser selectAssetItem:(AGIPCAssetItem *)assetItem {
    [self selectItem:assetItem];
}

- (void)photoBrowser:(AGIPCPhotoBrowser *)photoBrowser deselectAssetItem:(AGIPCAssetItem *)assetItem {
    [self deselectItem:assetItem];
}

#pragma mark - Private -
- (void)loadAssets {
    [AGIPCAssetItem setNumberOfSelections:0];
    
    [self.assets removeAllObjects];
    
    __weak AGIPCAssetsController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        __strong AGIPCAssetsController *strongSelf = weakSelf;
        
        @autoreleasepool {
            [strongSelf.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result == nil) 
                {
                    return;
                }
                if (strongSelf.imagePickerController.shouldShowPhotosWithLocationOnly) {
                    CLLocation *assetLocation = [result valueForProperty:ALAssetPropertyLocation];
                    if (!assetLocation || !CLLocationCoordinate2DIsValid([assetLocation coordinate])) {
                        return;
                    }
                }
                
                AGIPCAssetItem *item = [[AGIPCAssetItem alloc] initWithAsset:result];
                if ([self.imagePickerController.selection containsObject:item]) {
                    item.selected = YES;
                    [strongSelf.selectedAssets addObject:item];
                }
                [strongSelf.assets addObject:item];
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [strongSelf reloadData];
            
        });
    
    });
}

- (void)reloadData {
    [self.collectionView reloadData];
    
    [self changeSelectionInformation];
    
    NSInteger totalRows = [self.collectionView numberOfItemsInSection:0];
    if (totalRows > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:totalRows-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)doneAction:(id)sender {
    [self.imagePickerController didFinishPickingAssets:self.selectedAssets];
}

- (void)selectAllAction:(id)sender {
    for (AGIPCAssetItem *gridItem in self.assets) {
        gridItem.selected = YES;
    }
}

- (void)deselectAllAction:(id)sender {
    for (AGIPCAssetItem *gridItem in self.assets) {
        gridItem.selected = NO;
    }
}

- (void)changeSelectionInformation {
    if (!self.view.window) {
        return;
    }
    self.navigationItem.rightBarButtonItem.enabled = ([AGIPCAssetItem numberOfSelections] > 0);
    
    if (self.imagePickerController.shouldDisplaySelectionInformation) {
        if (0 == [AGIPCAssetItem numberOfSelections] ) {
            self.navigationController.navigationBar.topItem.prompt = nil;
        } else {
            NSInteger maxNumber = _imagePickerController.maximumNumberOfPhotosToBeSelected;
            if (0 < maxNumber) {
                self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%lu/%ld)", (unsigned long)[AGIPCAssetItem numberOfSelections], (long)maxNumber];
            } else {
                self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%lu/%lu)", (unsigned long)[AGIPCAssetItem numberOfSelections], (unsigned long)self.assets.count];
            }
        }
    }
}

- (void)selectItem:(AGIPCAssetItem *)assetItem {
    if (self.imagePickerController.selectionMode == AGImagePickerControllerSelectionModeSingle) {
        for (AGIPCAssetItem *item in self.assets) {
            if (item != assetItem && item.selected) {
                item.selected = NO;
            }
        }
    }
    if (nil == _selectedAssets) {
        _selectedAssets = [[NSMutableArray alloc] init];
    }
    if ([_selectedAssets containsObject:assetItem]) {
        [_selectedAssets removeObject:assetItem];
    }
    [_selectedAssets addObject:assetItem];
    [self changeSelectionInformation];
}

- (void)deselectItem:(AGIPCAssetItem *)assetItem {
    [_selectedAssets removeObject:assetItem];
    [self changeSelectionInformation];
}

#pragma mark - Notifications -

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didChangeLibrary:) 
                                                 name:ALAssetsLibraryChangedNotification 
                                               object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ALAssetsLibraryChangedNotification 
                                                  object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadAssets];
    });
}

@end
