//
//  TweetController.h
//  QuickTweet
//
//  Created by Your Name on 11/01/24.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitPic.h"
#import "Bitly.h"
#import "XAuthTwitterEngine.h"
#import "LocationController.h"

#define kCachedXAuthAccessTokenStringKey @"cachedXAuthAccessTokenKey"



// XAuthを使うときは申請メールを送る必要がある(http://dev.twitter.com/pages/xauth)
// アプリのスクリーンショットは、添付ファイルだと受け取ってもらえないので、アップロードしてリンクを記述する必要がある。
#define kOAuthConsumerKey                @""
#define kOAuthConsumerSecret             @""




@interface TweetController : UIViewController<UITextViewDelegate, XAuthTwitterEngineDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, LocationControllerDelegate, TwitPicDelegate> {
	IBOutlet UITextView *tweetText_;
	
	XAuthTwitterEngine *twitterEngine_;
	
	NSString *lastTweet_;
	
	CLLocationCoordinate2D coordinate_;
	
	UILabel *countLabel_;
	UIBarButtonItem *cameraButton_;
	UIBarButtonItem *locationButton_;
	
	NSString *tmpImagePath_;
	
	TwitPic *twitPic_;
}

@property (nonatomic, retain) NSString *lastTweet;
@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;
@property (nonatomic, retain) NSString *tmpImagePath;

- (void)countText;
- (UIBarButtonItem *)createCameraButton:(NSInteger)style;
- (void)attachSendButton;
- (void)attachSettingButton;

@end

