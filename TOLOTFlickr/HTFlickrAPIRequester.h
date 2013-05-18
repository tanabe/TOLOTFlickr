//
//  HTFlickrAPIRequester.h
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/16.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveFlickr.h"

typedef void (^fetchAccessTokenCallback)();
typedef void (^fetchImagesCallback)(NSDictionary *response);

@interface HTFlickrAPIRequester : NSObject
@property (readonly) BOOL hasAuthorized;
+ (HTFlickrAPIRequester *) getInstance;
- (void) authorize;
- (void) fetchAccessToken:url complete:(fetchAccessTokenCallback)callback;
- (void) fetchImages:(fetchImagesCallback)callback;
@end
