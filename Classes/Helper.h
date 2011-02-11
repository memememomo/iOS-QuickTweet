//
//  Helper.h
//  TaskWatch2
//
//  Created by Your Name on 11/02/07.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <UIKit/UIKit.h>


#ifdef DEBUG
	#define LOG(...) NSLog(__VA_ARGS__);
	#define LOG_METHOD NSLog(@"%s", __func__);
	#define DNSLogPoint(p) NSLog(@"%f,%f", p.x, p.y);
	#define DNSLogSize(p)  NSLog(@"%f,%f", p.width, p.height);
	#define DNSLogRect(p)  NSLog(@"%f,%f %f,%f", p.origin.x, p.origin.y, p.size.width, p.size.height);
#else
	#define LOG(...)       ;
	#define LOG_METHOD     ;
	#define DNSLogPoint(p) ;
	#define DNSLogSize(p)  ;
	#define DNSLogRect(p)  ;
#endif


#define LOCALIZE(string) NSLocalizedString(string, @"")


void UIAlertViewQuick(NSString* title, NSString* message, NSString* dismissButtonTitle);
UIBarButtonItem* createFlexibleSpace();
UINavigationController* createNavControllerWrappingViewControllerOfClass(Class controller, NSString* nibName, NSString* iconName, NSString* tabTitle);
UINavigationController* createNavControllerWrappingTableViewControllerOfClass(Class controller, NSString* iconName, NSString* tabTitle);

void removeImageFile(NSString *path);
NSString* createTmpImageFile(UIImage *image, NSString *filename);
NSString* newFilePath(NSString *rootPath); 


@interface Helper : NSObject
@end
