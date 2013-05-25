//
//  HTImageEntity.h
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/25.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTImageEntity : NSObject
@property NSString *thumbnailURL;
@property NSString *largeURL;
@property NSString *title;
@property BOOL selected;

- (id) initWithImageInfo:(NSDictionary *)imageInfo;
@end
