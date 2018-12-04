#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
#import "params.h"

@interface TutuUtils : NSObject

#pragma mark 参数相关操作
+ (NSMutableDictionary *)getParams;

+ (NSMutableDictionary *)getParams:(NSString *)appID_;

+ (NSString *)createQueryStringFromDict:(NSDictionary *)paramDict;

+ (NSString *)createQueryStringFromString:(NSString *)string;

+ (NSMutableDictionary *)getQueryStringParams:(NSString *)queryString;

+ (NSString *)appendParamsWithURL:(NSString *)urlStr;

+ (NSString *)getURLWithParams:(NSString *)urlStr;

+ (NSString *)getTimeStamp;

+ (NSArray*) getOpenIDFAArray;

+ (NSString *)getFACode;

+ (NSString *)getFA;

#pragma mark 设备及用户相关操作
+ (BOOL)isGreaterThanVersion:(float)ver;

+ (NSString *)getUserID;

#pragma mark 加密解密操作
+ (NSString *)DEC:(NSString *)sText;

+ (NSString *)ENC:(NSString *)sText;

+ (NSString *)encode:(NSString *)sText key:(NSString *)_key;

+ (NSString *)decode:(NSString *)sText key:(NSString *)_key;

+ (NSString *)encryptWithText:(NSString *)sText;

+ (NSString *)decryptWithText:(NSString *)sText;

+ (NSString *)SHA256WithTimeStamp:(NSString *)timeStamp;

+ (NSString *)SHA256WithTimeStamp:(NSString *)timeStamp param:(NSString *)param;

+ (NSString *)SHA256WithTimeStamp:(NSString *)timeStamp points:(int)points guid:(NSString *)guid;

+ (NSString *)SHA256WithString:(NSString *)dataStr;

+ (NSString *)md5Hash:(NSString *)str;

#pragma mark 持久存储操作
+ (NSString *)getCacheObjectForKey:(NSString *)defaultName;

+ (void)setCacheObject:(NSString *)value forKey:(NSString *)defaultName;

+ (void)clearCache;

+ (void)saveKeyChain:(NSString *)service data:(id)data;

+ (id)loadKeyChain:(NSString *)service;


#pragma mark 设备信息操作
+ (BOOL)isSimu;

+ (BOOL)isPad;

+ (BOOL)isIOS7;

+ (void)removeCacheObjectForKey:(NSString *)defaultName;

+ (NSString *)getDeviceOrientation;


#pragma mark 其他一些通用处理工具方法
+ (NSString *)getShortSC:(NSString *)scString;

+ (NSString *)getConfigValue:(NSString *)key;

+ (NSString *)obj2JsonStr:(id)dict;

+ (id)jsonStr2Obj:(NSString *)json;

#pragma mark 时间相关方法
+ (NSTimeInterval)compareOldDateStr:(NSString *)dateString;
@end

