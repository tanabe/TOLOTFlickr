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
#import "HTTolotConnector.h"
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
    
    self.trackedViewName = @"ConfirmView";
    
    _imagesTableView.delegate = self;
    _imagesTableView.dataSource = self;
    self.navigationItem.title = @"確認";
    [_imagesTableView registerNib:[UINib nibWithNibName:@"HTConfirmViewCell" bundle:nil] forCellReuseIdentifier:@"ConfirmCell"];
    
    UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithTitle:@"作成する" style:UIBarButtonItemStylePlain target:self action:@selector(openTolot)];
    confirmButton.tintColor = [UIColor blueColor];
    self.navigationItem.rightBarButtonItem = confirmButton;
}

- (void) openTolot {
    [HTTolotConnector openTolotApplication:_images];
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

- (void) reverse:(id)sender {
    NSArray *reversed = [[_images reverseObjectEnumerator] allObjects];
    for (NSInteger i = 0; i < _images.count; i++) {
        _images[i] = reversed[i];
    }
    [_imagesTableView reloadData];
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
        HTConfirmViewCell *cell = (HTConfirmViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ConfirmCell"];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.reverseButton addTarget:self
                               action:@selector(reverse:)
                     forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else {
        HTImageEntity *imageEntity = (HTImageEntity *)_images[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = imageEntity.title;
        [cell.imageView setImageWithURL:[NSURL URLWithString:imageEntity.thumbnailURL]];
    }
    
    return cell;
}

@end
