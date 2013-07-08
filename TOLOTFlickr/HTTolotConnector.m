//
//  HTTolotConnector.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/26.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTTolotConnector.h"
#import "HTImageEntity.h"

@implementation HTTolotConnector

static NSString *developerInfo = @"<?xml version='1.0' encoding='UTF-8'?>"
"<info>"
"<version>1.0</version>"
"<devCode>c87913faa98c</devCode>"
"<devName>Hideaki Tanabe</devName>"
"<appCode>8d6d84f77769</appCode>"
"<appName>フリトロ</appName>"
"</info>";

static NSString *book = @"<?xml version='1.0' encoding='UTF-8'?>"
"<book>"
"<title></title>"
"<subTitle></subTitle>"
"<author></author>"
"<description></description>"
"<createDate></createDate>"
"<themeCode>1025</themeCode>"
"</book>";

static NSString *pageBodyFormat = @"<?xml version='1.0' encoding='utf-8' standalone='no'?>"
"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>"
"<html>"
"<head>"
"</head>"
"<body class='tolot' data-page-type='%@' data-item-lock='%@'>"
"<article class='tolot' data-tag-type='item' data-item-type='%@'><img src='%@' /></article>"
"</body>"
"</html>";

+ (void) openTolotApplication:(NSMutableArray *)images {
    [HTTolotConnector createPasteboard:images];
    
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

+ (NSMutableDictionary *) createPages:(NSMutableArray *)images {
    NSMutableDictionary *pages = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 0; i < images.count; i++) {
        NSInteger index = i;
        HTImageEntity *imageEntity = (HTImageEntity *)images[i];
        NSString *imageURL = @"http://upload.wikimedia.org/wikipedia/commons/c/c5/Siberian_Husky_pho_.jpg";
        //NSString *imageURL = imageEntity.largeURL;
        NSString *pageData = [NSString stringWithFormat:pageBodyFormat, @"page", @"false", @"image", imageURL];
        NSString *key = [NSString stringWithFormat:@"page%d", index];
        [pages setObject:pageData forKey:key];
    }
    return pages;
}

+ (NSString *) createContent {
    return @"<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>"
    "<package xmlns='http://www.idpf.org/2007/opf' prefix='cc: http://creativecommons.org/ns# rendition: http://www.idpf.org/vocab/rendition/#' unique-identifier='BookId' version='2.0'>"
    "<spine toc='ncx'>"
    "<itemref idref='page0'/>"
    "<itemref idref='page1'/>"
    "<itemref idref='page2'/>"
    "</spine>"
    "</package>";
}

+ (void) createPasteboard:(NSMutableArray *) images {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                         developerInfo, @"info",
                         book, @"book",
                         [HTTolotConnector createPages:images], @"xhtml",
                         [HTTolotConnector createContent], @"content",
                         @"true", @"debugMode",
                         nil];
    
    UIPasteboard* pasteboard = [UIPasteboard pasteboardWithName:@"TolotCustomPaseteBoard" create:YES];
    pasteboard.persistent = YES;
    NSData *pasteData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [pasteboard setData:pasteData forPasteboardType:@"TolotPlusData"];
}

@end
