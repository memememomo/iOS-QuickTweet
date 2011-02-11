//
//  TwitPic.h
//  QuickTweet
//
//  Created by Your Name on 11/02/09.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAMutableURLRequest+Addisions.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


// Twitpic(http://dev.twitpic.com/)
// 参考：(http://iphone.longearth.net/2010/08/05/twitpic%E3%81%AEoauthecho%E5%AF%BE%E5%BF%9C/)
#define twitPicApiKey @""


@protocol TwitPicDelegate
- (void)responseTwitPicSuccess:(NSString *)url;
@end


@interface TwitPic : NSObject {
	id<TwitPicDelegate> delegate;
	OAConsumer *consumer_;
	OAToken *accessToken_;
}


@property (nonatomic, assign) id<TwitPicDelegate> delegate;
@property (nonatomic, retain) OAConsumer *consumer;
@property (nonatomic, retain) OAToken *accessToken;


- (ASIFormDataRequest *)createOAuthEchoRequest:(NSString *)url format:(NSString *)format;
- (void)uploadToTwitterByTwitPic:(NSString*)tweet image:(UIImage*)image;
- (void)twitPicRequestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (NSString *)extractUploadURLFromTwitPicResponse:(NSString *)body;

@end
