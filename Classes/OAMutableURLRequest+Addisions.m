//
//  OAMutableURLRequest+Addisions.m
//  QuickTweet
//
//  Created by Your Name on 11/02/02.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import "OAMutableURLRequest+Addisions.h"

@implementation OAMutableURLRequest (DC)
- (NSString*)authorizationString {
	NSString *string = [self valueForHTTPHeaderField:@"Authorization"];
	if (!string) {
		[self prepare];
		string = [self valueForHTTPHeaderField:@"Authorization"];
	}
	return string;
}
@end