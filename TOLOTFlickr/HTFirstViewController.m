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
#import <SDWebImage/UIImageView+WebCache.h>
#import <objc/runtime.h>
#import "AQGridViewController.h"

static NSInteger PER_PAGE = 100;

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
                                                      NSLog(@"%@", note.userInfo);
                                                      NSDictionary *imageInfo = note.userInfo;
                                                      NSString *url = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_b.jpg", imageInfo[@"farm"], imageInfo[@"server"], imageInfo[@"id"], imageInfo[@"secret"]];
                                                      
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
    [_flickrAPIRequester fetchImages:PER_PAGE withPage:0 complete:^(NSDictionary *response) {
        [_images addObjectsFromArray:response[@"photos"][@"photo"]];
        [_gridView reloadData];
    }];
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
    return CGSizeMake(75, 80);
}

@end