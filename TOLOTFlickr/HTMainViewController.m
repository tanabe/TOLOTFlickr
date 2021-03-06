//
//  HTMainViewController.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/14.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTMainViewController.h"
#import "HTFlickrAPIRequester.h"
#import "HTImageDetailViewController.h"
#import "HTLoadMoreImageCell.h"
#import "HTImageCell.h"
#import "HTLoadMoreImageCell.h"
#import "HTImageEntity.h"

#import "HTConfirmViewController.h"

//#import <SDWebImage/UIImageView+WebCache.h>
#import <objc/runtime.h>
#import "AQGridViewController.h"
#import "SVProgressHUD.h"
#import <BlocksKit/BlocksKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

static NSInteger PER_PAGE    = 100;
static NSInteger CELL_WIDTH  = 75;
static NSInteger CELL_HEIGHT = 80;
static NSInteger LOAD_BUTTON_HEIGHT = 40;
static NSInteger MAX_IMAGES = 62;

static NSString *TITLE_FORMAT = @"%d/62枚選択";

@interface UIImage (URL)
@property (nonatomic) NSString *url;
@end

@interface HTMainViewController () <AQGridViewDataSource, AQGridViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property HTFlickrAPIRequester *flickrAPIRequester;

@property NSMutableArray *images;
@property NSMutableArray *selectedImages;
@property BOOL hasMoreImages;

@property NSInteger pages;
@property NSInteger currentPage;
@property (strong, nonatomic) IBOutlet UIView *loginView;

@property (strong, nonatomic) UIButton *loadMoreImagesButton;
@property (strong, nonatomic) IBOutlet AQGridView *gridView;
@property (strong, nonatomic) IBOutlet HTImageCell *gridViewCellContent;
@property (strong, nonatomic) IBOutlet HTLoadMoreImageCell *loadMoreImageCellContent;
@property (strong, nonatomic) IBOutlet UIButton *flickrLoginButton;
@property (strong, nonatomic) UIBarButtonItem *confirmButton;
@property (strong, nonatomic) UIBarButtonItem *uploadButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;


@end

@implementation HTMainViewController
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"写真を選ぶ";
        self.tabBarItem.image = [UIImage imageNamed:@"photos"];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![_flickrAPIRequester hasAuthorized]) {
        [self reset];
        _loginView.hidden = NO;
        _uploadButton.enabled = NO;
    }
    [self updateTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trackedViewName = @"MainView";
    
    _flickrAPIRequester = [HTFlickrAPIRequester getInstance];
    
    [self reset];
    [self updateTitle];
    [self initializeNotificationCenter];
    
    [self createConfirmButton];
    [self createUploadButton];
    
    if ([_flickrAPIRequester hasAuthorized]) {
        _loginView.hidden = YES;
        [self showImages];
    } else {
        _uploadButton.enabled = NO;
        _loginView.hidden = NO;
    }
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
}

- (void) createConfirmButton {
    _confirmButton = [[UIBarButtonItem alloc] initWithTitle:@"確認画面へ進む" style:UIBarButtonItemStylePlain target:self action:@selector(showConfirm)];
    self.navigationItem.rightBarButtonItem = _confirmButton;
    _confirmButton.enabled = NO;
}

- (void) createUploadButton {
    _uploadButton = [[UIBarButtonItem alloc] initWithTitle:@"アップロード" style:UIBarButtonItemStylePlain target:self action:@selector(preparePhoto)];
    self.navigationItem.leftBarButtonItem = _uploadButton;
    _uploadButton.enabled = YES;
}

- (void) reset {
    _confirmButton.enabled = NO;
    _currentPage = 1;
    _images = [NSMutableArray array];
    _selectedImages = [NSMutableArray array];
    _hasMoreImages = YES;
    _gridView.delegate = self;
    _gridView.dataSource = self;
    [_gridView reloadData];
}

- (void) initializeNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"didThumbnailLongTapped"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      HTImageDetailViewController *viewController = [[HTImageDetailViewController alloc] initWithImageInfo:note.userInfo];
                                                      [self presentViewController:viewController animated:YES completion:nil];
                                                  }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) updateTitle {
    self.navigationItem.title = [NSString stringWithFormat:TITLE_FORMAT, _selectedImages.count];
}

- (void) updateConfirmButton {
    if (_selectedImages.count > 0 && _selectedImages.count <= MAX_IMAGES) {
        _confirmButton.enabled = YES;
    } else {
        _confirmButton.enabled = NO;
    }
}

- (void) showHint:(NSString *)type {
    NSDictionary *hints = @{
                            @"longTap": @"サムネイル画像を長押しすると拡大表示できます",
                            @"upload": @"端末の写真を Flickr にアップロードできます。\n※公開情報は非公開設定となります。"
                            };
    
    NSString *key = [NSString stringWithFormat:@"didShowHint_%@", type];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL didShowHint = [userDefaults boolForKey:key];
    if (!didShowHint) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"ヒント" message:hints[type]
                                  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [userDefaults setBool:YES forKey:key];
        [userDefaults synchronize];
    }
}

- (void) showImages {
    _uploadButton.enabled = YES;
    _loginView.hidden = YES;
    [SVProgressHUD showWithStatus:@"読込中"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_flickrAPIRequester fetchImages:PER_PAGE withPage:_currentPage complete:^(NSDictionary *response) {
        _pages = [response[@"photos"][@"pages"] intValue];
        //NSLog(@"%d", _pages);
        //NSLog(@"%@", response);
        NSArray *photos = response[@"photos"][@"photo"];

        for (NSInteger i = 0; i < photos.count; i++) {
            NSDictionary *imageInfo = photos[i];
            HTImageEntity *imageEntity = [[HTImageEntity alloc] initWithImageInfo:imageInfo];
            
            [imageEntity addObserver:self
                           forKeyPath:@"selected"
                              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                              context:nil];
            
            [_images addObject:imageEntity];
        }

        [_gridView reloadData];
        [SVProgressHUD dismiss];
        [self showHint:@"longTap"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if (_currentPage < _pages) {
            [self showLoadMoreImagesButton];
            [self adjustGridViewHeight];
        } else {
            [_loadMoreImagesButton removeFromSuperview];
        }
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    //TODO fixme heavy loop
    _selectedImages = [[NSMutableArray alloc] init];
    for (HTImageEntity *imageEntity in _images) {
        if (imageEntity.selected) {
            [_selectedImages addObject:imageEntity];
        }
    }
    
    CGPoint lastOffset = _gridView.contentOffset;
    [_gridView reloadData];
    [self adjustGridViewHeight];
    _gridView.contentOffset = lastOffset;
    
    [self updateTitle];
    [self updateConfirmButton];
}

- (void) showLoadMoreImagesButton {
    NSInteger gridViewContentHeight = _images.count / 4 * CELL_HEIGHT;
    
    [_loadMoreImagesButton removeFromSuperview];
    _loadMoreImagesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loadMoreImagesButton.frame = CGRectMake(0, gridViewContentHeight, self.view.frame.size.width, LOAD_BUTTON_HEIGHT);
    [_loadMoreImagesButton setTitle:@"さらに100枚読み込む" forState:UIControlStateNormal];
    [_gridView addSubview:_loadMoreImagesButton];
    [_loadMoreImagesButton addTarget:self action:@selector(didTapLoadMoreImagesButton:) forControlEvents:UIControlEventTouchUpInside ];
    _loadMoreImagesButton.enabled = YES;
}

- (void)adjustGridViewHeight {
    NSInteger gridViewContentHeight = _images.count / 4 * CELL_HEIGHT;
    _gridView.contentSize = CGSizeMake(self.view.frame.size.width, gridViewContentHeight + LOAD_BUTTON_HEIGHT);
}

#pragma mark delegates

- (void)didTapLoadMoreImagesButton:(id)sender {
    _currentPage++;
    [self showImages];
    _loadMoreImagesButton.enabled = NO;
}

- (NSUInteger) numberOfItemsInGridView:(AQGridView *)gridView {
    return _images.count;
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
	static NSString *CellIdentifier = @"ReusableGridViewCell";
    AQGridViewCell *cell;
    cell = (AQGridViewCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"HTImageCell" owner:self options:nil];
        cell = [[AQGridViewCell alloc] initWithFrame:_gridViewCellContent.frame
                                     reuseIdentifier:CellIdentifier];
        [cell.contentView addSubview:_gridViewCellContent];
        cell.selectionStyle = AQGridViewCellSelectionStyleNone;
    }

    HTImageCell *content = (HTImageCell *)[cell.contentView viewWithTag:1];
    [content setData:_images[index]];
	return cell;
}

- (CGSize) portraitGridCellSizeForGridView:(AQGridView *)gridView {
    return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
}

- (void) clearSelection {
    _selectedImages = [[NSMutableArray alloc] init];
    for (HTImageEntity *imageEntity in _images) {
        imageEntity.selected = NO;
    }
    
    CGPoint lastOffset = _gridView.contentOffset;
    [_gridView reloadData];
    [self adjustGridViewHeight];
    _gridView.contentOffset = lastOffset;
    
    [self updateTitle];
    [self updateConfirmButton];
}

- (void) showConfirm {
    HTConfirmViewController *confirmViewController = [[HTConfirmViewController alloc] initWithImages:_selectedImages];
    [self.navigationController pushViewController:confirmViewController animated:YES];
}

- (void) preparePhoto {
    [self showHint:@"upload"];
    if (_selectedImages.count > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"選択が解除されますがよろしいですか？"];
        [alertView addButtonWithTitle:@"OK" handler:^{
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        }];
        
        [alertView addButtonWithTitle:@"キャンセル" handler:^{
        }];
        
        [alertView show];
    } else {
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }

}

- (void) startUploadPhoto:(NSObject *)args {
    [SVProgressHUD showWithStatus:@"送信中"];
    NSDictionary *params = (NSDictionary *)args;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_flickrAPIRequester uploadImage:params[@"image"] withName:params[@"name"] complete:^{
        [SVProgressHUD dismiss];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self reset];
        [self updateTitle];
        [self showImages];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        NSLog(@"[imageRep filename] : %@", [imageRep filename]);
        [self dismissViewControllerAnimated:YES completion:nil];
        UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self performSelector:@selector(startUploadPhoto:) withObject:@{@"image": selectedImage, @"name": [imageRep filename]} afterDelay:0.0];
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)didTapFlickrLoginButton:(id)sender {
    [_flickrAPIRequester authorize];
}

@end