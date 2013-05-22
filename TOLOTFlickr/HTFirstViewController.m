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

static NSInteger PER_PAGE = 10;

@interface UIImage (URL)
@property (nonatomic) NSString *url;
@end

@implementation UIImage (URL)
-(NSString *)url {
    return objc_getAssociatedObject(self, @selector(setUrl:));
}

-(void)setUrl:(NSString*)val {
    objc_setAssociatedObject(self, _cmd, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end


@interface HTFirstViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property HTFlickrAPIRequester *flickrAPIRequester;
@property (strong, nonatomic) IBOutlet UITableView *imagesTableView;
@property NSMutableArray *images;
@property NSMutableArray *selectedImages;
@property BOOL hasMoreImages;
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
    
    [_imagesTableView registerNib:[UINib nibWithNibName:@"HTLoadMoreImageCell" bundle:nil] forCellReuseIdentifier:@"LoadMoreImageCell"];
    [_imagesTableView registerNib:[UINib nibWithNibName:@"HTImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    
    _images = [NSMutableArray array];
    _selectedImages = [NSMutableArray array];
    
    _hasMoreImages = YES;
    _imagesTableView.delegate = self;
    _imagesTableView.dataSource = self;
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
//        _images = [[NSArray alloc] initWithArray:response[@"photos"][@"photo"]];
        [_imagesTableView reloadData];
    }];
}

#pragma mark delegates

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _hasMoreImages ? _images.count + 1 : _images.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"0/62枚を選択済み";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _images.count) {
        return 50;
    }
    return 125;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell;
    
//    if (cell == nil) {
//        NSLog(@"hogehoge");
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
//    }
    
    if (_hasMoreImages && indexPath.row >= _images.count) {
        HTLoadMoreImageCell *cell = (HTLoadMoreImageCell*)[tableView dequeueReusableCellWithIdentifier:@"LoadMoreImageCell"];
        tableViewCell = cell;
    } else {
        HTImageCell *cell = (HTImageCell *)[tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
        NSDictionary *imageInfo = _images[indexPath.row];
        [cell setData:imageInfo];
        tableViewCell = cell;
    }
    return tableViewCell;
}

#pragma mark delegate methods

-(void) handleTap:(UITapGestureRecognizer *)sender {
    if ([sender.view isMemberOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)sender.view;
        NSLog(@"%@", imageView.image.url);
        //TODO show details
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_s.jpg" options:0 error:nil];
        NSString *url = [regex stringByReplacingMatchesInString:imageView.image.url options:0 range:NSMakeRange(0, imageView.image.url.length) withTemplate:@"_b.jpg"];
        HTImageDetailViewController *viewController = [[HTImageDetailViewController alloc] initWithURL:url];
        [self presentViewController:viewController animated:YES completion:nil];
    } else if ([sender.view isMemberOfClass:[UITableViewCell class]]) {
        NSLog(@"cell");
        UITableViewCell *cell = (UITableViewCell *)sender.view;
        cell.backgroundColor = [UIColor grayColor];
    }
}

@end