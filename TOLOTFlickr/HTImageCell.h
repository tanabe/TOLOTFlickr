//
//  HTImageCell.h
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/23.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridViewCell.h"
#import "HTImageEntity.h"

@interface HTImageCell : UIView
- (void) setData:(HTImageEntity *)imageEntity;
@end
