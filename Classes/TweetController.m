//
//  TweetController.m
//  QuickTweet
//
//  Created by Your Name on 11/01/24.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "TweetController.h"
#import "LoginController.h"
#import "LocationController.h"


@implementation TweetController


@synthesize lastTweet = lastTweet_;
@synthesize twitterEngine = twitterEngine_;

@synthesize tmpImagePath = tmpImagePath_;


- (void)dealloc
{
	[countLabel_ release];
	[cameraButton_ release];
	[locationButton_ release];
	
	[lastTweet_ release];
	[tmpImagePath_ release];
	
	[twitterEngine_ release];
	
	[twitPic_ release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tmpImagePath = @"";
	self.lastTweet = @"";
	
	
	// ツイッタークライアントの初期化
	self.twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
	self.twitterEngine.consumerKey = kOAuthConsumerKey;
	self.twitterEngine.consumerSecret = kOAuthConsumerSecret;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(accountChanged:)
												 name:@"AccountChanged"
											   object:nil];

	
	// 送信ボタンを設置
	[self attachSendButton];
	
	
	// ユーザー設定ボタンを設定
	[self attachSettingButton];
	
	
	// ログインしているかどうかチェック
	if ([self.twitterEngine isAuthorized]) {
		[tweetText_ becomeFirstResponder];
	} else {
		[LoginController showModal:self.navigationController];
	}
}


#pragma mark -
#pragma mark TextViewController


/*
 * 編集開始時
 */

- (void)textViewDidBeginEditing:(UITextView *)textView 
{
	static const CGFloat kKeyboardHeight = 216.0 - 48.0;
	

	// 編集完了ボタン
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self 
											   action:@selector(doneDidPush)] 
											  autorelease];
	
	
	// カメラボタン
	if (!cameraButton_) {
		cameraButton_ = [self createCameraButton:UIBarButtonItemStyleBordered];
		cameraButton_.style = UIBarButtonItemStyleBordered;
	}
	if ([self.tmpImagePath isEqualToString:@""]) {
		cameraButton_.style = UIBarButtonItemStyleBordered;
	} else {
		cameraButton_.style = UIBarButtonItemStyleDone;
	}
	
	
	// ロケーションボタン
	locationButton_ = [[[UIBarButtonItem alloc]
						initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
						target:self
						action:@selector(locationButtonPush:)]
					   autorelease];
	locationButton_.style = UIBarButtonItemStyleBordered;
	if (coordinate_.longitude || coordinate_.latitude) {
		locationButton_.style = UIBarButtonItemStyleDone;
	}

	
	// 削除ボタン
	UIBarButtonItem *trashButton = [[[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
									 target:self
									 action:@selector(trashButtonPush:)]
									autorelease];
	trashButton.style = UIBarButtonItemStyleBordered;
	
	
	// 文字数カウント
	countLabel_ = [[[UILabel alloc] init] autorelease];
	countLabel_.frame = CGRectMake(0, 0, 30, 30);
	countLabel_.backgroundColor = [UIColor clearColor];
	countLabel_.textColor = [UIColor whiteColor];
	countLabel_.font = [UIFont boldSystemFontOfSize:16];
	[self countText];
	
	UIBarButtonItem *countLabelButton = [[[UIBarButtonItem alloc]
										  initWithCustomView:countLabel_]
										 autorelease];
	
	
	// ツールバー
	[self setToolbarItems:[NSArray arrayWithObjects:
						   trashButton,
						   createFlexibleSpace(),
						   countLabelButton,
						   // TODO:locationButton_,
						   cameraButton_,
						   nil]];
	

	// キーボード表示
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	CGRect textViewFrame = textView.frame;
	textViewFrame.size.height = self.view.bounds.size.height - kKeyboardHeight;
	textView.frame = textViewFrame;

	self.navigationController.toolbarHidden = NO;
	CGRect toolbarFrame = self.navigationController.toolbar.frame;
	toolbarFrame.origin.y = self.view.window.bounds.size.height - toolbarFrame.size.height - kKeyboardHeight - 44.0;
	self.navigationController.toolbar.frame = toolbarFrame;

	[UIView commitAnimations];
}


/*
 * 編集中
 */

- (void)textViewDidChange:(UITextView *)textView
{
	[self countText];
}


/*
 * 編集終了時
 */

- (void)textViewDidEndEditing:(UITextView *)textView 
{
	[self attachSendButton];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:0.3];
	
	textView.frame = self.view.bounds;
	
	CGRect toolbarFrame = self.navigationController.toolbar.frame;
	toolbarFrame.origin.y = self.view.window.bounds.size.height - toolbarFrame.size.height;
	self.navigationController.toolbar.frame = toolbarFrame;
	[UIView commitAnimations];
	
	self.navigationController.toolbarHidden = YES;
}


/*
 * 送信ボタン
 */

- (void)attachSendButton
{
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithTitle:@"Send" 
											   style:UIBarButtonItemStylePlain
											   target:self
											   action:@selector(sendButtonPush)] autorelease];
}


/*
 * 送信ボタン
 */

- (void)attachSettingButton
{
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
											   target:self
											   action:@selector(settingButtonPush)]
											  autorelease];
}


/*
 * 入力文字数
 */

- (void)countText
{
	int currentLength = [tweetText_.text length];
	countLabel_.text = [NSString stringWithFormat:@"%d", 140 - currentLength];
}


#pragma mark -
#pragma mark Button Push Action


/*
 * ツイート編集完了ボタン
 */

- (void)doneDidPush
{
	[tweetText_ resignFirstResponder];
}


/*
 * ツイート送信ボタン
 */

- (void)sendButtonPush
{
	if (![self.twitterEngine isAuthorized]) {
		[LoginController showModal:self.navigationController];
	} else {
		self.lastTweet = tweetText_.text;
		tweetText_.text = @"";
		
		if (![self.tmpImagePath isEqualToString:@""]) {
			UIImage *image = [UIImage imageWithContentsOfFile:self.tmpImagePath];
			
			if (!twitPic_) {
				twitPic_ = [[TwitPic alloc] init];
				twitPic_.delegate = self;
			}

			twitPic_.accessToken = self.twitterEngine.accessToken;
			twitPic_.consumer = self.twitterEngine.consumer;
			[twitPic_ uploadToTwitterByTwitPic:self.lastTweet image:image];
		} else {
			if (![self.lastTweet isEqualToString:@""]) {
				if (coordinate_.latitude) {
					[self.twitterEngine sendUpdate:self.lastTweet];
				} else {
					[self.twitterEngine sendUpdate:self.lastTweet];
				}
			}
		}
	}
}


/*
 * ユーザー設定ボタン
 */

- (void)settingButtonPush
{
	[LoginController showModal:self.navigationController];
}



#pragma mark -
#pragma mark Trash

- (void)trashButtonPush:(id)sender
{
	UIAlertView *alert =
	[[UIAlertView alloc] initWithTitle:@"確認" 
							   message:@"削除してもよろしいですか？"
							  delegate:self 
					 cancelButtonTitle:@"いいえ"
					 otherButtonTitles:@"はい", 
	 nil];
	[alert show];
	[alert release];
}


-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	
	switch (buttonIndex) {
		case 0:
			//１番目のボタンが押されたときの処理を記述する
			break;
		case 1:
			//２番目のボタンが押されたときの処理を記述する
			lastTweet_ = @"";
			tweetText_.text = @"";
			coordinate_.latitude = 0;
			coordinate_.longitude = 0;
			removeImageFile(self.tmpImagePath);
			self.tmpImagePath = @"";
			cameraButton_.style = UIBarButtonItemStyleBordered;
			locationButton_.style = UIBarButtonItemStyleBordered;
			break;
	}
}


#pragma mark -
#pragma mark Location Delegate

- (void)locationButtonPush:(id)sender
{
	LocationController *location = [LocationController sharedObject];
	location.delegate = self;
	[location yobidashi];
}


- (void)updateCoordinate:(CLLocationCoordinate2D)coordinate
{
	coordinate_ = coordinate;
	LocationController *location = [LocationController sharedObject];
	[location stop];

	locationButton_.style = UIBarButtonItemStyleDone;
}


#pragma mark -
#pragma mark Camera

- (void)cameraButtonPush:(id)sender
{
	// アクションシートを呼び出す
	UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
	sheet.delegate = self;
	[sheet addButtonWithTitle:@"Camera"];
	[sheet addButtonWithTitle:@"アルバム"];
	[sheet addButtonWithTitle:@"キャンセル"];
	sheet.cancelButtonIndex = 2;
	[sheet showInView:self.navigationController.toolbar];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	// ボタンインデックスをチェックする
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	
	// ソースタイプを決定する
	UIImagePickerControllerSourceType sourceType = 0;
	switch (buttonIndex) {
		case 0:
			sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
		case 1:
			sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;
	}
	
	// 使用可能かどうかチェックする
	if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
		UIAlertViewQuick(@"", @"Not Available", @"OK");
		return;
	}

	// イメージピッカーを作る
	UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
	picker.delegate = self;
	picker.sourceType = sourceType;

	
	// イメージピッカーを表示する
	[self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// イメージピッカーを隠す
	[self dismissModalViewControllerAnimated:YES];
	
	// オリジナル画像を取得する
	UIImage*    originalImage;
	originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	// グラフィックスコンテキストを作る
	CGSize  size = { 300, 400 };
	UIGraphicsBeginImageContext(size);
	
	// 画像を縮小して描画する
	CGRect  rect;
	rect.origin = CGPointZero;
	rect.size = size;
	[originalImage drawInRect:rect];
	
	// 描画した画像を取得する
	UIImage*    shrinkedImage;
	shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	

	// ボタンを明るくする
	cameraButton_.style = UIBarButtonItemStyleDone;
	
	
	// 一時保存する
	self.tmpImagePath = createTmpImageFile(shrinkedImage, @"tmp.jpg");
}


- (UIBarButtonItem *)createCameraButton:(NSInteger)style
{
	UIImage *image = [UIImage imageNamed:@"camera"];
	UIBarButtonItem *cameraButton = [[[UIBarButtonItem alloc]
									  initWithImage:image
									  style:style
									  target:self
									  action:@selector(cameraButtonPush:)]
									 autorelease];
	return cameraButton;
}


#pragma mark -
#pragma mark Twitter Delegate

/*
 * isAuthorizedで呼び出され、予備トークンがあるかをチェック
 */

- (NSString *)cachedTwitterXAuthAccessTokenStringForUsername:(NSString *)username 
{
	NSString *accessTokenString = [[NSUserDefaults standardUserDefaults] 
								   objectForKey:kCachedXAuthAccessTokenStringKey];
	return accessTokenString;
}


/*
 * トークンを取得するタイミングでキャッシュに保存
 */

- (void)storeCachedTwitterXAuthAccessTokenString:(NSString *)tokenString forUsername:(NSString *)username
{
	[[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kCachedXAuthAccessTokenStringKey];
}


/*
 * トークン取得失敗の時に呼び出される
 */

- (void)twitterXAuthConnectionDidFailWithError:(NSError *)error
{
	UIAlertViewQuick(@"Authentication error", @"Please check your username and password and try again.", @"OK");
}


/*
 * Notification経由で呼び出される
 */

- (void)accountChanged:(NSNotification *)notification
{
	NSString *login = [[notification userInfo] objectForKey:@"login"];
	NSString *password = [[notification userInfo] objectForKey:@"password"];
	
	[self.twitterEngine exchangeAccessTokenForUsername:login password:password];
}


/*
 * ツイートが成功すると呼び出される
 */

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	//NSLog(@"Twitter request succeeded: %@", connectionIdentifier);

	tweetText_.text = @"";
	lastTweet_ = @"";
	
	UIAlertViewQuick(@"Tweet sent!", @"The tweet was successfully sent. Everything works!", @"OK");
}


/*
 * ツイートが失敗すると呼び出される
 */

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	NSLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
	
	if ([[error domain] isEqualToString: @"HTTP"])
	{
		switch ([error code]) {
				
			case 401:
			{
				// Unauthorized. The user's credentials failed to verify.
				UIAlertViewQuick(@"Oops!", @"Your username and password could not be verified. Double check that you entered them correctly and try again.", @"OK");	
				break;				
			}
				
			case 502:
			{
				// Bad gateway: twitter is down or being upgraded.
				UIAlertViewQuick(@"Fail whale!", @"Looks like Twitter is down or being updated. Please wait a few seconds and try again.", @"OK");	
				break;				
			}
				
			case 503:
			{
				// Service unavailable
				UIAlertViewQuick(@"Hold your taps!", @"Looks like Twitter is overloaded. Please wait a few seconds and try again.", @"OK");	
				break;								
			}
				
			default:
			{
				NSString *errorMessage = [[NSString alloc] initWithFormat: @"%d %@", [error	code], [error localizedDescription]];
				UIAlertViewQuick(@"Twitter error!", errorMessage, @"OK");	
				[errorMessage release];
				break;				
			}
		}
		
	}
	else 
	{
		switch ([error code]) {
				
			case -1009:
			{
				UIAlertViewQuick(@"You're offline!", @"Sorry, it looks like you lost your Internet connection. Please reconnect and try again.", @"OK");					
				break;				
			}
				
			case -1200:
			{
				UIAlertViewQuick(@"Secure connection failed", @"I couldn't connect to Twitter. This is most likely a temporary issue, please try again.", @"OK");					
				break;								
			}
				
			default:
			{				
				NSString *errorMessage = [[NSString alloc] initWithFormat:@"%@ xx %d: %@", [error domain], [error code], [error localizedDescription]];
				UIAlertViewQuick(@"Network Error!", errorMessage , @"OK");
				[errorMessage release];
			}
		}
	}
}



#pragma mark -
#pragma mark TwitPic Delegate


- (void)responseTwitPicSuccess:(NSString *)url
{
	Bitly *bitly = [[[Bitly alloc] init] autorelease];
	
	
	// 短縮する
	NSString *shortUrl = [bitly bitly:url];
	if ([shortUrl isEqualToString:@""]) {
		shortUrl = url;
	}
	
	[self.twitterEngine sendUpdate:[NSString stringWithFormat:@"%@ %@", self.lastTweet, shortUrl]];
	removeImageFile(self.tmpImagePath);
	self.tmpImagePath = @"";
	self.lastTweet = @"";
	
}


@end


