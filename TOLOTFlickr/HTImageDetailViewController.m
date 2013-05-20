//
//  HTImageDetailViewController.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/18.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTImageDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HTImageDetailViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property NSString *url;
@end

@implementation HTImageDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithURL:(NSString *)url {
    if((self = [super init]) != nil) {
        _url = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_imageView setImageWithURL:[NSURL URLWithString:_url] placeholderImage:[UIImage imageNamed:@"loading.gif"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didTapCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion: nil];
}

@end
