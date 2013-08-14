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
typedef void (^uploadImageCallback)();

@interface HTFlickrAPIRequester : NSObject
+ (HTFlickrAPIRequester *) getInstance;
- (void) authorize;
- (void) logout;
- (void) fetchAccessToken:url complete:(fetchAccessTokenCallback)callback;
- (void) fetchImages:(NSInteger)perPage withPage:(NSInteger)page complete:(fetchImagesCallback)callback;
- (void) uploadImage:(UIImage *)image withName:(NSString *)name complete:(uploadImageCallback)callback;
- (BOOL) hasAuthorized;
@end
