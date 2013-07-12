//
//  HTConfirmViewController.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/07/12.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTConfirmViewController.h"
#import "HTImageEntity.h"
#import "HTConfirmViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HTConfirmViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *imagesTableView;
@property (strong, nonatomic) NSMutableArray *images;
@end

@implementation HTConfirmViewController

- (id) initWithImages:(NSMutableArray *)images {
    self = [super init];
    if (self) {
        _images = images;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _imagesTableView.delegate = self;
    _imagesTableView.dataSource = self;
    self.navigationItem.title = @"確認";
    [_imagesTableView registerNib:[UINib nibWithNibName:@"HTConfirmViewCell" bundle:nil] forCellReuseIdentifier:@"ConfirmCell"];
}

- (void) backToMainView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark degelgate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 50;
    }
    return 44;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return _images.count;
    }
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (indexPath.section == 0) {
        cell = (HTConfirmViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ConfirmCell"];
        //cell.textLabel.text = @"hoge";
        //UIButton *reverseButton = [[UIButton alloc] init];
        //reverseButton.titleLabel.text = @"順序を反転";
    } else {
        HTImageEntity *imageEntity = (HTImageEntity *)_images[indexPath.row];
        cell.textLabel.text = imageEntity.title;
        [cell.imageView setImageWithURL:[NSURL URLWithString:imageEntity.thumbnailURL]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
