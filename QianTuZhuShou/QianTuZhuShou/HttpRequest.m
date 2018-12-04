//
//  HttpRequest.m
//  apilib
//
//  Created by 金小光 on 15/11/4.
//  Copyright © 2015年 金小光. All rights reserved.
//

#import "HttpRequest.h"

@implementation HttpRequest
@synthesize resultData, finishBlock;

+ (NSString *)getURLStringWithConnectionType:(int)connectionType {
    NSString *URLString = nil;
    
    switch (connectionType) {
            
        case C_TYPE_LESS: {
            URLString = [NSString stringWithFormat:@"%@%@", DECODE(H_1), DECODE(U_03)];
        }
            break;
            
        case C_TYPE_REQACT: {
            URLString= [NSString stringWithFormat:@"%@%@", DECODE(H_1), DECODE(U_02)];
        }
            break;
            
        case C_TYPE_ACT: {
            URLString= [NSString stringWithFormat:@"%@%@", DECODE(H_1),  DECODE(U_04)];
        }
            break;

        case C_TYPE_INIT:
        default: {
            
            URLString = [NSString stringWithFormat:@"%@%@", DECODE(H_1), DECODE(U_01)];
        }
            break;
            
    }
    return URLString;
}

#pragma mark 代理方法异步请求

/**
 *  接收到服务器回应的时回调
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    responseCode = [httpResponse statusCode];
    if (!self.resultData) {
        self.resultData = [[NSMutableData alloc]init];
    } else {
        [self.resultData setLength:0];
    }

    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        
    }
}

/**
 *  即将发送服务器所要告知的证书
 */
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge{
    
    if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        // 告诉服务器，客户端信任证书
        // 创建凭据对象
        NSURLCredential *credntial = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        // 告诉服务器信任证书
        [challenge.sender useCredential:credntial forAuthenticationChallenge:challenge];
    }

}

/**
 *  接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.resultData appendData:data];
}

/**
 *  网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.finishBlock) {
        self.finishBlock(responseCode,nil);
    }
}

#pragma mark 计数器连接完成后的动作
/**
 *  数据传完之后调用此方法
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *resultStr = [[NSString alloc]initWithData:self.resultData
                                               encoding:NSUTF8StringEncoding];
    if (self.finishBlock) {
        self.finishBlock(responseCode,resultStr);
    }
}

+ (void)getRequestWithURL:(NSString *)urlStr
                 response:(FinishBlock)block
{
    HttpRequest *httpRequest = [[HttpRequest alloc]init];
    httpRequest.finishBlock = block;
    
    NSString *requestString = urlStr;
    
    NSURL * ns_url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc]initWithURL:ns_url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:30];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:requset delegate:httpRequest];
}

+ (void)getRequestWithURL:(NSString *)url
               withParams:(NSDictionary *)params
                 response:(FinishBlock)block
{
    HttpRequest *httpRequest = [[HttpRequest alloc]init];
    httpRequest.finishBlock = block;

    NSString *requestString = [NSString stringWithFormat:@"%@?%@", url, [TutuUtils createQueryStringFromDict:params]];

    NSURL * ns_url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc]initWithURL:ns_url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:30];

    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:requset delegate:httpRequest];
}

+ (void)postRequestWithType:(int)connectionType
                withParams:(NSDictionary *)params
                  response:(FinishBlock)block
{
    HttpRequest *httpRequest = [[HttpRequest alloc]init];
    httpRequest.finishBlock = block;

    NSString *URLString = [self getURLStringWithConnectionType:connectionType];

    NSString *requestString = [NSString stringWithFormat:@"%@?%@", URLString, [TutuUtils createQueryStringFromDict:params]];


    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:30];
    [requset setHTTPBody:[[TutuUtils createQueryStringFromDict:params] dataUsingEncoding:NSUTF8StringEncoding]];
    [requset setHTTPMethod:@"POST"];

    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:requset delegate:httpRequest];
}

+ (void)getRequestWithType:(int)connectionType
                withParams:(NSDictionary *)params
                  response:(FinishBlock)block
{
    HttpRequest *httpRequest = [[HttpRequest alloc]init];
    httpRequest.finishBlock = block;

    NSString *URLString = [self getURLStringWithConnectionType:connectionType];

    NSString *requestString = [NSString stringWithFormat:@"%@?%@", URLString, [TutuUtils createQueryStringFromDict:params]];
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:30];

    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:requset delegate:httpRequest];
}


//todo:新的联网方法
+ (void)getAsyncRequestWithType:(int)connectionType withParams:(NSDictionary *)params
{
    NSString *URLString = [self getURLStringWithConnectionType:connectionType];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                                    ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        // ...
                                                    }];

    [task resume];
}
@end
