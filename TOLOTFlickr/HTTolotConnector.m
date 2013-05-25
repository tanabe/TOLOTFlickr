//
//  HTTolotConnector.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/26.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTTolotConnector.h"

@implementation HTTolotConnector

static NSString *developerInfo = @"<?xml version='1.0' encoding='UTF-8'?>"
"<info>"
"<version>1.0</version>"
"<devCode>000011</devCode>"
"<devName>Hideaki Tanabe</devName>"
"<appCode>000000</appCode>"
"<appName>フリトロ</appName>"
"</info>";

+ (void) openTolotApplication {
    NSString* url = @"tolot://jp.atom.tolot";
    NSURL* appUrl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:appUrl]) {
        [[UIApplication sharedApplication] openURL:appUrl];
    } else {
        url = @"http://plus.tolot.com/install/ios/";
        appUrl = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL:appUrl];
    }
}

+ (void) createPasteboard {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                         developerInfo, @"info",
                         //book, @"book",
                         //pageDic, @"xhtml",
                         //content, @"content",
                         @"true", @"debugMode",
                         nil];
    
    UIPasteboard* pasteboard = [UIPasteboard pasteboardWithName:@"TolotCustomPaseteBoard" create:YES];
    pasteboard.persistent = YES;
    NSData *pasteData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [pasteboard setData:pasteData forPasteboardType:@"TolotPlusData"];
}

@end
