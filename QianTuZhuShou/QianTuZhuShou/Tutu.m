//
//  Tutu.m
//  apilib
//
//  Created by 金小光 on 15/11/4.
//  Copyright © 2015年 金小光. All rights reserved.
//

#import "Tutu.h"
#import "params.h"
#import "TutuUtils.h"
#import "HttpRequest.h"
#import "THXMLParser.h"
#import "Flow.h"
#import "HelpViewController.h"
#import "SCUtils.h"
#import "WXApiManager.h"
#import "BackWorks.h"
#import "HttpShenJiu.h"
#import "CParser.h"
#import "GGInformation.h"
#import "CEncrypt.h"
static Tutu *instance = nil;

@interface Tutu ()
//@property (nonatomic,copy) wangloBlock block; //网络

@end

@implementation Tutu

static Tutu *shareTutu = nil;

+ (Tutu *)shareTutu
{
    @synchronized(self)
    {
        if (shareTutu == nil)
        {
            shareTutu = [[self alloc] init];
        }
    }
    return shareTutu;
}
#pragma mark 计数器、单例初始化

+ (Tutu *)init {
    if (!instance) {
        instance = [[super alloc] init];
    }
    return instance;
}

- (void)initConnectWithAppID:(NSString *)id channel:(NSString *)channel userID:(NSString *)userid {
    _ap = id;
    _pd = channel;
    if (userid) {
        _ud = userid;
    } else {
        _ud = @"";
    }
}

+ (Tutu *)toLink:(NSString *)id {
    return [self toLink:id pid:nil];
}

+ (Tutu *)toLink:(NSString *)id pid:(NSString *)channel {
    return [self toLink:id pid:channel uid:nil];
}
- ( NSString*)chuanAppKey:(NSString *)id AppPid:(NSString *)pid UserId:(NSString *)userid{
    
    
    self.ap=id;
    self.pd=pid;
    
    
    if((self.ap==nil||self.ap.length<=0)||(self.pd==nil||self.pd.length<=0)){
        
//        [self fanhuipanduan:@"参数错误" Code:0];
//
        return @"失败";
    }
    
    if (userid) {
        self.ud = userid;
    } else {
        self.ud = @"";
    }
    
    return @"成功";
    
}


- (void)initShare{
    
    
    NSMutableDictionary * params= [Tutu getConfigs];

//    NSMutableDictionary * params= [ConSugou getOnlineparameter];
    NSString * weixinkey=params[@"shareapp_id"];
    NSString * wxname=@"测试";
    if (weixinkey.length<=0||weixinkey==nil) {
        
        weixinkey=@"wx220b90b61a79d4f5";
    }else{
        wxname=params[@"shareapp_name"];
        
    }
    
    BOOL ce= [WXApi registerApp:weixinkey enableMTA:YES];
    if (ce) {
        NSLog(@"成功");
    }
    
}
+ (Tutu *)toLink:(NSString *)id pid:(NSString *)channel uid:(NSString *)theUserID {
    
    [[Tutu shareTutu] initConnectWithAppID:id channel:channel userID:theUserID];
    NSString *str = [[Tutu shareTutu] chuanAppKey:id AppPid:channel UserId:theUserID];
    [Tutu shareTutu].isInitial = YES;
    
    if ([str isEqualToString:@"成功"]){  //参数正确请求网络
        
        
        [HttpRequest getRequestWithType:C_TYPE_INIT withParams:[TutuUtils getParams:id] response:^(int statusCode, NSString *dataString) {
            
//                    NSLog(@"%@",dataString);
            [self linkFinishLoading:statusCode response:dataString];
            [[Tutu shareTutu] initShare];

        }];
        
    }
    return nil;
}
//+(void)initialsdk:(NSString *)id pid:(NSString *)PidStr userID:(NSString *)UserIDStr result:(wangloBlock)result{
//    
//    [Tutu shareTutu].block = result;
//    
//    NSString *str = [[Tutu shareTutu] chuanAppKey:id AppPid:PidStr UserId:UserIDStr];
//    
//    //    NSDictionary *dic=[GGInformation genParams:id];
//    if ([str isEqualToString:@"成功"]){  //参数正确请求网络
//        
//        [HttpShenJiu getRequestWithType:CS_CONNECT_TYPE_CONNECT withParams:[TutuUtils getParams:id] response:^(int statusCode, NSString *dataString) {
//            //            NSLog(@"finish callback block, result: %d ,  %@",statusCode, dataString);
//            [[Tutu shareTutu] chuanStatusCode:statusCode DataString:dataString];
//            
//        }];
//        
//    }
//    
//}

+ (void)onLinkSuccess {
    if ([[[Tutu shareTutu] delegate] respondsToSelector:@selector(onLinkSuccess)]) {
        [[[Tutu shareTutu] delegate] onLinkSuccess];
    }
}

+ (void)onLinkFailed:(NSString *)error {
    if ([[[Tutu shareTutu] delegate] respondsToSelector:@selector(onLinkFailed:)]) {
        [[[Tutu shareTutu] delegate] onLinkFailed:error];
    }
}

+ (void)linkFinishLoading:(int)statusCode response:(NSString *)dataString; {
    //todo:开始扫描
    [[Flow shareFlow] loop];
    if (statusCode == 200) {
        if (dataString && dataString.length > 0) {
            NSRange range = [dataString rangeOfString:DECODE(OP_R)];
            if (!range.length > 0) {
                [self onLinkFailed:@"nil"];
            } else {
                NSData *xmlData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                THXMLParser *parser = [[THXMLParser alloc] init];
                NSDictionary *resultObject = [parser parseData:xmlData];
                NSDictionary *dataArray = [THXMLParser getDataAtPath:DECODE(OP_R) fromResultObject:resultObject];
                if (dataArray) {
                    
                    NSString *newVersion_ = dataArray[DECODE(OP_VER)];
                    NSString *updateTip = dataArray[DECODE(OP_UPTIP)];
                    
                    //新版本升级判断
                    if ([newVersion_ length] > 0) {
                        NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *) kCFBundleVersionKey];
                        BOOL result = [bundleVersion compare:newVersion_] == NSOrderedAscending;
                        if (result) {
                            [TutuUtils setCacheObject:newVersion_ forKey:DECODE(C_VER)];
                            NSString *isUpdate = [TutuUtils getCacheObjectForKey:newVersion_];
                            if (isUpdate && [isUpdate isEqualToString:@"NO"]) {
                                
                            } else {
                                NSString *updateMessage = nil;
                                if ([updateTip length] > 0) {
                                    updateMessage = updateTip;
                                } else {
                                    updateMessage = [[NSString alloc] initWithString:[NSString stringWithFormat:DECODE(M_VER), newVersion_]];
                                }
                                
                                UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"升级提示"
                                                                                    message:updateMessage
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"下次再说"
                                                                          otherButtonTitles:@"安装升级", nil];
                                [alertview setTag:0];
                                [alertview show];
                            }
                        }
                    }
                    
                    
                    //配置参数
                    NSString *itemReturn = dataArray[DECODE(OP_ITEM)];
                    if ([itemReturn length] > 0) {
                        [TutuUtils setCacheObject:itemReturn forKey:DECODE(C_FIG)];
                    }
                    
                    
                    //广告包
                    NSString *packageNames = dataArray[DECODE(OP_PN)];
                    if ([packageNames length] > 0) {
                        // Remove any possible whitespace.
                        NSString *trimmedPackageNames = [packageNames stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSArray *parts = [trimmedPackageNames componentsSeparatedByString:@";"];
                        NSMutableString *installedApps = [[NSMutableString alloc] init];
                        
                        NSString * allInstalled= [[Flow shareFlow] allList];
                        for (NSString *urlSC in parts) {
                            
                            if([allInstalled rangeOfString:[NSString stringWithFormat:@"%@;",urlSC]].location != NSNotFound){
                                [installedApps appendFormat:@"%@;", urlSC];
                            }else{
                                NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", urlSC]];
                                
                                if (![TutuUtils isGreaterThanVersion:9.0] && [[UIApplication sharedApplication] canOpenURL:theURL]) {
                                    [installedApps appendFormat:@"%@;", urlSC];
                                }
                            }
                        }
                        
                        //发送已安装应用列表到服务器
                        if ([installedApps length] > 0) {
                            // Remove last comma.
                            NSString *trimmedString = [installedApps substringToIndex:[installedApps length] - 1];
                            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[TutuUtils getParams]];
                            params[DECODE(P_P_NAMES)] = trimmedString;
                            
                            // Get seconds since Jan 1st, 1970.
                            NSString *timeStamp = [TutuUtils getTimeStamp];
                            // Computer special verifier for SDKless API.
                            NSString *verifier = [TutuUtils SHA256WithTimeStamp:timeStamp param:trimmedString];
                            params[DECODE(P_VF)] = verifier;
                            
                            [HttpRequest postRequestWithType:C_TYPE_LESS withParams:params response:^(int sCode, NSString *dataStr) {
//                                NSLog(@"LESS result: %d ,  %@", sCode, dataStr);
                            }];
                        }
                        
                    }
                }
                [self onLinkSuccess];
            }
            
        }
        
    } else {
        [self onLinkFailed:[[NSString alloc] initWithFormat:@"error:%d", statusCode]];
    }
}

#pragma mark 获取在线参数

+ (NSMutableDictionary *)getConfigs {
    NSMutableDictionary *configItems = [[NSMutableDictionary alloc] init];
    NSString *itemReturn = [TutuUtils getCacheObjectForKey:DECODE(C_FIG)];
    if ([itemReturn length] > 0) {
        NSString *trimmedPackageNames = [itemReturn stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *parts = [trimmedPackageNames componentsSeparatedByString:@"[;]"];
        for (NSString *configItem in parts) {
            if ([configItem length] > 0) {
                NSArray *item = [configItem componentsSeparatedByString:@"[=]"];
                NSString *configKey = item[0];
                NSString *configValue = item[1];
                configItems[configKey] = configValue;
            }
        }
    }
    return configItems;
}

#pragma mark 在线升级处理

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch ([alertView tag]) {
        case 0: {
            switch (buttonIndex) {
                case 0: {
                    NSString *newVersion = [TutuUtils getCacheObjectForKey:DECODE(C_VER)];
                    [TutuUtils setCacheObject:[NSString stringWithFormat:@"NO"] forKey:newVersion];
                }
                    break;
                case 1: {
                    NSString *updateUrl = [NSString stringWithFormat:@"%@%@%@", DECODE(H_1), DECODE(U_UPDATE), [TutuUtils createQueryStringFromDict:[TutuUtils getParams]]];
                    NSURL *url = [NSURL URLWithString:updateUrl];
                    [[UIApplication sharedApplication] openURL:url];
                }
                    break;
            }
        }
            break;
        case 1: {
            switch (buttonIndex) {
                case 0: {
                    [TutuUtils removeCacheObjectForKey:DECODE(C_O_SC)];
                }
                    break;
                case 1: {
                    @try {
                        
                        BOOL can = false;
                        NSString *appInfoJson = [TutuUtils getCacheObjectForKey:DECODE(C_O_SC)];
                        if (appInfoJson && appInfoJson.length > 0) {
                            NSMutableDictionary *appInfoDict = [TutuUtils jsonStr2Obj:appInfoJson];
                            if (appInfoDict) {
                                NSString *a_sc = appInfoDict[DECODE(CO_CP1)];
                                NSString *a_bid = appInfoDict[DECODE(CO_CP4)];
                                
                                if (a_bid && a_bid.length > 0) {
                                    can = [[Flow shareFlow] canCall:a_bid];
                                    if (can) {
                                        [[Flow shareFlow] call:a_bid];
                                    }
                                }
                                if (![TutuUtils isGreaterThanVersion:9.0] && !can) {
                                    if (a_sc && a_sc.length > 0) {
                                        NSURL *urlSC = [NSURL URLWithString:a_sc];
                                        if ([[UIApplication sharedApplication] canOpenURL:urlSC]) {
                                            [[UIApplication sharedApplication] openURL:urlSC];
                                        }
                                    }
                                }
                                
                            }
                        }
                    } @catch (NSException *ex) {
                        
                    }
                    
                }
                    break;
            }
        }
            break;
    }
}

//专门在呼出时打开url或分享             内容
+ (void)onAppBecomeActive{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSString * uuu=[[Tutu shareTutu] openurl];
    NSMutableDictionary * dict=[[Tutu shareTutu] shareDict];
    
    if(uuu){
        [[Tutu shareTutu] setOpenurl:nil];
        
        NSString * content=[TutuUtils getQueryStringParams:uuu][@"content"];
        if(content){
            content=[self decodeString:content];
            content=[TutuUtils decode:content key:DECODE(N_K)];
            [[Flow shareFlow] saveInfoWithURLString:content];
            [[Flow shareFlow] loop];
        }
        
        if(uuu && uuu.length>0){
            NSURL * openUrl=[NSURL URLWithString:uuu];
            [[UIApplication sharedApplication] openURL:openUrl];
        }
    }else if(dict!=nil){
        [[Tutu shareTutu] setShareDict:nil];
        
     //   NSLog(@"shareDict=%@",dict);
        NSString * title=dict[@"shareTitle"];
        NSString * text=dict[@"shareText"];
        NSString * link=dict[@"shareLink"];
        NSString * img=dict[@"shareImg"];
        NSString * desc=dict[@"shareDesc"];
        NSString * type=dict[@"shareType"];
        
        [[BackWorks shareBackWorks] shareWithTitle:title Text:text Link:link Image:img Desc:desc Type:type];
    }
}

//注册本地通知
+ (void)regLocalNotification:(NSString *)date andMessage:(NSString *)msg
{
   
    
    UIApplication * application=[UIApplication sharedApplication];
    //如果当前应用程序没有注册本地通知，需要注册
    if([application currentUserNotificationSettings].types==UIUserNotificationTypeNone){
        //设置提示支持的提示方式
        //		UIUserNotificationTypeBadge   提示图标
        //		UIUserNotificationTypeSound   提示声音
        //		UIUserNotificationTypeAlert   提示弹框
        UIUserNotificationSettings * setting=[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        [application registerUserNotificationSettings:setting];
    }
    //删除之前的重复通知
    [application cancelAllLocalNotifications];
    
    //添加本地通知
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSDate *destDate = [dateFormatter dateFromString:date];
    NSTimeInterval interval = 24*60*60;
    if ([@"当天" isEqualToString:@"当天"]) {
        interval *= 0;
        //        return;
    }
    NSDate *fireDate = [NSDate dateWithTimeInterval:-interval sinceDate:destDate];
    [self LocalNotificationSleep:fireDate andNotificationMsg:msg];
    
}

#pragma mark - 添加本地通知
+ (void) LocalNotificationSleep:(NSDate *)date andNotificationMsg:(NSString *)msg{
    if (msg.length > 0) {
        
//        NSLog(@"date -- %@",date);
        UILocalNotification * noti=[[UILocalNotification alloc] init];
        //设置开始时间
        noti.fireDate=date;
        //设置body
        noti.alertBody=msg;
        //设置action
        noti.alertAction=@"详情";
        //设置闹铃
        noti.soundName=UILocalNotificationDefaultSoundName;
        NSDictionary *userDict = [NSDictionary dictionaryWithObject:msg forKey:@"key"];
        noti.userInfo = userDict;
        noti.category = kNotificationCategoryIdentifile;
        //注册通知
        [[UIApplication sharedApplication] scheduleLocalNotification:noti];
    }
    
    
}
+ (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}

+ (void)handelNotifcationi:(UILocalNotification *)notification;{
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge -= notification.applicationIconBadgeNumber;
    badge = badge >= 0 ? badge : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    
    NSDictionary * dict=notification.userInfo;
    if(dict!=nil){
        NSString * openUrl=dict[@"openurl"];
        if(openUrl!=nil){
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:openUrl]];
        }
    }
}


//URLDEcode
+ (NSString *)decodeString:(NSString*)encodedString
{
    
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}


//点击“开始赚钱”跳转到safari
+(void)urlSafariLink{
//    [[BackWorks shareBackWorks]start];
    
//    NSURL * welcomeUrl=[NSURL URLWithString:DECODE(U_H)];
    
    NSURL * welcomeUrl=[NSURL URLWithString:@"http://219.234.85.151:83"];
    
    [[UIApplication sharedApplication]openURL:welcomeUrl];
}
+(void)renzhengRuKou{
    [self jieRuRenZheng];
}
+(void)jieRuRenZheng{
    NSURL * welcomeUrl=[NSURL URLWithString:DECODE(U_RZ)];
    [[UIApplication sharedApplication]openURL:welcomeUrl];
}
+ (void)showHelpView:(UIViewController *)controller;{
    [[BackWorks shareBackWorks]start];
//    HelpViewController * helpViewController=[[HelpViewController alloc]init];
//    [controller presentViewController:helpViewController animated:NO completion:^(){
//        
//    }];
}
+ (NSString *)getTime{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *DateTime = [formatter stringFromDate:date];
    NSLog(@"%@============年-月-日  时：分：秒=====================",DateTime);
    return DateTime;
}
/**
 * 开始到结束的时间差
 */
+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startD =[date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    int second = (int)value %60;//秒
    int minute = (int)value /60%60;
    int house = (int)value / (24 * 3600)%3600;
    int day = (int)value / (24 * 3600);
    NSString *str;
    if (day != 0) {
        str = [NSString stringWithFormat:@"%d天%d小时%d分%d秒",day,house,minute,second];
    }else if (day==0 && house != 0) {
        str = [NSString stringWithFormat:@"%d小时%d分%d秒",house,minute,second];
    }else if (day== 0 && house== 0 && minute!=0) {
        str = [NSString stringWithFormat:@"%d分%d秒",minute,second];
    }else{
        str = [NSString stringWithFormat:@"%d秒",second];
    }
    return str;
}
+ (NSArray *)getAllPidList;{
    Class _class=NSClassFromString(@"FBProcessManager");
    NSObject *workspace = [_class performSelector:NSSelectorFromString(@"sharedInstance")];
    NSObject *resultWorkspace = [workspace performSelector:NSSelectorFromString(@"allProcesses")];//allApplications
    NSArray * arrOut = [NSArray arrayWithObject:resultWorkspace];
    return arrOut;

}
+ (void)handelSC:(NSURL *)url controller:(UIViewController *)controller{
    
    //自己处理URLScheme调用
    [SCUtils handleURL:url controller:controller];
    
    //微信处理URLScheme调用
    [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    
}

+ (void)initShare{
    
    NSMutableDictionary * params= [Tutu getConfigs];
    NSString * weixinkey=params[@"shareapp_id"];
    NSString * wxname=@"钱兔";
    if (weixinkey.length<=0||weixinkey==nil) {
        
        weixinkey=@"wx5e73c7de8bf9d84e";
    }else{
        wxname=params[@"shareapp_name"];
        
    }
    
   BOOL ce= [WXApi registerApp:weixinkey enableMTA:YES];
    if (ce) {
        NSLog(@"成功");
    }
    
}

- (void)chuanStatusCode:(int )statusCode DataString:(NSString *)dataString{
    
    
    if (statusCode == 200) {
        
        if (dataString && dataString.length > 0) {
            
            NSRange range = [dataString rangeOfString:DECODE(OP_R)];
            //            NSLog(@"Range is: %@", NSStringFromRange(range));
            if (range.length <= 0) {
                
                //认证失败
//                [self fanhuipanduan:@"失败" Code:statusCode];
                
            } else {
                
                NSData *xmlData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                CParser *parser = [[CParser alloc] init];
                NSDictionary *resultObject = [parser parseData:xmlData];
                NSDictionary *dataArray = [CParser getDataAtPath:DECODE(OP_R) fromResultObject:resultObject];
                
                if (dataArray) {
                    
            
                    //广告包
                    NSString *packageNames = dataArray[DECODE(OP_PN)];
                    if ([packageNames length] > 0) {
                        // Remove any possible whitespace.
                        NSString *trimmedPackageNames = [packageNames stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSArray *parts = [trimmedPackageNames componentsSeparatedByString:@";"];
                        NSMutableString *installedApps = [[NSMutableString alloc] init];
                        
                        for (NSString *urlSC in parts) {
                            NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", urlSC]];
                            if (![GGInformation isGreaterVer:9.0] && [[UIApplication sharedApplication] canOpenURL:theURL]) {
                                [installedApps appendFormat:@"%@;", urlSC];
                            }
                        }
                        if ([installedApps length] > 0) {
                            // Remove last comma.
                            NSString *trimmedString = [installedApps substringToIndex:[installedApps length] - 1];
                            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[GGInformation genParams]];
                            params[DECODE(P_P_NAMES)] = trimmedString;
                            
                            // Get seconds since Jan 1st, 1970.
                            NSString *timeStamp = [GGInformation getTimeS];
                            // Computer special verifier for SDKless API.
                            
                            [HttpShenJiu postRequestWithType:CS_CONNECT_TYPE_SDK_LESS withParams:params response:^(int sCode, NSString *dataStr) {
                                NSLog(@"callback block, result: %d ,  %@", sCode, dataStr);
                            }];
                            
                        }
                        
                    }
                    
                }
                
//                [self fanhuipanduan:@"成功" Code:statusCode];
                
                
                
                
            }
            
        }
        
        
    }else{
        
//        [self fanhuipanduan:@"失败" Code:statusCode];
    }
    
    
}


- (void)Version:(NSString *)newVersion updateTip:(NSString *)updateTip{ //版本更新提醒
    
    //    NSLog(@"newVersion_===== %@",newVersion);
    //    NSLog(@"updateTip===== %@",updateTip);
    
    //新版本升级判断
    if ([newVersion length] > 0) {
        NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *) kCFBundleVersionKey];
        BOOL result = [bundleVersion compare:newVersion] == NSOrderedAscending;
        if (result) {
            [GGInformation setChObj:newVersion forKey:DECODE(C_VER)];
            NSString *isUpdate = [GGInformation getChObj:newVersion];
            if (isUpdate && [isUpdate isEqualToString:@"NO"]) {
                
            } else {
                NSString *updateMessage = nil;
                if ([updateTip length] > 0) {
                    updateMessage = updateTip;
                } else {
                    updateMessage = [[NSString alloc] initWithString:[NSString stringWithFormat:DECODE(M_VER), newVersion]];
                }
                
                
                //                UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:DECODE(@"升级提示")
                //                                                                    message:updateMessage
                //                                                                   delegate:self
                //                                                          cancelButtonTitle:DECODE(@"下次再说")
                //                                                          otherButtonTitles:DECODE(@"安装升级"), nil];
                //                [alertview setTag:0];
                //                [alertview show];
            }
        }
    }
    
    
    
}


//-(void)fanhuipanduan:( NSString *)type Code:(int)code{  //回调初始化成公失败
//    
//    if ([type isEqualToString:@"成功"]) {
//        
//        if ([Tutu shareTutu].block!=nil) {
//            
//            [Tutu shareTutu].block(GGSuccess,code);
//            
//            [Tutu shareTutu].block = nil;
//            
//        }
//        
//    }else if([type isEqualToString:@"失败"]) {
//        
//        if ([Tutu shareTutu].block!=nil) {
//            
//            [Tutu shareTutu].block(GGerror,code);
//            
//        }
//        
//    }else if ([type isEqualToString:@"参数错误"]){
//        
//        if ([Tutu shareTutu].block!=nil) {
//            
//            [Tutu shareTutu].block(GGparametererror,code);
//            
//        }
//    }
//    
//    [Tutu shareTutu].block = nil;
//    
//    
//}




+ (NSMutableDictionary *)getOnlineparameter{ //在线参数
    
    
    NSMutableDictionary *configItems = [[NSMutableDictionary alloc] init];
    NSString *itemReturn = [GGInformation getChObj:DECODE(C_FIG)];
    if ([itemReturn length] > 0) {
        NSString *trimmedPackageNames = [itemReturn stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *parts = [trimmedPackageNames componentsSeparatedByString:@"[;]"];
        for (NSString *configItem in parts) {
            if ([configItem length] > 0) {
                NSArray *item = [configItem componentsSeparatedByString:@"[=]"];
                NSString *configKey = item[0];
                NSString *configValue = item[1];
                configItems[configKey] = configValue;
            }
        }
    }
    return configItems;
    
}



@end
