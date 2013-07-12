//
//  HTConfirmViewController.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/07/12.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTConfirmViewController.h"

@interface HTConfirmViewController ()

@end

@implementation HTConfirmViewController

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

@end
