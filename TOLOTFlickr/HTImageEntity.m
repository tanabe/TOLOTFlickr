//
//  HTImageEntity.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/25.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTImageEntity.h"

@implementation HTImageEntity

- (id) initWithImageInfo:(NSDictionary *)imageInfo {
    self = [super init];
    if (self != nil ) {
        NSString *farmId = imageInfo[@"farm"];
        NSString *imageId = imageInfo[@"id"];
        NSString *serverId = imageInfo[@"server"];
        NSString *secret = imageInfo[@"secret"];
        
        //properties
        _title = imageInfo[@"title"];
        _largeURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_b.jpg", farmId, serverId, imageId, secret];
        _thumbnailURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_s.jpg", farmId, serverId, imageId, secret];
        _selected = NO;
    }
    return self;
}
@end
