//
//  Bitly.m
//  QuickTweet
//
//  Created by Your Name on 11/02/09.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "Bitly.h"
#import "NSString+URLEncoding.h"
#import "JSON.h"


@implementation Bitly


- (NSString *)bitly:(NSString *)longUrl
{
	NSString *baseURLString = @"http://api.bit.ly/v3/shorten?&login=%@&apiKey=%@&longUrl=%@";
	
	// URLをエンコードする（カテゴリによってNSStringに追加したメソッドを使用）
	NSString *encodedLongURL = [longUrl stringByURLEncoding:NSUTF8StringEncoding];
	
	// bit.lyのAPIをコールするためのURLを作成する
	NSString *urlString = [NSString stringWithFormat:baseURLString, bitlyUserName, bitlyApi, encodedLongURL];
	NSURL *url = [NSURL URLWithString:urlString];
	
	// bit.lyのAPIをコールする
	NSString *jsonResult = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	
	// 取得したJSONフォーマットのデータをjson-frameworkを使ってパースする
	NSDictionary *dic = [jsonResult JSONValue];
	
	// 短縮されたURLを取り出す
	if ([[dic objectForKey:@"status_code"] intValue] == 200) {
		NSString *shortenURL = [[dic objectForKey:@"data"] objectForKey:@"url"];
		return shortenURL;
	} else {
		return @"";
	}
}


@end
