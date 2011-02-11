//
//  LoginController.h
//  QuickTweet
//
//  Created by Your Name on 11/02/02.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetController.h"

@interface LoginController : UITableViewController<UITextFieldDelegate> {
	NSMutableArray *keys_;
	NSMutableDictionary *dataSource_;
	
	UITextField *usernameField_;
	UITextField *passwordField_;
}

+ (void)showModal:(UINavigationController *)parentController;

@end
