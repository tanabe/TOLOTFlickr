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
#import <objc/runtime.h>

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
@property NSArray *images;
@property NSMutableArray *selectedImages;
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
    _selectedImages = [[NSMutableArray alloc] init];
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
    return @"0/62枚を選択済み";
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
    [cell.imageView.image setUrl:urlString];
    cell.textLabel.text = imageInfo[@"title"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *thumbnailTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    thumbnailTapRecognizer.delegate = self;
    [cell.imageView addGestureRecognizer:thumbnailTapRecognizer];

    UITapGestureRecognizer *cellTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    cellTapRecognizer.delegate = self;
    [cell addGestureRecognizer:cellTapRecognizer];

    return cell;
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
