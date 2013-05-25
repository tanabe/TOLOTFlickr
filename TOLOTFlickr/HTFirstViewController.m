//
//  HTFirstViewController.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/14.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTFirstViewController.h"
#import "HTFlickrAPIRequester.h"
#import "HTImageDetailViewController.h"
#import "HTLoadMoreImageCell.h"
#import "HTImageCell.h"
#import "HTImageEntity.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <objc/runtime.h>
#import "AQGridViewController.h"
#import "SVProgressHUD.h"

static NSInteger PER_PAGE = 100;
static NSInteger CELL_WIDTH = 75;
static NSInteger CELL_HEIGHT = 80;

@interface UIImage (URL)
@property (nonatomic) NSString *url;
@end

@interface HTFirstViewController () <AQGridViewDataSource, AQGridViewDelegate>
@property HTFlickrAPIRequester *flickrAPIRequester;

@property NSMutableArray *images;
@property NSMutableArray *selectedImages;
@property BOOL hasMoreImages;
@property (strong, nonatomic) IBOutlet AQGridView *gridView;
@property (strong, nonatomic) IBOutlet HTImageCell *gridViewCellContent;

@end

@implementation HTFirstViewController
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad {
    [super viewDidLoad];

    _images = [NSMutableArray array];
    _selectedImages = [NSMutableArray array];
    
    _hasMoreImages = YES;
  
    _flickrAPIRequester = [HTFlickrAPIRequester getInstance];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"didThumbnailTapped"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSString *url = note.userInfo[@"largeURL"];
                                                      HTImageDetailViewController *viewController = [[HTImageDetailViewController alloc] initWithURL:url];
                                                      [self presentViewController:viewController animated:YES completion:nil];
                                        }];
    _gridView.delegate = self;
    _gridView.dataSource = self;
    [_gridView reloadData];
    
    if (_flickrAPIRequester.hasAuthorized) {
        [self showImages];
    } else {
        [_flickrAPIRequester authorize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) showImages {
    [SVProgressHUD showWithStatus:@"読込中"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_flickrAPIRequester fetchImages:PER_PAGE withPage:0 complete:^(NSDictionary *response) {
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    [_gridView reloadData];
}

#pragma mark delegates

- (NSUInteger) numberOfItemsInGridView:(AQGridView *)gridView {
    return _images.count;
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
	static NSString *CellIdentifier = @"ReusableGridViewCell";
	AQGridViewCell *cell = (AQGridViewCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
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

@end