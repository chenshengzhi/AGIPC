//
//  AGIPCAlbumsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCAlbumsController.h"

#import "AGImagePickerController.h"
#import "AGIPCAssetsController.h"

@interface AGIPCAlbumsController () {
    NSMutableArray *_assetsGroups;
    BOOL _isLoadingAssetsGroups;
    __weak AGImagePickerController *_imagePickerController;
}

@end

@interface AGIPCAlbumsController ()

- (void)reloadData;

- (void)cancelAction:(id)sender;

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

@end

@implementation AGIPCAlbumsController

#pragma mark - Properties -

@synthesize imagePickerController = _imagePickerController;

- (NSMutableArray *)assetsGroups {
    if (_assetsGroups == nil)
    {
        _assetsGroups = [[NSMutableArray alloc] init];
    }
    
    return _assetsGroups;
}

#pragma mark - Object Lifecycle -

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.imagePickerController = imagePickerController;
        
        [self assetsGroups];
        
        [self registerForNotifications];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.f) {
            [self loadAssetsGroups];
        }

    }
    
    return self;
}

- (void)dealloc {
    [self unregisterFromNotifications];
}

#pragma mark - View lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"照片", nil);
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.f) {
        [self loadAssetsGroups];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)pushAssetsControllerWithName:(NSString *)name {
    if (0 == [name length]) {
        return;
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    @synchronized(self) {
        if (0 < self.assetsGroups.count) {
            ALAssetsGroup *targetAssetsGroup = nil;
            for (ALAssetsGroup *assetsGroup in self.assetsGroups) {
                NSString *pName = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
                if ([name isEqualToString:pName]) {
                    targetAssetsGroup = assetsGroup;
                    break;
                }
            }
            
            if (nil != targetAssetsGroup) {
                AGIPCAssetsController *controller = [[AGIPCAssetsController alloc] initWithImagePickerController:self.imagePickerController andAssetsGroup:targetAssetsGroup];
                [self.navigationController pushViewController:controller animated:NO];
            }
        } else {
            static int tryCount;
            if (tryCount < 3) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self pushAssetsControllerWithName:name];
                });
                ++tryCount;
            }
        }
    }
}

- (void)pushFirstAssetsController {
    @synchronized(self) {
        if (0 < self.assetsGroups.count) {
            NSString *pName = [[self.assetsGroups firstObject] valueForProperty:ALAssetsGroupPropertyName];
            [self pushAssetsControllerWithName:pName];
        } else {
            static int tryCount;
            if (tryCount < 3) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self pushFirstAssetsController];
                });
                ++tryCount;
            }
        }
    }
}

#pragma mark - UITableViewDataSource Methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    ALAssetsGroup *group = (self.assetsGroups)[indexPath.row];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSUInteger numberOfAssets = group.numberOfAssets;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [group valueForProperty:ALAssetsGroupPropertyName]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfAssets];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)self.assetsGroups[indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	AGIPCAssetsController *controller = [[AGIPCAssetsController alloc] initWithImagePickerController:self.imagePickerController andAssetsGroup:self.assetsGroups[indexPath.row]];
	[self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {	
	return 57;
}

#pragma mark - Private -

- (void)loadAssetsGroups {
    BOOL wasLoading = NO;
    @synchronized(self) {
        wasLoading = _isLoadingAssetsGroups;
        if (!_isLoadingAssetsGroups) {
            _isLoadingAssetsGroups = YES;
            [self.assetsGroups removeAllObjects];
        }
    }
    
    if (wasLoading) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        @autoreleasepool {
            
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
            {
                if (group == nil || group.numberOfAssets == 0)
                {
                    return;
                }
                
                @synchronized(self) {
                    int groupType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                    if (self.imagePickerController.shouldShowSavedPhotosOnTop && groupType == ALAssetsGroupSavedPhotos) {
                        if (![self.assetsGroups containsObject:group]) {
                            [self.assetsGroups insertObject:group atIndex:0];
                        }
                    } else {
                        NSUInteger index = 0;
                        for (ALAssetsGroup *g in [NSArray arrayWithArray:self.assetsGroups]) {
                            if (self.imagePickerController.shouldShowSavedPhotosOnTop && [[g valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                                index++;
                                continue;
                            }
                            if (groupType > [[g valueForProperty:ALAssetsGroupPropertyType] intValue]) {
                                if (![self.assetsGroups containsObject:group]) {
                                    [self.assetsGroups insertObject:group atIndex:index];
                                }
                                break;
                            }
                            index++;
                        }
                        if (![self.assetsGroups containsObject:group]) {
                            [self.assetsGroups addObject:group];
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(self) {
                        NSLog(@"Load assets group list finished. Items %@", self.assetsGroups);
                        [self reloadData];
                        _isLoadingAssetsGroups = NO;
                    }
                });
            };
            
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                @synchronized(self) {
                    NSLog(@"A problem occured. Error: %@", error.localizedDescription);
                    _isLoadingAssetsGroups = NO;
                    [self.imagePickerController didFail:error];
                }
            };
            
            [[AGImagePickerController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
        }
    });
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)cancelAction:(id)sender {
    [self.imagePickerController didCancelPickingAssets];
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
    [self loadAssetsGroups];
}

@end
