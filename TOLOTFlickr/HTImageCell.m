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
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) NSDictionary *imageInfo;
@end

@implementation HTImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setData:(NSDictionary *)imageInfo {
    _imageInfo = imageInfo;
    NSString *urlString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_s.jpg", imageInfo[@"farm"], imageInfo[@"server"], imageInfo[@"id"], imageInfo[@"secret"]];
    [_photoView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"loading.gif"]];
    _photoView.userInteractionEnabled = YES;

//    [cell.imageView.image setUrl:urlString];
//     cell.textLabel.text = imageInfo[@"title"];
//     cell.selectionStyle = UITableViewCellSelectionStyleNone;  
     UITapGestureRecognizer *thumbnailTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
     thumbnailTapRecognizer.delegate = self;
     [_photoView addGestureRecognizer:thumbnailTapRecognizer];
//     
//     UITapGestureRecognizer *cellTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//     cellTapRecognizer.delegate = self;
//     [cell addGestureRecognizer:cellTapRecognizer];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark delegate methods

-(void) handleTap:(UITapGestureRecognizer *)sender {
    if ([sender.view isMemberOfClass:[UIImageView class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didThumbnailTapped" object:self userInfo:_imageInfo];
    }
}


@end
