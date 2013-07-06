//
//  HTSecondViewController.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/14.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTSecondViewController.h"
#import "HTFlickrAPIRequester.h"

@interface HTSecondViewController ()

@property HTFlickrAPIRequester *flickrAPIRequester;
@end

@implementation HTSecondViewController

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark IBAction

- (IBAction)didTapLogoutButton:(id)sender {
    _flickrAPIRequester = [HTFlickrAPIRequester getInstance];
    [_flickrAPIRequester logout];
}
@end
