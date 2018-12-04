#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

#import "params.h"

@interface GGInformation : NSObject

#pragma mark 参数相关操作
+ (NSMutableDictionary *)genParams;

+ (NSMutableDictionary *)genParams:(NSString *)appID_;


//createQueryStringFromDict
+ (NSString *)createQuSgFmD:(NSDictionary *)paramDict;


//createQueryStringFromString
+ (NSString *)createQuSgFmS:(NSString *)string;


//getQueryStringParams
+ (NSMutableDictionary *)getQuSgP:(NSString *)queryString;


//appendParamsWithURL
+ (NSString *)appendPWU:(NSString *)url;


//+ (NSString *)getURLWithParams:(NSString *)url_;


//getTimeStamp
+ (NSString *)getTimeS;


//+ (void)dataRequest:(NSURLRequest *)request andObject:(id)object tag:(int)tag;


//getOpenIDFAArray
+ (NSArray*)getOidfaArr;



#pragma mark 设备及用户相关操作
+ (BOOL)isGreaterVer:(float)ver;

+ (NSString *)getUserID;

//+ (BOOL)isStatusBarHidden;

//getCurrentDeviceWidth
+ (CGFloat)getCurrDW;
//getCurrentDeviceHeight
+ (CGFloat)getCurrDH;



#pragma mark 加密解密操作
+ (NSString *)DEC:(NSString *)sText;

//+ (NSString *)ENC:(NSString *)sText;
//
//+ (NSString *)encode:(NSString *)sText key:(NSString *)_key;
//
//+ (NSString *)decode:(NSString *)sText key:(NSString *)_key;


//encryptWithText
+ (NSString *)encWText:(NSString *)sText;
//decryptWithText
+ (NSString *)decWText:(NSString *)sText;


//+ (NSString *)SHA256WithTimeStamp:(NSString *)timeStamp;
//
//+ (NSString *)SHA256WithTimeStamp:(NSString *)timeStamp param:(NSString *)param;
//
//+ (NSString *)SHA256WithTimeStamp:(NSString *)timeStamp points:(int)points guid:(NSString *)guid;
//
//+ (NSString *)SHA256WithString:(NSString *)dataStr;
//
//+ (NSString *)md5Hash:(NSString *)str;



//+ (NSString *)md5Hash:(NSString *)str;


#pragma mark 持久存储操作
+ (NSString *)getChObj:(NSString *)defaultName;

+ (void)setChObj:(NSString *)value forKey:(NSString *)defaultName;

//+ (void)clearCache;


#pragma mark 设备信息操作
//+ (BOOL)isSimu;

+ (BOOL)isPad;

//+ (BOOL)isIOS7;

//+ (NSString *)getTasks:(int)type;

//removeCacheObjectForKey
+ (void)removeChObj:(NSString *)defaultName;

//getDeviceOrientation
+ (NSString *)getDevOri;




#pragma mark 其他一些通用处理工具方法
//+ (NSString *)getShortSC:(NSString *)scString;
//
//+ (CGRect)getMidFrameWidthStr:(float)width heightStr:(float)height;
//
//+ (NSString *)getConfigValue:(NSString *)key;

+ (NSArray *)json2menu:(NSString *)jsonStr;

+ (NSString *)obj2JsonStr:(id)dict;

+ (id)jsonStr2Obj:(NSString *)json;

#pragma mark 测试视图
//+ (void)testView:(UIView *)rootViews space:(NSString *)space;

+ (void )mvkey:(NSString *)adid;

+(NSString *)getNetWorkStates;

@end

