//
//  HTFlickrAPIRequester.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/16.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTFlickrAPIRequester.h"
#import "ObjectiveFlickr.h"
#import "APIKey.h"

static NSString *storedAuthTokenKeyName = @"FlickrOAuthToken";
static NSString *storedAuthTokenSecretKeyName = @"FlickrOAuthTokenSecret";
static NSString *callbackURLBaseString = @"tolotflickr://auth";

static NSString *fetchRequestTokenStep = @"fetchRequestTokenStep";
static NSString *getAccessTokenStep = @"getAccessTokenStep";

static HTFlickrAPIRequester *instance;

@interface HTFlickrAPIRequester() <OFFlickrAPIRequestDelegate>

@property OFFlickrAPIRequest *flickrAPIRequest;
@property OFFlickrAPIContext *flickrContext;
@end

@implementation HTFlickrAPIRequester
+ (HTFlickrAPIRequester *)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HTFlickrAPIRequester alloc] init];
    });
    return instance;
}

- (id) init {
    self = [super init];
    if (self != nil) {
        _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_API_KEY
                                                       sharedSecret:OBJECTIVE_FLICKR_API_SHARED_SECRET];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *authToken = [userDefaults objectForKey:storedAuthTokenKeyName];
        NSString *authTokenSecret = [userDefaults objectForKey:storedAuthTokenSecretKeyName];
        
        if (([authToken length] > 0) && ([authTokenSecret length] > 0)) {
            _flickrContext.OAuthToken = authToken;
            _flickrContext.OAuthTokenSecret = authTokenSecret;
        }
        _flickrAPIRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
        _flickrAPIRequest.delegate = self;
    }
    
    return self;
}

- (void) authorize {
    _flickrAPIRequest.requestTimeoutInterval = 60.0;
    _flickrAPIRequest.sessionInfo = fetchRequestTokenStep;
    [_flickrAPIRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:callbackURLBaseString]];
}

- (void) fetchAccessToken:url complete:(callback)callback {
    NSString *token = nil;
    NSString *verifier = nil;
    BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:callbackURLBaseString], &token, &verifier);

    if (!result) {
        NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
    }
    
    _flickrAPIRequest.sessionInfo = getAccessTokenStep;
    [_flickrAPIRequest fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];
}

- (void) fetchImages {
    //_flickrAPIRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
    //_flickrAPIRequest.delegate = self;
    //NSLog(@"%@", _flickrContext.OAuthToken);
    //[_flickrAPIRequest callAPIMethodWithGET:@"flickr.test.login" arguments:nil];
    [_flickrAPIRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:@{@"user_id": @"me"}];
    NSLog(@"called");
}

#pragma mark OFFlickrAPIRequest delegate methods
- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID {
    //callback();
    //test
    _flickrContext.OAuthToken = inAccessToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    [self fetchImages];
}

- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
    NSLog(@"%@", inResponseDictionary);
}

- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
	NSLog([inError description]);
}

- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret {
    _flickrContext.OAuthToken = inRequestToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    NSURL *authURL = [_flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}

@end
