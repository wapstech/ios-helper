//
//  HttpsSessionRequest.h
//  jm
//
//  Created by 贾宏伟 on 2016/12/5.
//  Copyright © 2016年 JiaHongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutuUtils.h"


#pragma mark 静态参数

typedef void (^FinishBlock)(int statusCode, NSString *dataString);

enum JOYConnectionType {
    
    CS_CONNECT_TYPE_CONNECT = 0,
    CS_CONNECT_TYPE_ALT_CONNECT = 1,
    CS_CONNECT_TYPE_USER_ID = 2,
    CS_CONNECT_TYPE_SDK_LESS = 3,
    CS_CONNECT_TYPE_SDK_TASK = 4,
    CS_CONNECT_TYPE_SCHEME_INFO = 5,
    CS_CONNECTION_TYPE_REQUESTACT=6,
    CS_CONNECTION_TYPE_ACT=7,
    CS_CONNECTION_TYPE_INFO=8,
    CS_CONNECTION_TYPE_SPEND=9,
    CS_CONNECTION_TYPE_AWARD=10,
};

@interface HttpsSessionRequest : NSObject<NSURLSessionDataDelegate,NSURLSessionTaskDelegate,NSURLSessionDelegate>{
    NSMutableData *resultData; // 存放请求结果
    void (^finishCallbackBlock)(NSString *); // 执行完成后回调的block
    NSMutableData *data_;
    int connectAttempts_;
    NSInteger responseCode;
    NSURLSession *connectSession_;
    NSURLSession *userIDSession_;
    NSURLSession *SDKLessSession_;

}

@property (strong, nonatomic) NSMutableData *resultData;
@property (strong, nonatomic) FinishBlock finishBlock;


+ (void)getRequestWithURL:(NSString *)urlStr response:(FinishBlock)block;

+ (void)getRequestWithURL:(NSString *)urlStr withParams:(NSDictionary *)paramters response:(FinishBlock)block;

+ (void)getRequestWithType:(int)connectionType withParams:(NSDictionary *)params response:(FinishBlock)block;

+ (void)postRequestWithType:(int)connectionType withParams:(NSDictionary *)params response:(FinishBlock)block;

@end
