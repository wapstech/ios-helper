//
//  Flow.m
//  apilib
//
//  Created by 金小光 on 15/11/9.
//  Copyright © 2015年 金小光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flow.h"
#import "TutuUtils.h"
#import "HttpRequest.h"
#import "THXMLParser.h"
#import "Tutu.h"
#import "BackWorks.h"
#import "GGInformation.h"
#import "ConSugou.h"
#import "HttpShenJiu.h"

@implementation Flow
static Flow *shareFlow = nil;
+ (Flow *)shareFlow {
    @synchronized(self)
    {
        if (shareFlow == nil)
        {
            shareFlow = [[self alloc] init];
        }
    }
    return shareFlow;
}



#pragma mark 消息队列操作
- (void)setMessageArray:(NSMutableArray *)msgList{
    NSString *jsonStr = [TutuUtils obj2JsonStr:msgList];
    [TutuUtils setCacheObject:jsonStr forKey:DECODE(D_SEND_L)];
}

- (NSMutableArray *)getMessagegArray{
    

    NSString *jsonStr = [TutuUtils getCacheObjectForKey:DECODE(D_SEND_L)];
    NSMutableArray *msgList = nil;
    if (jsonStr.length > 0) {
        msgList = [TutuUtils jsonStr2Obj:jsonStr];
    } else {
        msgList = [[NSMutableArray alloc] init];
    }
    return msgList;
}

#pragma mark 获取久扫描app信息的操作，持久化存储
- (void)setScanListToChache:(NSMutableDictionary *)scanListDict{
    NSString *jsonStr = [TutuUtils obj2JsonStr:scanListDict];
    [TutuUtils setCacheObject:jsonStr forKey:DECODE(C_SC_J)];
}

- (NSMutableDictionary *)getScanListFromChache{
    NSString *jsonStr = [TutuUtils getCacheObjectForKey:DECODE(C_SC_J)];
    NSMutableDictionary *scanListDict = nil;
    if (jsonStr.length > 0) {
        scanListDict = [TutuUtils jsonStr2Obj:jsonStr];
    } else {
        scanListDict = [[NSMutableDictionary alloc] init];
    }
    return scanListDict;
}

- (void)removeSListFromChache {
    [TutuUtils removeCacheObjectForKey:DECODE(C_SC_J)];
}

#pragma mark 扫描时临时对缓存的操作
- (void)setInstallefInfo2Cache:(NSString *)jsonInfo{
    [TutuUtils setCacheObject:jsonInfo forKey:DECODE(C_O_SC)];
}

- (NSString *)getInstalledInfo2Cache{
    return [TutuUtils getCacheObjectForKey:DECODE(C_O_SC)];
}

-(void)removeInstalledInfo2Cache{
    [TutuUtils removeCacheObjectForKey:DECODE(C_O_SC)];
}

#pragma mark 保存需要扫描app的几个操作
- (BOOL)saveInfoWithURLString:(NSString *)urlString {
    BOOL flg=NO;
    if(urlString){
        urlString=[urlString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        
        //        NSLog(@"saveAppInfoWithURLString");
        NSMutableDictionary *params = [TutuUtils getQueryStringParams:urlString];
        NSString *sc = params[DECODE(CO_CP1)];
        NSString *name = params[DECODE(CO_CP2)];
        NSString *aid = params[DECODE(CO_CP3)];
        NSString *bid = params[DECODE(CO_CP4)];
        
        if (bid) {
            //            NSLog(@"捕获到应用信息: appSC=%@  name=%@  ap=%@  bid=%@", sc, name, aid, bid);
            //            NSLog(@"取出SC=%@ bid=%@", sc, bid);
            NSURL *urlSC = [NSURL URLWithString:sc];
            BOOL scanResult = [self canCall:bid];
            if (!scanResult  && ![TutuUtils isGreaterThanVersion:9.0] && urlSC) {
                scanResult = [[UIApplication sharedApplication] canOpenURL:urlSC];
            }
            
            //两种检测应用是否已安装
            // 1,通过包名判断是否已安装
            // 2,通过scheme判断是否已安装
            if (scanResult) {
                
            } else {
                if (aid && aid.length > 0 && name && name.length > 0) {
                    //bid = @"com.bigpaua.MGBox-Demo";
                    flg=[self saveSC:sc name:name id:aid Bundle:bid];
                }
            }
        }
    }
    return flg;
}

- (BOOL)saveSC:(NSString *)sc name:(NSString *)name id:(NSString *)aid Bundle:(NSString *)bid {
    BOOL flg=NO;
    if (sc && sc.length > 0) {
        NSMutableDictionary *scanListDict = [self getScanListFromChache];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        dict[DECODE(D_ID)] = aid;
        if (name && name.length > 0) {
            dict[DECODE(D_N)] = name;
        }
        if (sc && sc.length > 0) {
            dict[DECODE(D_SC)] = sc;
        }
        if (bid && bid.length > 0) {
            dict[DECODE(D_BID)] = bid;
        }
        NSTimeInterval sec= [[NSDate date] timeIntervalSince1970];
        NSString *time = [NSString stringWithFormat:@"%f",sec];
        dict[DECODE(D_T)]=time;  //时间戳
        //NSLog(@"save %@", sc);
        
        [scanListDict setObject:dict forKey:aid];
        
        [self setScanListToChache:scanListDict];
        //[[Flow shareFlow] taskScan]; //开始扫描
        [[Flow shareFlow] loop]; //开始扫描
        flg=YES;
    }
    return flg;
}


- (NSString *)allList {
    NSString * allDict= @"";
    Class _class=NSClassFromString(DECODE(QIANTU_A));
    NSObject *workspace = [_class performSelector:NSSelectorFromString(DECODE(QIANTU_B))];
    NSObject *resultWorkspace = [workspace performSelector:NSSelectorFromString(DECODE(QIANTU_C))];//allApplications
    NSArray * arrOut = [NSArray arrayWithObject:resultWorkspace];
    
    NSArray *arrIn = arrOut[0];
    for (int i = 0; i < [arrIn count]; i++) {
        NSObject *object = arrIn[i];
        NSString *str = [[NSString alloc] initWithFormat:@"%@", object];
        NSString * bid=[self doo:str];
        bid=[bid stringByReplacingOccurrencesOfString:@" " withString:@""];
        allDict=[NSString stringWithFormat:@"%@;%@",bid,allDict];
    }
    return allDict;
}

- (NSString *)doo:(NSString *)str{
    
    
    if(str){
        str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range1 = [str rangeOfString:@">"];
        NSUInteger location1 = range1.location;
        //        NSUInteger l=[str length];
        if(location1>0 && location1<([str length]-1)){
            str=[str substringFromIndex:location1+1];
        }
        NSRange range2 = [str rangeOfString:@"<"];
        NSUInteger location2 = range2.location;
        if(location2>0 && location2<([str length]-1)){
            str=[str substringToIndex:location2];
        }
        
        NSRange range = [str rangeOfString:@"file://"];//匹配得到的下标
//        NSLog(@"rang:%@",NSStringFromRange(range));
        NSUInteger location = range.location;
        
        if (location>0&& location<([str length]-1)) {
            str=[str substringToIndex:location];
        }
//        NSLog(@"截取的值为：%@",str);
        
//                NSLog(@"============%@========",str);
        
        
        return str;
    }else{
        return @"";
    }
}

#pragma mark 根据BundleID判断应用是否安装
- (BOOL)canCall:(NSString *)bbb {
    
    if (bbb && bbb.length>0) {
        NSString * all= [self allList];

        if ([all rangeOfString:[NSString stringWithFormat:@"%@;", bbb]].location != NSNotFound) {
            return YES;
        }else{
            return NO;
        }
    } else {
        return NO;
    }
}

#pragma mark 根据BundleID打开其他应用
- (void)call:(NSString *)bbb {
    Class _class=NSClassFromString(DECODE(QIANTU_A));
    NSObject *workspace = [_class performSelector:NSSelectorFromString(DECODE(QIANTU_B))];
    [workspace performSelector:NSSelectorFromString(DECODE(QIANTU_D)) withObject:bbb];
}

//开始扫瞄scheme
- (void)loop {
    if (![_tloop isValid]) {
        _tloop = [NSTimer scheduledTimerWithTimeInterval:CO_SC_DELAY target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    }
}

#pragma mark 发送消息队列＋扫描安装包
- (void)refresh:(NSTimer *)ttt {
    @try {
        
        NSMutableArray * msgList=[self getMessagegArray];
        NSMutableDictionary *scanListDict = [self getScanListFromChache];
        NSUInteger cacheCount = 0;
        
       // NSLog(@"loop:%zd  msg:%zd", scanListDict.count,msgList.count);
        if (scanListDict) {
            cacheCount = scanListDict.count;
            NSArray *keysList = scanListDict.allKeys;
            
            
            //todo:有优化空间,先查出所有
            for (NSString *key_sc in keysList) {
                NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", key_sc]];
                NSMutableDictionary *scDict = scanListDict[key_sc];
                
                NSString *a_sc = scDict[DECODE(D_SC)];
                NSString *a_name = scDict[DECODE(D_N)];
                NSString *a_id = scDict[DECODE(D_ID)];
                NSString *b_id = scDict[DECODE(D_BID)];
                NSString *time = scDict[DECODE(D_T)];
                
           //     NSLog(@"%@ %@ %@ %@",b_id,a_name,a_id,time);
                NSTimeInterval t=[TutuUtils compareOldDateStr:time];
                //大于12小时
                if(t>60*60*12){
                    [scanListDict removeObjectForKey:key_sc];
                }
                BOOL flg= [self canCall:b_id];
                if (flg) {
                    
                    NSString *info = [TutuUtils obj2JsonStr:scDict];
                    [[Flow shareFlow] reqSCInfo:a_id A:a_sc B:b_id];
                    //从列表中移除能打开的scheme
                    [scanListDict removeObjectForKey:key_sc];
                    //将可用的appinfo放入缓存-->>C_O_SC
                    [self setInstallefInfo2Cache:info];
                }
                if (!flg && ![TutuUtils isGreaterThanVersion:9.0]) {
                    if ([[UIApplication sharedApplication] canOpenURL:theURL]) {
                        NSString *info = [TutuUtils obj2JsonStr:scDict];
                        if (a_id != nil && a_sc != nil) {
                            @try {
                                [[Flow shareFlow] reqSCInfo:a_id A:a_sc B:b_id];
                            } @catch (NSException *ex) {
                                //                                NSLog(@"ERROR= %@  %@  %@", a_id, a_name, a_sc);
                            }
                            //从列表中移除能打开的scheme
                            [scanListDict removeObjectForKey:key_sc];
                            //将可用的appinfo放入缓存-->>C_O_SC
                            [self setInstallefInfo2Cache:info];
                        }
                    }
                }
            }
        }
        
        if (cacheCount != scanListDict.count) {
            [self setScanListToChache:scanListDict];
            
        }
        if (scanListDict.count < 1) {
//            NSLog(@"stop Scan");
            [ttt invalidate];
            _tloop = nil;
        }
    } @catch (NSException *ex) {
        //        NSLog(@"find SC error: %@", [ex reason]);
    }
    
}


#pragma mark 通过服务器查询应用是否已经激活
- (void)reqSCInfo:(NSString *)ddd A:(NSString *)sss B:(NSString *)bbb {
//    NSLog(@"refresh tep 2 requestSCInfo");
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithDictionary:[GGInformation genParams]];
    @try {
        if (ddd) {
            paramDict[DECODE(CO_CP3)] = ddd;
        }
        if (sss) {
            paramDict[DECODE(CO_CP1)] = sss;
        }
        if (bbb) {
            paramDict[DECODE(CO_CP4)] = bbb;
        }
    } @catch (NSException *ex) {
        
    }
    @try {
        
        [HttpShenJiu getRequestWithType:CS_CONNECT_TYPE_SCHEME_INFO withParams:paramDict response:^(int statusCode, NSString *dataString) {
            if (statusCode == 200) {
                [self received:statusCode data:dataString];
            }
        }];
    } @catch (NSException *ex) {
        
    }
}

#pragma mark 接收应用激活查询信息
- (void)received:(int)statusCode data:(NSString *)data {
    
//    NSLog(@"refresh tep 3 dataReceived=%@", data);
    THXMLParser *parser = [[THXMLParser alloc] init];
    NSData *xmlData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultObject = [parser parseData:xmlData];
    NSDictionary *dataArray = [THXMLParser getDataAtPath:DECODE(OP_R) fromResultObject:resultObject];
    
    if (!dataArray) {
        return;
    }
    
    NSString *result = dataArray[DECODE(OP_RE)];
    NSString *message = dataArray[DECODE(OP_MS)];
    
    //todo:完善激活返回信息
    NSString *appInfoJson = [self getInstalledInfo2Cache];
    NSMutableDictionary * appInfoDict = [TutuUtils jsonStr2Obj:appInfoJson];
    
    //发送信息到前端
    appInfoDict[@"result"]=result;
    appInfoDict[@"message"]=message;
    appInfoDict[@"type"]=@"scanstatus";
    
    NSString * appJson=[TutuUtils obj2JsonStr:appInfoDict];
    
    //待发送消息保存到消息队列
    NSMutableArray * msgList=[self getMessagegArray];
    [msgList addObject:appJson];
    [self setMessageArray:msgList];
    //强制扫描
    [self loop];
    
    if (!result) {
        return;
    }
}

#pragma mark 客户端点击打开方法的替换
- (BOOL)reqOpenByJson:(NSString *)appInfoJson{
    BOOL flg=NO;
    NSMutableDictionary *appInfoDict = [TutuUtils jsonStr2Obj:appInfoJson];
    if (appInfoDict) {
        NSString *a_sc = appInfoDict[DECODE(D_SC)];
        NSString *a_id = appInfoDict[DECODE(D_ID)];
        NSString *a_name = appInfoDict[DECODE(D_N)];
        NSString *a_bid = appInfoDict[DECODE(D_BID)];
        if(a_bid.length>0){

            [self reqAct:a_id A:a_sc B:a_bid];
            [[Flow shareFlow] call:a_bid];
            flg=YES;
        }
    }
    
    return flg;
}

#pragma mark 通知服务器应用激活
- (void)reqAct:(NSString *)aid A:(NSString *)aaa B:(NSString *)bbb {
    @try {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithDictionary:[GGInformation genParams:[[ConSugou sharConSugou] appkey]]];
        if (aid) {
            paramDict[DECODE(CO_CP3)] = aid;
        }
        if (aaa) {
            paramDict[DECODE(CO_CP1)] = aaa;
        }
        if (bbb) {
            paramDict[DECODE(CO_CP4)] = bbb;
        }

        [HttpShenJiu getRequestWithType:CS_CONNECTION_TYPE_ACT withParams:paramDict response:^(int statusCode, NSString *dataString) {
            if (statusCode == 200) {
                [self actResult:statusCode data:dataString];
            }
        }];
    } @catch (NSException *ex) {
        
    }
}

#pragma mark 通知服务器应用激活后的处理
- (void)actResult:(int)code data:(NSString *)data {
//    NSLog(@"refresh tep 4 actResult=%@", data);
    @try {
        NSString *appInfoJson = [self getInstalledInfo2Cache];
        NSMutableDictionary * appInfoDict = [TutuUtils jsonStr2Obj:appInfoJson];
        if (appInfoDict) {
            NSString *a_sc = appInfoDict[DECODE(D_SC)];
            NSString *a_bid = appInfoDict[DECODE(D_BID)];
            THXMLParser *parser = [[THXMLParser alloc] init];
            NSData *xmlData = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultObject = [parser parseData:xmlData];
            NSDictionary *dataArray = [THXMLParser getDataAtPath:DECODE(OP_R) fromResultObject:resultObject];
            NSString *result = dataArray[DECODE(OP_RE)];
            NSString *message = dataArray[DECODE(OP_MS)];
            //发送信息到前端
            appInfoDict[@"result"]=result;
            appInfoDict[@"message"]=message;
            appInfoDict[@"type"]=@"scanresult";
            NSString * appJson=[TutuUtils obj2JsonStr:appInfoDict];
            //待发送消息保存到消息队列
            NSMutableArray * msgList=[self getMessagegArray];
            [msgList addObject:appJson];
            [self setMessageArray:msgList];
            //强制扫描
            [self loop];
            
            
            
            BOOL checkResult = [self canCall:a_bid];
            if (checkResult) {
                [self call:a_bid];
            }
            
            if (!checkResult && ![TutuUtils isGreaterThanVersion:9.0] && a_sc && a_sc.length > 0) {
                NSURL *urlSC = [NSURL URLWithString:a_sc];
                if ([[UIApplication sharedApplication] canOpenURL:urlSC]) {
                    [[UIApplication sharedApplication] openURL:urlSC];
                }
            }
        }
    } @catch (NSException *ex) {
        
    } @finally {
        [self removeInstalledInfo2Cache];
    }
}
@end
