//
//  TwitPic.m
//  QuickTweet
//
//  Created by Your Name on 11/02/09.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "TwitPic.h"


@implementation TwitPic

@synthesize delegate;
@synthesize consumer = consumer_;
@synthesize accessToken = accessToken_;


- (void)dealloc
{
	[consumer_ release];
	[accessToken_ release];
	[super dealloc];
}


/*
 * 画像をTwitPicにアップロードする
 */

- (void)uploadToTwitterByTwitPic:(NSString*)tweet image:(UIImage*)image 
{
	NSString *url = @"http://api.twitpic.com/2/upload.json";
	ASIFormDataRequest *request = [self createOAuthEchoRequest:url format:@"json"];
	
	NSData *imageRepresentation = UIImageJPEGRepresentation(image, 1.0);
	[request setData:imageRepresentation forKey:@"media"];
	[request setPostValue:tweet  forKey:@"message"];
	[request setPostValue:twitPicApiKey  forKey:@"key"];
	
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(twitPicRequestFinished:)];
	[request setDidFailSelector:@selector(requestFailed:)];	
	[request startAsynchronous];
}


/*
 * TwitPicアップロードのレスポンスデリゲート
 */

- (void)twitPicRequestFinished:(ASIHTTPRequest *)request
{
	NSString *responseString = [request responseString];
	
	NSString *url = [self extractUploadURLFromTwitPicResponse:responseString];
	if (!url) {
		[self requestFailed:request];
		return;
	}
	
	[delegate responseTwitPicSuccess:url];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Error:%@",[error localizedDescription]);
}


/*
 * TwitPicのレスポンス処理
 */

- (NSString *)extractUploadURLFromTwitPicResponse:(NSString *)body
{
	NSString *key = @"url";
	NSArray  *array = [body componentsSeparatedByString: @","];
	if (array.count < 1) return nil;
	
	for (NSString *keyValue in array) {
		NSArray *keyValueArray = [keyValue componentsSeparatedByString: @"\":"];
		
		if (keyValueArray.count == 2) {
			NSString *aKey = [keyValueArray objectAtIndex: 0];
			NSString *value = [keyValueArray objectAtIndex: 1];
			
			aKey = [aKey substringWithRange:NSMakeRange(1, aKey.length - 1)];
			value = [value substringWithRange:NSMakeRange(1, value.length - 2)];		   
			if ([aKey isEqualToString:key]) {
				value = [value stringByReplacingOccurrencesOfString:@"\\" withString:@""];
				value = [value stringByReplacingOccurrencesOfString:@"}" withString:@""];
				value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
				return value;
			}
		}
	}
	return nil;
}


/*
 * TwitPicのリクエストヘッダを組み立てる
 */

- (ASIFormDataRequest *)createOAuthEchoRequest:(NSString*)url format:(NSString*)format 
{
	NSString *authorizeUrl = [NSString stringWithFormat:@"https://api.twitter.com/1/account/verify_credentials.%@", format];
	OAMutableURLRequest *oauthRequest = [[[OAMutableURLRequest alloc]
										  initWithURL:[NSURL URLWithString:authorizeUrl]
										  consumer:self.consumer
										  token:self.accessToken   
										  realm:@"http://api.twitter.com/"
										  signatureProvider:nil] 
										 autorelease];
	
	
	NSString *oauthHeader = [oauthRequest authorizationString];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	request.requestMethod = @"POST";
	request.shouldAttemptPersistentConnection = NO;	
	
	[request addRequestHeader:@"X-Auth-Service-Provider" value:authorizeUrl]; 
	[request addRequestHeader:@"X-Verify-Credentials-Authorization" value:oauthHeader];
	
	return request;
}


@end
