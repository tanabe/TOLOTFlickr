//
//  HTImageDetailViewController.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/18.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTImageDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NIPhotoScrollView.h"

@interface HTImageDetailViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *imageViewContainer;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NIPhotoScrollView *photoScrollView;
@property NSString *url;
@property NSString *imageTitle;
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

- (id) initWithImageInfo:(NSDictionary *)imageInfo {
    if((self = [super init]) != nil) {
        _url = imageInfo[@"largeURL"];
        _imageTitle = imageInfo[@"title"];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.hidden = NO;
    _activityIndicator.center = self.view.center;
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    __weak HTImageDetailViewController *that = self;
    
    CGRect bounds = _imageViewContainer.bounds;
    NIPhotoScrollView *photoScrollView = [[NIPhotoScrollView alloc] initWithFrame:bounds];
    _photoScrollView = photoScrollView;
    _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    //_photoScrollView.photoDimensions = CGSizeMake(800, 600);
    [_imageViewContainer addSubview:_photoScrollView];
    

    //_imageView.contentMode = UIViewContentModeCenter;
    
    [_imageView setImageWithURL:[NSURL URLWithString:_url]
               placeholderImage:[UIImage imageNamed:nil]
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
         [that.photoScrollView setImage:that.imageView.image photoSize:NIPhotoScrollViewPhotoSizeOriginal];
         //that.imageView.contentMode = UIViewContentModeScaleAspectFit;
         that.activityIndicator.hidden = YES;
         [that.activityIndicator removeFromSuperview];
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
     }];
    
    _navigationBar.title = _imageTitle;
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
