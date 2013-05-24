//
//  HTImageCell.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/23.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HTImageCell() <UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSDictionary *imageInfo;
@end

@implementation HTImageCell

- (void) setData:(NSDictionary *)imageInfo {
    _imageInfo = imageInfo;
    NSString *urlString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_s.jpg", imageInfo[@"farm"], imageInfo[@"server"], imageInfo[@"id"], imageInfo[@"secret"]];

    [_imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"loading.gif"]];
    _imageView.userInteractionEnabled = YES;
    
     UITapGestureRecognizer *thumbnailTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
     thumbnailTapRecognizer.delegate = self;
     [_imageView addGestureRecognizer:thumbnailTapRecognizer];
}

#pragma mark delegate methods

-(void) handleTap:(UITapGestureRecognizer *)sender {
    if ([sender.view isMemberOfClass:[UIImageView class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didThumbnailTapped" object:self userInfo:_imageInfo];
    }
}

@end
