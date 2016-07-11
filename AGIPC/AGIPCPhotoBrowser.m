//
//  AGIPCPhotoBrowser.m
//  AGIPCPhotoBrowserDemo
//
//  Created by 陈圣治 on 15/11/25.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "AGIPCPhotoBrowser.h"
#import "AGIPCBadgeDoneButton.h"
#import "AGIPCBrowserCell.h"

@interface AGIPCPhotoBrowser () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AGIPCBrowserCellDelegate> {
    BOOL _statusBarShouldBeHidden;
    BOOL _viewIsActive;

    BOOL _previousNavBarHidden;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) AGIPCBadgeDoneButton *badgeDoneButton;

@property (nonatomic, strong) NSMutableArray<AGIPCAssetItem *> *cachedDataSource;
@property (nonatomic) NSUInteger selectedNumber;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation AGIPCPhotoBrowser

#pragma mark - life cycle -
- (instancetype)initWithDelegate:(id<AGIPCPhotoBrowserDelegate>)delegate currentIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _currentIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self reloadData];
    
    if (!_viewIsActive && [self.navigationController.viewControllers objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.frame.size.width * self.currentIndex,0)];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers objectAtIndex:0] != self &&
        ![self.navigationController.viewControllers containsObject:self]) {
        
        _viewIsActive = NO;
        [self restorePreviousNavBarAppearance:animated];
    }

    [self.navigationController.navigationBar.layer removeAllAnimations];
    [self setControlsHidden:NO animated:NO];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    _viewIsActive = NO;
    [super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    CGFloat height = 44;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        height = 32;
    }
    self.toolbar.frame = CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.frame = CGRectMake(-10, 0, self.view.bounds.size.width + 20, self.view.bounds.size.height);
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = self.collectionView.bounds.size;
    
    NSUInteger index = _currentIndex;
    [self.collectionView reloadData];
    self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width * index, 0);
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.alpha = _toolbar.alpha;
    
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    self.navigationController.navigationBar.alpha = _toolbar.alpha;
    
    [super viewDidLayoutSubviews];
}

#pragma mark - priviate -
- (void)setupView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    [self collectionView];
    [self toolbar];
    [self setupBarButtonItems];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.checkButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)setupBarButtonItems {
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithCustomView:self.badgeDoneButton];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item4.width = -10;

    [self.toolbar setItems:@[item2,item3,item4]];
}

- (void)updateNavigationBarAndToolBar {
    NSUInteger totalNumber = self.cachedDataSource.count;
    self.title = [NSString stringWithFormat:@"%@/%@", @(self.currentIndex+1), @(totalNumber)];
    AGIPCAssetItem *assetItem = [self.cachedDataSource objectAtIndex:self.currentIndex];
    self.checkButton.selected = assetItem.selected;
}

- (void)updateSelestedNumber {
    [AGIPCAssetItem setNumberOfSelections:_selectedNumber];
    self.badgeDoneButton.badgeValue = [NSString stringWithFormat:@"%@", @(_selectedNumber)];
}

#pragma mark - Nav Bar Appearance -
- (void)setNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)storePreviousNavBarAppearance {
    _previousNavBarHidden = self.navigationController.navigationBarHidden;
}

- (void)restorePreviousNavBarAppearance:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
}

#pragma mark - ui actions -
- (void)checkButtonAction {
    AGIPCAssetItem *item = self.cachedDataSource[self.currentIndex];
    if (item.isSelected) {
        self.checkButton.selected = NO;
        item.selected = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:deselectAssetItem:)]) {
            [self.delegate photoBrowser:self deselectAssetItem:item];
        }
        _selectedNumber--;
    } else {
        if (item.canSelect) {
            self.checkButton.selected = YES;
            item.selected = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:selectAssetItem:)]) {
                [self.delegate photoBrowser:self selectAssetItem:item];
            }
            _selectedNumber++;
        }
    }
    
    [self updateSelestedNumber];
}

- (void)badgeDoneButtonAction {
    if ([self.delegate respondsToSelector:@selector(photobrowser:doneWithCurrentAssetItem:)]) {
        [self.delegate photobrowser:self doneWithCurrentAssetItem:self.cachedDataSource[self.currentIndex]];
    }
}

- (void)reloadData {
    self.cachedDataSource = [NSMutableArray array];
    NSUInteger count = [self.delegate numberOfAssetItemInPhotoBrowser:self];
    for (int i = 0; i < count; i++) {
        AGIPCAssetItem *item = [self.delegate photobrowser:self assetItemAtIndex:i];
        if (item) {
            [self.cachedDataSource addObject:item];
            if (item.selected) {
                _selectedNumber++;
            }
        }
    }
    if (_currentIndex >= count) {
        _currentIndex = count - 1;
    }
    [self.collectionView reloadData];
    [self updateSelestedNumber];
    [self updateNavigationBarAndToolBar];
}

#pragma mark - get/set -
- (UIButton *)checkButton {
    if (nil == _checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.frame = CGRectMake(0, 0, 25, 25);
        if (_checkButtonNormalImage) {
            [_checkButton setImage:_checkButtonNormalImage forState:UIControlStateNormal];
        } else {
            [_checkButton setImage:[UIImage imageNamed:@"AGIPC_check_default"] forState:UIControlStateNormal];
        }
        if (_checkButtonSelectedImage) {
            [_checkButton setImage:_checkButtonSelectedImage forState:UIControlStateSelected];
        } else {
            [_checkButton setImage:[UIImage imageNamed:@"AGIPC_check_selected"] forState:UIControlStateSelected];
        }
        [_checkButton addTarget:self action:@selector(checkButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}

- (AGIPCBadgeDoneButton *)badgeDoneButton {
    if (nil == _badgeDoneButton) {
        _badgeDoneButton = [[AGIPCBadgeDoneButton alloc] initWithFrame:CGRectZero];
        [_badgeDoneButton addTaget:self action:@selector(badgeDoneButtonAction)];
    }
    return  _badgeDoneButton;
}

- (UIToolbar *)toolbar {
    if (nil == _toolbar) {
        CGFloat height = 44;
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            height = 32;
        }
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height)];
        [self.view addSubview:_toolbar];
    }
    return _toolbar;
}

- (UICollectionView *)collectionView {
    if (nil == _collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.bounds.size.width+20, self.view.bounds.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[AGIPCBrowserCell class] forCellWithReuseIdentifier:NSStringFromClass([AGIPCBrowserCell class])];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)setMaximumNumberOfPhotosToBeSelected:(NSUInteger)maximumNumberOfPhotosToBeSelected {
    _maximumNumberOfPhotosToBeSelected = maximumNumberOfPhotosToBeSelected;
    [AGIPCAssetItem setMaximumNumberOfPhotosToBeSelected:maximumNumberOfPhotosToBeSelected];
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cachedDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AGIPCBrowserCell *cell = (AGIPCBrowserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AGIPCBrowserCell class]) forIndexPath:indexPath];
    cell.assetItem = self.cachedDataSource[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout -
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - AGIPCBrowserCellDelegate -
- (void)browserCellSingleTap:(AGIPCBrowserCell *)cell {
    [self toggleControls];
}

#pragma mark - scrollerViewDelegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat itemWidth = CGRectGetWidth(self.collectionView.frame);
    if (offsetX >= 0){
        NSInteger page = offsetX / itemWidth;
        [self didScrollToPage:page];
    }
}

- (void)didScrollToPage:(NSInteger)page {
    self.currentIndex = page;
    [self updateNavigationBarAndToolBar];
}

#pragma mark - Control Hiding / Showing -
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated {
    if (nil == self.cachedDataSource || self.cachedDataSource.count == 0) {
        hidden = NO;
    }
    
    CGFloat height = 44;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        height = 32;
    }
    
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    _statusBarShouldBeHidden = hidden;
    
    CGRect frame = CGRectIntegral(CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height));
    
    if ([self areControlsHidden] && !hidden && animated) {
        self.toolbar.frame = CGRectOffset(frame, 0, height/2);
    }
    
    [UIView animateWithDuration:animationDuration animations:^(void) {
        [self setNeedsStatusBarAppearanceUpdate];
        CGFloat alpha = hidden ? 0 : 1;
        [self.navigationController.navigationBar setAlpha:alpha];
        _toolbar.frame = frame;
        if (hidden) _toolbar.frame = CGRectOffset(_toolbar.frame, 0, height/2);
        _toolbar.alpha = alpha;
        self.collectionView.backgroundColor = hidden ? [UIColor blackColor] : [UIColor whiteColor];
    } completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return YES;
    }
    
    return _statusBarShouldBeHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)areControlsHidden {
    return (_toolbar.alpha == 0);
}

- (void)hideControls {
    [self setControlsHidden:YES animated:YES];
}

- (void)toggleControls {
    [self setControlsHidden:![self areControlsHidden] animated:YES];
}

@end
