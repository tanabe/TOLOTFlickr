//
//  HTConfigViewController.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/14.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTConfigViewController.h"
#import "HTFlickrAPIRequester.h"


@interface HTConfigViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *configTableView;

@property HTFlickrAPIRequester *flickrAPIRequester;
@end

@implementation HTConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"設定";
        self.tabBarItem.image = [UIImage imageNamed:@"gear"];
    }
    return self;
}
							
- (void)viewDidLoad {
    [super viewDidLoad];
    _configTableView.delegate = self;
    _configTableView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark IBAction

- (IBAction)didTapLogoutButton:(id)sender {
    _flickrAPIRequester = [HTFlickrAPIRequester getInstance];
    [_flickrAPIRequester logout];
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Flickr 連携を解除する";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        _flickrAPIRequester = [HTFlickrAPIRequester getInstance];
        [_flickrAPIRequester logout];
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
        
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"" message:@"Flickr 連携を解除しました"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];

    }
}
@end
