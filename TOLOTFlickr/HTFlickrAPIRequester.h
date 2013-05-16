//
//  HTFlickrAPIRequester.h
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/16.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveFlickr.h"

typedef void (^callback)();

@interface HTFlickrAPIRequester : NSObject
+ (HTFlickrAPIRequester *) getInstance;
- (void) authorize;
- (void) fetchAccessToken:url complete:(callback)callback;
- (void) fetchImages;
@end
