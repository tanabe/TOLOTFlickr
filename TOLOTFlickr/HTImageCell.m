//
//  HTImageCell.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/23.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTImageCell.h"
#import "HTImageEntity.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HTImageCell() <UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) HTImageEntity *imageEntity;
@property (strong, nonatomic) UIImageView *checkMarkImageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property BOOL initialized;
@end

@implementation HTImageCell

//BUG too many called
- (void) setData:(HTImageEntity *)imageEntity {
    _imageEntity = imageEntity;
    
    if (_initialized) {
        [_activityIndicatorView startAnimating];
        _activityIndicatorView.hidden = NO;
    } else {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [_activityIndicatorView startAnimating];
        [_activityIndicatorView setCenter:self.center];
        [self addSubview:_activityIndicatorView];
        _checkMarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        _checkMarkImageView.contentMode = UIViewContentModeBottomRight;
        _checkMarkImageView.image = [UIImage imageNamed:@"check"];
        
        [self initGestureRecognizer];
        [self initObserver];
        
        _initialized = YES;
    }

    NSString *urlString = imageEntity.thumbnailURL;
    __weak HTImageCell *that = self;
    [_imageView setImageWithURL:[NSURL URLWithString:urlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [that.activityIndicatorView stopAnimating];
        that.activityIndicatorView.hidden = YES;
    }];
    
    [self updateCheckMark];
}

- (void) initGestureRecognizer {
    _imageView.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongTap:)];
    longPressGestureRecognizer.delegate = self;
    [_imageView addGestureRecognizer:longPressGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGestureRecognizer.delegate = self;
    [_imageView addGestureRecognizer:tapGestureRecognizer];
}

- (void) initObserver {
    [_imageEntity addObserver:self
               forKeyPath:@"selected"
                  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                  context:nil];
}

- (void) updateCheckMark {
    if (_imageEntity.selected) {
        [self addSubview:_checkMarkImageView];
    } else {
        [_checkMarkImageView removeFromSuperview];
    }
}

#pragma mark delegate methods

-(void) didLongTap:(UILongPressGestureRecognizer *)sender {
    if ([sender.view isMemberOfClass:[UIImageView class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didThumbnailLongTapped" object:self userInfo:@{@"largeURL": _imageEntity.largeURL, @"title": _imageEntity.title}];
    }
}

- (void) didTap:(UITapGestureRecognizer *)sender {
    _imageEntity.selected = _imageEntity.selected == YES ? NO : YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    [self updateCheckMark];
}

@end