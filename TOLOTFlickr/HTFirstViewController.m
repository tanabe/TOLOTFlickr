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
#import <SDWebImage/UIImageView+WebCache.h>

@interface HTFirstViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property HTFlickrAPIRequester *flickrAPIRequester;
@property (strong, nonatomic) IBOutlet UITableView *imagesTableView;
@property NSArray *images;
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
    _imagesTableView.delegate = self;
    _imagesTableView.dataSource = self;
    _flickrAPIRequester = [HTFlickrAPIRequester getInstance];
    
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
    [_flickrAPIRequester fetchImages:^(NSDictionary *response) {
        _images = [[NSArray alloc] initWithArray:response[@"photos"][@"photo"]];
        [_imagesTableView reloadData];
    }];
}

#pragma mark delegates

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_images count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"hoge";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *imageInfo = _images[indexPath.row];
    NSString *urlString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_s.jpg", imageInfo[@"farm"], imageInfo[@"server"], imageInfo[@"id"], imageInfo[@"secret"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"loading.gif"]];
    cell.imageView.userInteractionEnabled = YES;
    cell.textLabel.text = imageInfo[@"title"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapThumbnail:)];
    tapGestureRecognizer.delegate = self;
    [cell.imageView addGestureRecognizer:tapGestureRecognizer];
    return cell;
}

#pragma mark delegate methods

-(void) didTapThumbnail:(UITapGestureRecognizer *)sender {
    NSLog(@"%@", sender);
    HTImageDetailViewController *viewController = [[HTImageDetailViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
