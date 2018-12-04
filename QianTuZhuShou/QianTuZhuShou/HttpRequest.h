//
//  HttpRequest.h
//  apilib
//
//  Created by 金小光 on 15/11/4.
//  Copyright © 2015年 金小光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutuUtils.h"

#pragma mark 静态参数

typedef void (^FinishBlock)(int statusCode, NSString *dataString);

enum C_Type {
    C_TYPE_INIT = 0,
    C_TYPE_LESS = 1,
    C_TYPE_REQACT =2,
    C_TYPE_ACT =3
};


@interface HttpRequest : NSObject<NSURLConnectionDataDelegate> {
    NSMutableData *resultData; // 存放请求结果
    void (^finishCallbackBlock)(NSString *); // 执行完成后回调的block
    NSMutableData *data_;
    int connectAttempts_;
    NSInteger responseCode;
    NSURLConnection *connectConnection_;
    NSURLConnection *userIDConnection_;
    NSURLConnection *SDKLessConnection_;
}

@property (strong, nonatomic) NSMutableData *resultData;
@property (strong, nonatomic) FinishBlock finishBlock;

+ (void)getRequestWithURL:(NSString *)urlStr response:(FinishBlock)block;

+ (void)getRequestWithURL:(NSString *)urlStr withParams:(NSDictionary *)paramters response:(FinishBlock)block;

+ (void)getRequestWithType:(int)connectionType withParams:(NSDictionary *)params response:(FinishBlock)block;

+ (void)postRequestWithType:(int)connectionType withParams:(NSDictionary *)params response:(FinishBlock)block;

@end

//调用方式
//[HttpRequest postRequestWithURL:@"http://www.baidu.com"
//paramters:@""
//finshedBlock:^(NSString *dataString) {
//NSLog(@"finish callback block, result: %@", dataString);
//}];