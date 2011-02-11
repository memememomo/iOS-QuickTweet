//
//  LoginController.m
//  QuickTweet
//
//  Created by Your Name on 11/02/02.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "LoginController.h"


@implementation LoginController


/*
 * 初期化と後処理
 */

- (void)dealloc 
{
	[usernameField_ release];
	[passwordField_ release];
	
	[keys_ release];
	[dataSource_ release];
	[super dealloc];
}

- (id)init
{
	// テーブルの表示形式を指定する
	if ( (self = [super initWithStyle:UITableViewStyleGrouped]) ) {
		self.title = @"SectionTable";
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// 選択されたセルのハイライトを解除する
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
	
	[usernameField_ becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// テーブルの削除を可能にする
	//[self.tableView setEditing:YES animated:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// セクション名
	keys_ = [[NSMutableArray alloc] initWithObjects:@"アカウント", nil];
	
	// 各セクションのデータ
	NSArray *object1 = [NSArray arrayWithObjects:@"ユーザー名", @"パスワード", nil];
	NSMutableArray *objects = [NSMutableArray arrayWithObjects:object1, nil];
	
	// セクション名とデータを合わせる
	dataSource_ = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys_];
	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	usernameField_ = [[UITextField alloc]
					  initWithFrame:CGRectMake(110, 10, 150, 30)];
	usernameField_.returnKeyType = UIReturnKeyNext;
	usernameField_.keyboardType = UIKeyboardTypeEmailAddress;
	usernameField_.delegate = self;
	usernameField_.tag = 0;
	usernameField_.text = [defaults objectForKey:@"username"];
	
	
	passwordField_ = [[UITextField alloc]
					  initWithFrame:CGRectMake(110, 10, 150, 30)];
	passwordField_.returnKeyType = UIReturnKeyDone;
	passwordField_.keyboardType = UIKeyboardTypeEmailAddress;
	passwordField_.delegate = self;
	passwordField_.tag = 1;
	passwordField_.text = [defaults objectForKey:@"password"];
	passwordField_.secureTextEntry = YES;
}


/*
 * 各セクションの項目数を返す
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id key = [keys_ objectAtIndex:section];
	return [[dataSource_ objectForKey:key] count];
}


/*
 * セルの内容
 */

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString *identifier = @"basis-cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if ( nil == cell ) {
		// 詳細情報ありの場合
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:identifier];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell autorelease];
	}

	UILabel *label = [[[UILabel alloc] 
					   initWithFrame:CGRectMake(10, 6, 100, 30)] 
					  autorelease];
	label.font = [UIFont boldSystemFontOfSize:18];
	
	
	if (indexPath.row == 0) {
		label.text = @"ユーザー名";
		[cell.contentView addSubview:usernameField_];
	} else if (indexPath.row == 1) {
		label.text = @"パスワード";
		[cell.contentView addSubview:passwordField_];
	}

	
	// セルにコントロールを追加
	[cell.contentView addSubview:label];

	
	return cell;
}



/*
 * セクションの数を返す
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [keys_ count];
}


/*
 * section番目のセクション名を返す
 */

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [keys_ objectAtIndex:section];
}



#pragma mark -
#pragma mark TextField Delegate



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ( textField.tag == 0 ) {
		[passwordField_ becomeFirstResponder];
	} else {
		NSString *login = usernameField_.text;
		NSString *password = passwordField_.text;
		
		[textField resignFirstResponder];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:login forKey:@"username"];
		[defaults setObject:password forKey:@"password"];
		[defaults setObject:nil forKey:kCachedXAuthAccessTokenStringKey];

		
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"AccountChanged"
		 object:nil
		 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:login, @"login", password, @"password", nil]];
		
		[self dismissModalViewControllerAnimated:YES];
	}
	return YES;
}



#pragma mark -
#pragma mark Interface


+ (void)showModal:(UINavigationController *)parentController
{
	static LoginController *sharedController;
	static UINavigationController *navigationController;
	if (!sharedController) {
		sharedController = [[LoginController alloc] init];
		navigationController = [[UINavigationController alloc]
								initWithRootViewController:sharedController];
	}
	
	[parentController presentModalViewController:navigationController animated:YES];
}


@end
