//
//  Flow.h
//  apilib
//
//  Created by 金小光 on 15/11/9.
//  Copyright © 2015年 金小光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <sys/sysctl.h>

@interface Flow : NSOperation{

}

@property (nonatomic, assign) NSTimer *tloop;

+ (Flow *)shareFlow;

- (void)setMessageArray:(NSMutableArray *)msgList;

- (NSMutableArray *)getMessagegArray;

- (void)removeSListFromChache;

- (BOOL)saveInfoWithURLString:(NSString *)urlString;

- (BOOL)canCall:(NSString*)bbb;

- (void)call:(NSString*)bbb;

- (NSString *)allList;

- (BOOL)reqOpenByJson:(NSString *)appInfoJson;

- (void)loop;
@end
