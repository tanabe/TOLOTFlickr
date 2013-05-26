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
"<version>1.6.1</version>"
"<devCode>000011</devCode>"
"<devName>Hideaki Tanabe</devName>"
"<appCode>000000</appCode>"
"<appName>フリトロ</appName>"
"</info>";

static NSString *book = @"<?xml version='1.0' encoding='UTF-8'?>"
"<book>"
"<title>aaa</title>"
"<subTitle>bbb</subTitle>"
"<author>ccc</author>"
"<description>ddd</description>"
"<createDate>12345</createDate>"
"<themeCode></themeCode>"
"</book>";

static NSString *pageBodyFormat = @"<?xml version='1.0' encoding='utf-8' standalone='no'?>"
"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>"
"<html>"
"<head>"
"</head>"
"<body class='tolot' data-page-type='%@' data-item-lock='%@'>"
"<article class='tolot' data-tag-type='item' data-item-type='%@'>%@</article>"
"</body>"
"</html>";

+ (void) openTolotApplication:(NSMutableArray *)images {
    
    //[HTTolotConnector createPasteboard:images];
    
    
    //info(開発者情報)を含んだXML形式の文字列の作成します。タグ内の値は適切に変更して下さい
    NSString *info = @"<?xml version='1.0' encoding='UTF-8'?>"
    "<info>"
    "<version>1.0</version>"
    "<devCode>000011</devCode>"
    "<devName>トロット 太郎</devName>"
    "<appCode>000000</appCode>"
    "<appName>開発者のアプリ名</appName>"
    "</info>";
    
    //book(フォトブックの情報)を含んだXML形式の文字列を作成します。タグ内の値は適切に変更して下さい
    NSString *book = @"<?xml version='1.0' encoding='UTF-8'?>"
    "<book>"
    "<title>サンプルタイトル</title>"
    "<subTitle>サンプルサブタイトル</subTitle>"
    "<author>サンプル作成者</author>"
    "<description>サンプル説明</description>"
    "<createDate>yyyy/MM/dd HH:mm</createDate>"
    "<themeCode>1025</themeCode>"
    "</book>";
    
    //page(フォトブックのページ情報)を含んだXHTML形式の文字列を作成します。タグ内の値は加工して入れる形になります
    NSString *pageBody = @"<?xml version='1.0' encoding='utf-8' standalone='no'?>"
    "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>"
    
    "<html>"
    "<head>"
    "</head>"
    
    "<body class='tolot' data-page-type='%@' data-item-lock='%@'>"
    "<article class='tolot' data-tag-type='item' data-item-type='%@'>%@</article>"
    "</body>"
    "</html>";
    
    NSUInteger index;
    //生成された文字列を格納する辞書
    NSMutableDictionary *pageDic = [NSMutableDictionary dictionary];
    NSString *key = @"page%d";
    //ページの順番を格納するarray
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    
     //textの例
    NSArray *textArray = @[@"hoge", @"foo", @"bar"];
     for(index = 0;index < [textArray count];index++){
     //1:ページタイプ,2:見開きかどうか,3:pageが表示すべきタイプ,4:文字データ
     //NSString *pageData = [NSString stringWithFormat:pageBody,@"page",@"false",@"text",@"TOLOTアプリに送る文章"];
     //意図的に空白ページにしたい場合は下記の様にします。空白の場合はページタイプをblankPageにするだけで構いません
     NSString *pageData = [NSString stringWithFormat:pageBody,@"blankPage",@"",@"",@""];
     
     //下記2つの処理は必須です
     [pageDic setObject:pageData forKey:[NSString stringWithFormat:key,index]];
     [keyArray addObject:[NSString stringWithFormat:key,index]];
     }
     
    
    //content(フォトブックのページ構成情報)の文字列を作成します。タグ内の値は加工して入れる形になります
    NSString *content = @"<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>"
    //namespaceはepubとの親和性を高める為に設定しておきます
    "<package xmlns='http://www.idpf.org/2007/opf' prefix='cc: http://creativecommons.org/ns# rendition: http://www.idpf.org/vocab/rendition/#' unique-identifier='BookId' version='2.0'>"
    "<spine toc='ncx'>"
    "%@"
    "</spine>"
    "</package>";
    
    NSString *spineItemref = @"";
    for(index = 0;index < keyArray.count;index++){
        NSString *opfKey = [keyArray objectAtIndex:index];
        
        NSString *spineItemrefBody = [NSString stringWithFormat:@"<itemref idref='%@'/>",opfKey];
        spineItemref = [spineItemref stringByAppendingString:spineItemrefBody];
    }
    content = [NSString stringWithFormat:content,spineItemref];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         nil, @"info",
                         book, @"book",
                         pageDic, @"xhtml",
                         content, @"content",
                         nil];
    
    //CustomPasteboardを用意します
    UIPasteboard* pb = [UIPasteboard pasteboardWithName:@"TolotCustomPaseteBoard" create:YES];
    pb.persistent = YES;
    NSData *pasteData = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [pb setData:pasteData forPasteboardType:@"TolotPlusData"];
    
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
    for (NSInteger i = 0; i < 3; i++) {
        NSInteger index = i;
        NSString *pageData = [NSString stringWithFormat:pageBodyFormat, @"blankPage", @"", @"", @""];
        NSString *key = @"page%d";
        [pages setObject:pageData forKey:[NSString stringWithFormat:key, index]];
//        [keyArray addObject:[NSString stringWithFormat:key,index]];
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
    NSLog(@"%@", dictionary);
    
    UIPasteboard* pasteboard = [UIPasteboard pasteboardWithName:@"TolotCustomPaseteBoard" create:YES];
    pasteboard.persistent = YES;
    NSData *pasteData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [pasteboard setData:pasteData forPasteboardType:@"TolotPlusData"];
}

@end
