//
//  Bitly.h
//  QuickTweet
//
//  Created by Your Name on 11/02/09.
//  Copyright 2011 Your Org Name. All rights reserved.
//

#import <Foundation/Foundation.h>


// Bitly(http://bit.ly/)
// 参考：http://www.netimpact.co.jp/blog/11618
#define bitlyUserName @""
#define bitlyApi      @""


@interface Bitly : NSObject {

}

- (NSString *)bitly:(NSString *)longUrl;

@end
