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
static NSString *fetchImagesStep = @"fetchImagesStep";


static fetchAccessTokenCallback kFetchAccessTokenCallback;
static fetchImagesCallback kFetchImagesCallback;

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

- (void) logout {
    _flickrContext.OAuthToken = nil;
    _flickrContext.OAuthTokenSecret = nil;
    [self removeStoredKeys];
}

- (BOOL) hasAuthorized {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [userDefaults objectForKey:storedAuthTokenKeyName];
    NSString *authTokenSecret = [userDefaults objectForKey:storedAuthTokenSecretKeyName];
    if (([authToken length] > 0) && ([authTokenSecret length] > 0)) {
        return YES;
    }
    return NO;
}

- (void) fetchAccessToken:url complete:(fetchAccessTokenCallback)callback {
    kFetchAccessTokenCallback = callback;
    NSString *token = nil;
    NSString *verifier = nil;
    BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:callbackURLBaseString], &token, &verifier);

    if (!result) {
        NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
    }
    
    _flickrAPIRequest.sessionInfo = getAccessTokenStep;
    [_flickrAPIRequest fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];
}

- (void) fetchImages:(NSInteger)perPage withPage:(NSInteger)page complete:(fetchImagesCallback)callback {
    kFetchImagesCallback = callback;
    _flickrAPIRequest.sessionInfo = fetchImagesStep;
    [_flickrAPIRequest callAPIMethodWithGET:@"flickr.photos.search"
                                  arguments:@{@"user_id": @"me", @"media": @"photos", @"per_page": [NSString stringWithFormat:@"%ld", (long)perPage], @"page": [NSString stringWithFormat:@"%ld", (long)page]}];
}


#pragma mark OFFlickrAPIRequest delegate methods

- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID {
    [self setAndStoreFlickrAuthToken:inAccessToken secret:inSecret];
    _flickrContext.OAuthToken = inAccessToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    kFetchAccessTokenCallback();
}

- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
    if (_flickrAPIRequest.sessionInfo == fetchImagesStep) {
        kFetchImagesCallback(inResponseDictionary);
    }
}

- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
	//NSLog([inError description]);
}

- (void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret {
    _flickrContext.OAuthToken = inRequestToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    NSURL *authURL = [_flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}

- (void) removeStoredKeys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:storedAuthTokenKeyName];
    [userDefaults removeObjectForKey:storedAuthTokenSecretKeyName];
    [userDefaults synchronize];
}

- (void) setAndStoreFlickrAuthToken:(NSString *)inAuthToken secret:(NSString *)inSecret {
	if (![inAuthToken length] || ![inSecret length]) {
		[self logout];
	} else {
        NSLog(@"store");
		_flickrContext.OAuthToken = inAuthToken;
        _flickrContext.OAuthTokenSecret = inSecret;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:inAuthToken forKey:storedAuthTokenKeyName];
		[userDefaults setObject:inSecret forKey:storedAuthTokenSecretKeyName];
        [userDefaults synchronize];
	}
}

@end
