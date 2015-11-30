//
//  ViewController.m
//  AGIPCDemo
//
//  Created by 陈圣治 on 15/11/27.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "ViewController.h"
#import "AGIPCDemoCell.h"
#import "UIView+AGIPCPhotoBrowser.h"
#import "AGImagePickerController.h"
#import "AGIPCPhotoBrowser.h"

@interface ViewController () <AGImagePickerControllerDelegate, AGIPCPhotoBrowserDelegate>

@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) AGIPCDemoCell *addCell;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([AGIPCDemoCell class]) bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([AGIPCDemoCell class]) bundle:nil] forCellWithReuseIdentifier:@"add"];
    
    _datasource = [NSMutableArray array];
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datasource.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _datasource.count) {
        AGIPCDemoCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"add" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"add"];
        return cell;
    } else {
        AGIPCDemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        cell.assetItem = _datasource[indexPath.row];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _datasource.count) {
        AGImagePickerController *picker = [[AGImagePickerController alloc] initWithDelegate:self];
        picker.selection = _datasource;
        picker.maximumNumberOfPhotosToBeSelected = 10;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        AGIPCPhotoBrowser *browser = [[AGIPCPhotoBrowser alloc] initWithDelegate:self currentIndex:indexPath.row];
        browser.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browser];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - AGImagePickerControllerDelegate -
- (void)agImagePickerController:(AGImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    _datasource = info;
    [self.collectionView reloadData];
}

- (void)agImagePickerController:(AGImagePickerController *)picker didFail:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AGIPCPhotoBrowserDelegate -
- (NSUInteger)numberOfAssetItemInPhotoBrowser:(AGIPCPhotoBrowser *)photoBrowser {
    return _datasource.count;
}

- (AGIPCAssetItem *)photobrowser:(AGIPCPhotoBrowser *)photoBrowser assetItemAtIndex:(NSUInteger)index {
    return _datasource[index];
}

- (void)photobrowser:(AGIPCPhotoBrowser *)photoBrowse doneWithCurrentAssetItem:(AGIPCAssetItem *)assetItem {
    [self dismissViewControllerAnimated:YES completion:nil];
    _datasource = [_datasource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected = 1"]];
    [self.collectionView reloadData];
}

@end
