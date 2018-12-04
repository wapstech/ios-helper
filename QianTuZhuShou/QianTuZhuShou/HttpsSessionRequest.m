//
//  HttpsSessionRequest.m
//  jm
//
//  Created by 贾宏伟 on 2016/12/5.
//  Copyright © 2016年 JiaHongwei. All rights reserved.
//

#import "HttpsSessionRequest.h"

@implementation HttpsSessionRequest
@synthesize resultData, finishBlock;
+ (NSString *)getURLStringWithConnectionType:(int)connectionType {
    NSString *URLString = nil;
    
    switch (connectionType) {
        case CS_CONNECT_TYPE_SDK_TASK: {
            URLString = [NSString stringWithFormat:@"%@%@", DECODE(SH_1), DECODE(U_TASKS)];
        }
            break;
            
        case CS_CONNECT_TYPE_SDK_LESS: {
            URLString = [NSString stringWithFormat:@"%@%@", DECODE(SH_1), DECODE(U_INSTALLED)];
        }
            break;
            
        case CS_CONNECT_TYPE_USER_ID: {
            URLString = [NSString stringWithFormat:@"%@%@", DECODE(SH_1), DECODE(U_PUBLISHER)];
        }
            break;
            
        case CS_CONNECT_TYPE_SCHEME_INFO: {
            URLString = [NSString stringWithFormat:@"%@%@", DECODE(H_1), DECODE(U_INSTALL_INFO)];
        }
            break;
            
        case CS_CONNECT_TYPE_ALT_CONNECT: {
            URLString = [NSString stringWithFormat:@"%@%@", DECODE(SH_2), DECODE(U_CONNECT)];
        }
            break;
            
        case CS_CONNECTION_TYPE_REQUESTACT: {
            URLString= [NSString stringWithFormat:@"%@%@", DECODE(SH_1), DECODE(U_A_INFO)];
        }
            break;
        case CS_CONNECTION_TYPE_ACT: {
            URLString= [NSString stringWithFormat:@"%@%@", DECODE(SH_1),  DECODE(U_A_ACTIVE)];
        }
            break;
            
        case CS_CONNECTION_TYPE_INFO:{
            URLString=[NSString stringWithFormat:@"%@%@", DECODE(SH_1), DECODE(U_U_INFO)];
        }
            break;
            
        case CS_CONNECTION_TYPE_SPEND:{
            URLString=[NSString stringWithFormat:@"%@%@", DECODE(SH_1), DECODE(U_U_SPEND)];
        }
            break;
            
        case CS_CONNECTION_TYPE_AWARD:{
            URLString=[NSString stringWithFormat:@"%@%@", DECODE(SH_1), DECODE(U_U_AWARD)];
        }
            break;
            
        case CS_CONNECT_TYPE_CONNECT:
        default: {
            URLString = [NSString stringWithFormat:@"%@%@", DECODE(SH_1), DECODE(U_CONNECT)];
        }
            break;
            
            
    }
    return URLString;

}
/*
 NSURLSession  代理回调
 
 */
// 1.接收到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);

}
// 2.接收到服务器的数据（可能调用多次）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{

    [self.resultData appendData:data];
}

// 3.请求成功或者失败（如果失败，error有值）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // 请求完成,成功或者失败的处理
    if (error) {
        if (self.finishBlock) {
            self.finishBlock(responseCode,nil);
        }
    }
    else
    {
        NSString *resultStr = [[NSString alloc]initWithData:self.resultData
                                                   encoding:NSUTF8StringEncoding];
        if (self.finishBlock) {
            self.finishBlock(responseCode,resultStr);
        }

    }
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask{

}
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    NSLog(@"证书认证");
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString: NSURLAuthenticationMethodServerTrust]) {
        do
        {
            SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
            NSCAssert(serverTrust != nil, @"serverTrust is nil");
            if(nil == serverTrust)
                break; /* failed */
            /**
             *  导入多张CA证书（Certification Authority，支持SSL证书以及自签名的CA），请替换掉你的证书名称
             */
            NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];//自签名证书
            NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
            
            NSCAssert(caCert != nil, @"caCert is nil");
            if(nil == caCert)
                break; /* failed */
            
            SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
            NSCAssert(caRef != nil, @"caRef is nil");
            if(nil == caRef)
                break; /* failed */
            
            //可以添加多张证书
            NSArray *caArray = @[(__bridge id)(caRef)];
            
            NSCAssert(caArray != nil, @"caArray is nil");
            if(nil == caArray)
                break; /* failed */
            
            //将读取的证书设置为服务端帧数的根证书
            OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
            NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
            if(!(errSecSuccess == status))
                break; /* failed */
            
            SecTrustResultType result = -1;
            //通过本地导入的证书来验证服务器的证书是否可信
            status = SecTrustEvaluate(serverTrust, &result);
            if(!(errSecSuccess == status))
                break; /* failed */
            NSLog(@"stutas:%d",(int)status);
            NSLog(@"Result: %d", result);
            
            BOOL allowConnect = (result == kSecTrustResultUnspecified) || (result == kSecTrustResultProceed);
            if (allowConnect) {
                NSLog(@"success");
            }else {
                NSLog(@"error");
            }
            
            /* kSecTrustResultUnspecified and kSecTrustResultProceed are success */
            if(! allowConnect)
            {
                break; /* failed */
            }
            
#if 0
            /* Treat kSecTrustResultConfirm and kSecTrustResultRecoverableTrustFailure as success */
            /*   since the user will likely tap-through to see the dancing bunnies */
            if(result == kSecTrustResultDeny || result == kSecTrustResultFatalTrustFailure || result == kSecTrustResultOtherError)
                break; /* failed to trust cert (good in this case) */
#endif
            
            // The only good exit point
            NSLog(@"信任该证书");
            
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
            return [[challenge sender] useCredential: credential
                          forAuthenticationChallenge: challenge];
            
        }
        while(0);
    }
    
    // Bad dog
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,credential);
    return [[challenge sender] cancelAuthenticationChallenge: challenge];
}
+ (void)getRequestWithURL:(NSString *)urlStr
                 response:(FinishBlock)block
{
    HttpsSessionRequest *httpsRequest = [[HttpsSessionRequest alloc]init];
    httpsRequest.finishBlock = block;
    
    NSString *requestString = urlStr;
    
    NSURL * ns_url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc]initWithURL:ns_url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:30];
    
    // 2. 发送网络请求.
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requset
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      // ...
                                  }];
    
    [task resume];
}
+ (void)getRequestWithURL:(NSString *)url
               withParams:(NSDictionary *)params
                 response:(FinishBlock)block
{
    HttpsSessionRequest *httpsRequest = [[HttpsSessionRequest alloc]init];
    httpsRequest.finishBlock = block;
    
    NSString *requestString = [NSString stringWithFormat:@"%@?%@", url, [TutuUtils createQueryStringFromDict:params]];
    
    NSURL * ns_url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc]initWithURL:ns_url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:30];
    
    // 2. 发送网络请求.
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requset
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      // ...
                                  }];
    
    [task resume];
}

+ (void)getRequestWithType:(int)connectionType
                withParams:(NSDictionary *)params
                  response:(FinishBlock)block
{
    HttpsSessionRequest *httpsRequest = [[HttpsSessionRequest alloc]init];
    httpsRequest.finishBlock = block;
    
    NSString *URLString = [self getURLStringWithConnectionType:connectionType];
    
    NSString *requestString = [NSString stringWithFormat:@"%@?%@", URLString, [TutuUtils createQueryStringFromDict:params]];
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:30];
    
    // 2. 发送网络请求.
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requset
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      // ...
                                  }];
    
    [task resume];
}
+ (void)postRequestWithType:(int)connectionType
                 withParams:(NSDictionary *)params
                   response:(FinishBlock)block
{
    HttpsSessionRequest *httpsRequest = [[HttpsSessionRequest alloc]init];
    httpsRequest.finishBlock = block;
    
    NSString *URLString = [self getURLStringWithConnectionType:connectionType];
    
    NSString *requestString = [NSString stringWithFormat:@"%@?%@", URLString, [TutuUtils createQueryStringFromDict:params]];
    
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:30];
    [requset setHTTPBody:[[TutuUtils createQueryStringFromDict:params] dataUsingEncoding:NSUTF8StringEncoding]];
    [requset setHTTPMethod:@"POST"];
    
    // 2. 发送网络请求.
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requset
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      // ...
                                  }];
    
    [task resume];
    
}
@end
