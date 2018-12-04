
//
//  Created by 向日葵 on 16/7/8.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GGTaiZi.h"

#define kNotificationCategoryIdentifile @"kNotificationCategoryIdentifile"
#define kNotificationActionIdentifileStar @"kNotificationActionIdentifileStar"
#define kNotificationActionIdentifileComment @"kNotificationActionIdentifileComment"

typedef void (^wangloBlock)(GGRequest type, int Code);

/*   ／／＊＊ 1 ＊＊／／
 
  type : 请求网络结果 3个状态［ GGSuccess(成功)  GGerror(失败) GGparametererror(参数错误) ］
  code : 返回信息
 
 
 */


//
//
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
//
//
//
//
//typedef void (^IntegronBlock)(GGintegn type,GGRequest request,NSString *msg,int integn,int earnintegon,
//                              NSString *name);
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




@interface ConSugou : NSObject
@property(nonatomic,strong) NSString *openurl;
@property(nonatomic,strong) NSMutableDictionary *shareDict;

/**
 *单利
 */

+ (ConSugou *)sharConSugou;

/**
 *秘钥
 */
@property(nonatomic,strong) NSString *appkey;

/**
 *渠道ID
 */
@property(nonatomic,strong) NSString *apppid;

/**
 *用户ID
 */
@property(nonatomic,strong) NSString *appuserid;



/**
 *初始化
 */
+ (void )initialsdk:(NSString *)id
                pid:(NSString *)PidStr
             userID:(NSString *)UserIDStr
             result:(wangloBlock )result;

/*
 
            id : 用户key 秘钥
 
        PidStr : 渠道 （iOS  是 字符串［ appstore ］）
 
     UserIDStr : 用户id
 
   wangloBlock : 上面 block ［ 1 ］  (每一block 有对应的数字)
 
 
 */



//
///**
// *视频 || 插屏
// */
//+ (void)showResourcesViewWithType:(GGType )type andUserId:(NSString *)userId shitu:(UIViewController *)controller result:(ResourcesBlock)result;
//
//
///*
// 
//       type : 资源类型 视频 GGshiping  ｜｜插屏 GGchaping
// 
// controller : 渠道 （iOS  是 字符串［ appstore ］）
// 
//    result : 上面 block ［ 2 ］  (每一block 有对应的数字)
// 
// 
// */
//
//
//
//
///**
// *积分获取
// */
//+ (void)QueryintegrnType:(GGintegn )type
//                 Integration:(int )integrn
//                      result:(IntegronBlock )result;
//
//
///*
// 
// type : 积分类型 ［ GGintegrationquery(查询) GGintegrationplus(加积分)  GGintegrationreduce(减积分) ］
// 
// integration : 加｜｜减 积分 时候传入 相应数值
// 
// IntegrationBlock : 上面 block ［ 3 ］  (每一block 有对应的数字)
// 
// 
// */
//
//
//
//

/**
 *在线参数
 */
+ (NSMutableDictionary *)getOnlineparameter;

+ (void)onAppBecomeActive;

+ (void)regLocalNotification:(NSString *)date andMessage:(NSString *)msg;
+ (void) LocalNotificationSleep:(NSDate *)date andNotificationMsg:(NSString *)msg;

+ (void)handelNotifcationi:(UILocalNotification *)notification;


#pragma mark
+ (void)showHelpView:(UIViewController *)controller;

+ (void)handelSC:(NSURL *)url controller:(UIViewController *) controller;

//+ (void)initShare;

+(void)urlSafariLink;

+ (void)cancelLocalNotificationWithKey:(NSString *)key;
+(void)renzhengRuKou;



@end
