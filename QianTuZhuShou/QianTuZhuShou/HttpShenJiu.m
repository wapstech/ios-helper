
#import "HttpShenJiu.h"
#import "TutuUtils.h"

@implementation HttpShenJiu
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
            URLString = [NSString stringWithFormat:@"%@%@", DECODE(SH_1), DECODE(U_02)];
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
        NSDictionary *dic = [httpResponse allHeaderFields];
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

+ (void)getRequestWithURL:(NSString *)url
               withParams:(NSDictionary *)params
                 response:(FinishBlock)block
{
    HttpShenJiu *httpRequest = [[HttpShenJiu alloc]init];
    httpRequest.finishBlock = block;

    NSString *requestString = [NSString stringWithFormat:@"%@?%@", url, [GGInformation createQuSgFmD:params]];

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
    HttpShenJiu *httpRequest = [[HttpShenJiu alloc]init];
    httpRequest.finishBlock = block;

    NSString *URLString = [self getURLStringWithConnectionType:connectionType];

    NSString *requestString = [NSString stringWithFormat:@"%@?%@", URLString, [GGInformation createQuSgFmD:params]];


    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *requset = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:30];
    [requset setHTTPBody:[[GGInformation createQuSgFmD:params] dataUsingEncoding:NSUTF8StringEncoding]];
    [requset setHTTPMethod:@"POST"];

    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:requset delegate:httpRequest];
}

+ (void)getRequestWithType:(int)connectionType
                withParams:(NSDictionary *)params
                  response:(FinishBlock)block
{
    HttpShenJiu *httpRequest = [[HttpShenJiu alloc]init];
    httpRequest.finishBlock = block;

    NSString *URLString = [self getURLStringWithConnectionType:connectionType];

    NSString *requestString = [NSString stringWithFormat:@"%@?%@", URLString, [GGInformation createQuSgFmD:params]];
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
