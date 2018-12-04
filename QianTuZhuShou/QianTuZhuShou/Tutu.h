#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GGTaiZi.h"
//typedef void (^wangloBlock)(GGRequest type, int Code);
//
///*   ／／＊＊ 1 ＊＊／／
// 
// type : 请求网络结果 3个状态［ GGSuccess(成功)  GGerror(失败) GGparametererror(参数错误) ］
// code : 返回信息
// 
// 
// */
//typedef void (^ResourcesBlock)(GGType Resourcestype, GGviewsp type ,NSString *time ,NSString *earnintegration,NSString *code);
//
///*   ／／＊＊ 2 ＊＊／／
// 
// Resourcestype : 广告类型   视频 GGchaping｜｜插屏 GGshiping
// 
// type :  视频播放状态 3个状态［ GGviewspStart(开始)   GGviewspClose(关闭) GGviewspSuccess(成功)］
// 
// time :  剩余播放视频的时间间隔  ＝0 的的时候可以继续播放
// 
// earnintegration :  赚取积分
// 
// code :  错误信息
// 
// */
//typedef void (^IntegronBlock)(GGintegn type,GGRequest request,NSString *msg,int integn,int earnintegon,
//NSString *name);
//
///*   ／／＊＊ 2 ＊＊／／
// 
// type : 积分状态 ［ GGintegrationquery(查询) GGintegrationplus(加积分)  GGintegrationreduce(减积分) ］
// 
// request : 请求网络结果 3个状态［ GGSuccess(成功)  GGerror(失败) GGparametererror(参数错误) ］
// msg : 错误信息
// 
// integration : 剩余积分
// 
// earnintegration : 赚取积分
// 
// name : 积分单位 （一般返回字符串［积分］）
// 
// */
@protocol TODelegate;

#define kNotificationCategoryIdentifile @"kNotificationCategoryIdentifile"
#define kNotificationActionIdentifileStar @"kNotificationActionIdentifileStar"
#define kNotificationActionIdentifileComment @"kNotificationActionIdentifileComment"

@interface Tutu : NSObject

@property(assign) BOOL isInitial;
@property(nonatomic,strong) NSString *TIME;
@property(nonatomic,strong) NSString *ap;
@property(nonatomic,strong) NSString *pd;
@property(nonatomic,strong) NSString *ud;
@property(nonatomic,strong) NSString *openurl;
@property(nonatomic,strong) NSMutableDictionary *shareDict;

@property(nonatomic, assign) id <TODelegate> delegate;
///*视频 || 插屏
// */
//+ (void)showResourcesViewWithType:(GGType )type
//                            shitu:(UIViewController *)controller
//                           result:(ResourcesBlock)result andUrl:(NSString *)url;
///*初始化视频SDK*/
//+( void)initialsdk:(NSString *)id pid:(NSString *)PidStr userID:(NSString *)UserIDStr result:(wangloBlock)result;
//
///**
// *积分获取
// */
//+ (void)QueryintegrnType:(GGintegn )type
//             Integration:(int )integrn
//                  result:(IntegronBlock )result;
//#pragma mark 初始化&计数器调用
+ (Tutu *)shareTutu;

+ (Tutu *)toLink:(NSString *)id;

+ (Tutu *)toLink:(NSString *)id pid:(NSString *)channel;

+ (Tutu *)toLink:(NSString *)id pid:(NSString *)channel uid:(NSString *)theUserID;

+ (NSMutableDictionary *)getConfigs;

+ (void)onAppBecomeActive;

+ (void)regLocalNotification:(NSString *)date andMessage:(NSString *)msg;
+ (void) LocalNotificationSleep:(NSDate *)date andNotificationMsg:(NSString *)msg;

+ (void)handelNotifcationi:(UILocalNotification *)notification;


#pragma mark
+ (void)showHelpView:(UIViewController *)controller;

+ (void)handelSC:(NSURL *)url controller:(UIViewController *) controller;

+ (void)initShare;

+(void)urlSafariLink;

+ (void)cancelLocalNotificationWithKey:(NSString *)key;
+(void)renzhengRuKou;

+ (NSString *)getTime;
+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;

@end


@protocol TODelegate <NSObject>
@optional

- (void)onLinkSuccess;

- (void)onLinkFailed:(NSString *)error;

@end
