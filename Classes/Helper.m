//
//  Helper.m
//  TaskWatch2
//
//  Created by Your Name on 11/02/07.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "Helper.h"


/*
 * 簡易アラート
 */

void UIAlertViewQuick(NSString* title, NSString* message, NSString* dismissButtonTitle) 
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:nil 
										  cancelButtonTitle:dismissButtonTitle
										  otherButtonTitles:nil
						  ];
	[alert show];
	[alert autorelease];
}


/*
 * ツールバーのスペース
 */

UIBarButtonItem* createFlexibleSpace()
{
	UIBarButtonItem *space = [[[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
							   target:nil
							   action:nil]
							  autorelease];
	return space;
}


/*
 * タブバーに追加するナビゲーションを作成するヘルパー
 */

UINavigationController* createNavControllerWrappingViewControllerOfClass(Class controller, NSString* nibName, NSString* iconName, NSString* tabTitle)
{
	UIViewController* viewController = [[controller alloc] initWithNibName:nibName bundle:nil];
	
	UINavigationController *theNavigationController;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	viewController.tabBarItem.image = [UIImage imageNamed:iconName];
	viewController.title = NSLocalizedString(tabTitle, @""); 
	[viewController release];
	
	return theNavigationController;
}

UINavigationController* createNavControllerWrappingTableViewControllerOfClass(Class controller, NSString* iconName, NSString* tabTitle)
{
	UITableViewController* tableViewController = [[controller alloc] init];
	
	UINavigationController *theNavigationController;
	theNavigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
	tableViewController.tabBarItem.image = [UIImage imageNamed:iconName];
	tableViewController.title = NSLocalizedString(tabTitle, @""); 
	[tableViewController release];
	
	return theNavigationController;
}


/*
 * ファイルを削除する
 */

void removeImageFile(NSString *path) 
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		[fileManager removeItemAtPath:path error:nil];
	}
}


/*
 * 保留している画像をファイルで出力しておく
 */

NSString* createTmpImageFile(UIImage *image, NSString *filename)
{
	NSString *tempDir = NSTemporaryDirectory();
	NSString *path = [tempDir stringByAppendingPathComponent:filename];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
	
	NSData *data = UIImageJPEGRepresentation(image, 0.8);
	[data writeToFile:path atomically:YES];
	
	return path;
}


/*
 * 保存するファイル名をランダムに決める
 */

NSString* newFilePath(NSString *rootPath)
{
	// はじめて呼び出されたときは乱数の種を初期化する
	static BOOL sFirst = YES;
	
	if (sFirst) {
		srandomdev();
		sFirst = NO;
	}
	
	// ドキュメントフォルダのパスを取得する
	NSArray *array;
	array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
												NSUserDomainMask,
												YES);
	
	NSString *dir = [array lastObject];
	
	
	// ドキュメントフォルダ内で重複しないファイル名を決定する
	// ファイル名は乱数を文字列化したものとする
	NSString *path = nil;
	
	while (!path) {
		// 乱数を生成
		long l = random();
		
		// 乱数を文字列化してファイル名を作成する
		NSString *fileName;
		fileName = [NSString stringWithFormat:@"%X.jpg", l];
		
		// ファイルパスを作成
		NSString *tempPath;
		tempPath = [dir stringByAppendingPathComponent:fileName];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:tempPath]) {
			// 存在しないので、このファイル名とする
			// [pool release]で解放されないようにするため、「copy」メソッドでコピーする
			path = tempPath;
		}
	}
	
	// ファイルパスを返す
	return path;
}



@implementation Helper
@end