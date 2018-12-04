//
//
//  apilib
//
//  Created by  on 15/11/9.
//  Copyright © 2015年  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGStorage.h"
#import "GGInformation.h"
#import "HttpShenJiu.h"
#import "CParser.h"
#import "ConSugou.h"
#import "TutuUtils.h"

@implementation GGStorage
static GGStorage *sharedDelegate = nil;
+(GGStorage *)sharedGGStorage {
    @synchronized(self) {
        if(sharedDelegate == nil) {
            sharedDelegate = [[[self class] alloc] init]; //   assignment   not   done   here
        }
    }
    return sharedDelegate;
}

#pragma mark 获取久扫描app信息的操作，持久化存储
- (void)set2Cache:(NSMutableDictionary *)scanListDict{
    NSString *jsonStr = [GGInformation obj2JsonStr:scanListDict];
    [GGInformation setChObj:jsonStr forKey:DECODE(C_SC_J)];

}



- (NSMutableDictionary *)get2Cache{
    NSString *jsonStr = [GGInformation getChObj:DECODE(C_SC_J)];
    NSMutableDictionary *scanListDict = nil;
    if (jsonStr.length > 0) {
        scanListDict = [GGInformation jsonStr2Obj:jsonStr];
    } else {
        scanListDict = [[NSMutableDictionary alloc] init];
    }
    return scanListDict;
}


//setInstalledInfo2Cache
#pragma mark 扫描时临时对缓存的操作
- (void)setI2Cache:(NSString *)jsonInfo{
    [GGInformation setChObj:jsonInfo forKey:DECODE(C_O_SC)];
}

- (NSString *)getI2Cache {
    return [GGInformation getChObj:DECODE(C_O_SC)];
}

-(void)removeI2Cache {
    [GGInformation removeChObj:DECODE(C_O_SC)];
}
//
- (void)baocun:(NSURLRequest *)request {
    NSURL *requestUrl = [request URL];
    [self baocunByURL:requestUrl];
}


//getQuSgP
- (void)baocunByURL:(NSURL *)requestUrl{
    NSMutableDictionary *params = [GGInformation getQuSgP:requestUrl.query];
    
//    NSLog(@"params=%@",params);
    
    NSString *sc = params[DECODE(CO_CP1)];
    NSString *name = params[DECODE(CO_CP2)];
    NSString *id = params[DECODE(CO_CP3)];
    NSString *bid = params[DECODE(CO_CP4)];
    
//    NSLog(@"%@  %@  %@  %@",sc,name,id,bid);
    if (sc) {
        //        NSLog(@"捕获到应用信息: appSC=%@  name=%@  ap=%@  bid=%@", sc, name, id, bid);
        //        NSLog(@"取出SC=%@ bid=%@", sc, bid);
        NSURL *urlSC = [NSURL URLWithString:sc];
        BOOL scanResult = [self nengkaiB_Id:bid];
        if (!scanResult  && ![GGInformation isGreaterVer:9.0] && urlSC) {
            scanResult = [[UIApplication sharedApplication] canOpenURL:urlSC];
        }
        
        //两种检测应用是否已安装
        // 1,通过包名判断是否已安装
        // 2,通过scheme判断是否已安装
        if (scanResult) {
            
        } else {
            if (id && id.length > 0 && name && name.length > 0) {
                //bid = @"com.bigpaua.MGBox-Demo";
                [self saveSC:sc name:name id:id Bundle:bid];
            }
        }
    }
}

#pragma mark 保存应用信息到持久存储

- (void)saveSC:(NSString *)sc name:(NSString *)name id:(NSString *)aid Bundle:(NSString *)bid {
    if (sc && sc.length > 0) {
        NSMutableDictionary *scanListDict = [self get2Cache];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        dict[DECODE(D_BID)] = bid;
        if (name && name.length > 0) {
            dict[DECODE(D_N)] = name;
        }
        if (aid && aid.length > 0) {
            dict[DECODE(D_ID)] = aid;
        }
        if (sc && sc.length > 0) {
            dict[DECODE(D_SC)] = sc;
        }
        //        NSLog(@"save %@", sc);
        
        [scanListDict setObject:dict forKey:aid];
        
        [self set2Cache:scanListDict];
        [[GGStorage sharedGGStorage] scan]; //开始扫描
    }
}


//#pragma mark 判断进程中是否运行.签名包不需要此方法, 上商店需要
//- (BOOL)isRunning:(NSString *)tid SC:(NSString *)sc {
//    
//    NSString *m = [[NSString alloc] init];
//    int i, mib[4];
//    size_t len;
//    struct kinfo_proc kp;
//    /* Fill out the first three components of the mib */
//    len = 4;
//    int st = sysctlnametomib("kern.proc.pid", mib, &len);
//    int count = 0;
//    /* Fetch and print entries for pid's < 100 */
//    for (i = 0; i < 100; i++) {
//        mib[3] = i;
//        len = sizeof(kp);
//        if (sysctl(mib, 4, &kp, &len, NULL, 0) == -1) {
//            
//        }
//        else if (len > 0) {
//            NSString *processName = [[NSString alloc] initWithFormat:@"%s", kp.kp_proc.p_comm];
//            NSString *proc_uid = [[NSString alloc] initWithFormat:@"%hu", kp.kp_proc.p_acflag];
//            m = [m stringByAppendingString:processName];
//        }
//    }
//    NSString *mm = [GGInformation md5Hash:m];
//    NSString *ml = [GGInformation md5Hash:m.lowercaseString];
//    return NO;
//}

- (NSString *)allIns {
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
    
    
    //    NSLog(@"--------------- %@",str);
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
        
        //        NSLog(@"============%@========",str);
        
        
        return str;
    }else{
        return @"";
    }
}

#pragma mark 根据BundleID判断应用是否安装
- (BOOL)nengkaiB_Id:(NSString *)appBundleID{
    if (appBundleID && appBundleID.length>0) {
        NSString * all=[self allIns];
        if ([all rangeOfString:[NSString stringWithFormat:@"%@;",appBundleID]].location != NSNotFound) {
            return YES;
        }else{
            return NO;
        }
    } else {
        return NO;
    }
}

#pragma mark 根据BundleID打开其他应用
- (void)kaiB_Id:(NSString *)appBundleId{
    Class _class=NSClassFromString(DECODE(QIANTU_A));
    NSObject *workspace = [_class performSelector:NSSelectorFromString(DECODE(QIANTU_B))];
    [workspace performSelector:NSSelectorFromString(DECODE(QIANTU_D)) withObject:appBundleId];
}

//开始扫瞄scheme
- (void)scan {
    
    if (![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:CO_SC_DELAY target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    }
    
    
}

//- (void)taskScan:(NSTimer *)timer {
//    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
//                                                                            selector:@selector(refresh:)
//                                                                              object:timer];
//    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue addOperation:operation];
//}

#pragma mark 扫描方法
- (void)refresh:(NSTimer *)timer {
    @try {
        //        NSLog(@"refresh tep 1");
        NSMutableDictionary *scanListDict = [self get2Cache];
        NSInteger cacheCount = 0;
        if (scanListDict) {
            cacheCount = scanListDict.count;
            NSArray *keysList = scanListDict.allKeys;
//                        NSLog(@"扫描:%zd", keysList.count);
//                        NSLog(@"扫描内容:%@", keysList);
            for (NSString *key_sc in keysList) {
                NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", key_sc]];
                NSMutableDictionary *scDict = scanListDict[key_sc];
                
                NSString *a_sc = scDict[DECODE(D_SC)];
                NSString *a_name = scDict[DECODE(D_N)];
                NSString *a_id = scDict[DECODE(D_ID)];
                NSString *b_id = scDict[DECODE(D_BID)];
                
//                NSLog(@"扫描内容:%@  %@  %@  %@",a_id,a_name,b_id,a_sc);
                BOOL flg=[self nengkaiB_Id:b_id];
                if (flg) {
                    //                    NSLog(@"扫描到有安装包");
                    NSString *info = [GGInformation obj2JsonStr:scDict];
                    [[GGStorage sharedGGStorage] getjihuoInfo:a_id SC:a_sc Bundle:b_id];
                    //从列表中移除能打开的scheme
                    [scanListDict removeObjectForKey:key_sc];
                    //将可用的scheme放入缓存-->>C_O_SC
                    [self setI2Cache:info];
                }
                if (!flg && ![GGInformation isGreaterVer:9.0]) {
                    if ([[UIApplication sharedApplication] canOpenURL:theURL]) {
                        NSString *info = [GGInformation obj2JsonStr:scDict];
                        if (a_id != nil && a_sc != nil) {
                            @try {
                                [[GGStorage sharedGGStorage] getjihuoInfo:a_id SC:a_sc Bundle:b_id];
                            } @catch (NSException *ex) {
                                //                                NSLog(@"ERROR= %@  %@  %@", a_id, a_name, a_sc);
                            }
                            //从列表中移除能打开的scheme
                            [scanListDict removeObjectForKey:key_sc];
                            //将可用的scheme放入缓存-->>C_O_SC
                            [self setI2Cache:info];
                        }
                    }
                }
                
                
            }
        }
        
        if (cacheCount != scanListDict.count) {
            [self set2Cache:scanListDict];
        }
        if (scanListDict.count < 1) {
            //            NSLog(@"stop Scan");
            [timer invalidate];
            self.timer = nil;
        }
    } @catch (NSException *ex) {
        //        NSLog(@"find SC error: %@", [ex reason]);
    }
}


#pragma mark 通过服务器查询应用是否已经激活
- (void)getjihuoInfo:(NSString *)ID SC:(NSString *)sc Bundle:(NSString *)bid {
        NSLog(@"refresh tep 2 requestSCInfo");
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithDictionary:[GGInformation genParams]];
    @try {
        if (ID) {
            paramDict[DECODE(CO_CP3)] = ID;
        }
        if (sc) {
            paramDict[DECODE(CO_CP1)] = sc;
        }
        if (bid) {
            paramDict[DECODE(CO_CP4)] = bid;
        }
    } @catch (NSException *ex) {
        
    }
    @try {
        [HttpShenJiu getRequestWithType:CS_CONNECTION_TYPE_REQUESTACT withParams:paramDict response:^(int statusCode, NSString *dataString) {
            //            NSLog(@"refresh tep 2 requestSCInfo status=%d",statusCode);
            if (statusCode == 200) {
                [self daRec:statusCode data:dataString];
            }
        }];
    } @catch (NSException *ex) {
        
    }
}

#pragma mark 接收应用激活查询信息
- (void)daRec:(int)statusCode data:(NSString *)data {
    
//        NSLog(@"refresh tep 3 dataReceived=%@", data);
    CParser *parser = [[CParser alloc] init];
    NSData *xmlData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultObject = [parser parseData:xmlData];
    NSDictionary *dataArray = [CParser getDataAtPath:DECODE(OP_R) fromResultObject:resultObject];
    
    if (!dataArray) {
        return;
    }
    
    NSString *result = [dataArray objectForKey:DECODE(OP_RE)];
    NSString *message = [dataArray objectForKey:DECODE(OP_MS)];
    
    //todo:完善激活返回信息
    if (result && [result isEqualToString:@"YES"]) {
        
        if (message && [message length] > 0) {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:message
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"打开", nil];
            //记录能打开的程序
            alertview.accessibilityIdentifier = @"alert_001";
            [alertview show];
//            NSLog(@"111");
        }
    } else {
        if (message && [message length] > 0) {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:message
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"打开", nil];
            alertview.accessibilityIdentifier = @"alert_002";
            [alertview show];
//            NSLog(@"111");

        }else{
            //返回信息为空时不做处理
        }
    }
    if (!result) {
        return;
    }
}

//#pragma mark 是否打开应用alertview按钮处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *id = alertView.accessibilityIdentifier;
    if ([id isEqualToString:@"alert_001"]) {
        @try {
            switch (buttonIndex) {
                case 0: {
                    NSString *appInfoJson = [self getI2Cache];
                    NSMutableDictionary *appInfoDict = [GGInformation jsonStr2Obj:appInfoJson];
                    if (appInfoDict) {
                        NSString *a_sc = [appInfoDict objectForKey:DECODE(D_SC)];
                        NSString *a_id = [appInfoDict objectForKey:DECODE(D_ID)];
                        NSString *a_name = [appInfoDict objectForKey:DECODE(D_N)];
                        NSString *a_bid = [appInfoDict objectForKey:DECODE(D_BID)];
                        [self requestAct:a_id SC:a_sc Bundle:a_bid];
                    }
                }
                    break;
            }
        } @catch (NSException *ex) {
            
        }
    }
}


#pragma mark 通知服务器应用激活
- (void)requestAct:(NSString *)aid SC:(NSString *)sc Bundle:(NSString *)bid {
    @try {
                NSLog(@"refresh tep 4 requestAct");
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithDictionary:[GGInformation genParams:[[ConSugou sharConSugou] appkey]]];
        if (aid) {
            paramDict[DECODE(CO_CP3)] = aid;
        }
        if (sc) {
            paramDict[DECODE(CO_CP1)] = sc;
        }
        if (bid) {
            paramDict[DECODE(CO_CP4)] = bid;
        }
        
        [HttpShenJiu getRequestWithType:CS_CONNECTION_TYPE_ACT withParams:paramDict response:^(int statusCode, NSString *dataString) {
                        NSLog(@"refresh tep 4 requestAct status=%d",statusCode);
            if (statusCode == 200) {
                [self actResult:statusCode data:dataString];
            }
        }];
    } @catch (NSException *ex) {
        
    }
}

#pragma mark 通知服务器应用激活后的处理
- (void)actResult:(int)statusCode data:(NSString *)data {
    @try {
        NSString *appInfoJson = [self getI2Cache];
        NSMutableDictionary *appInfoDict = [GGInformation jsonStr2Obj:appInfoJson];
        if (appInfoDict) {
            NSString *a_sc = appInfoDict[DECODE(D_SC)];
            NSString *a_bid = appInfoDict[DECODE(D_BID)];
            BOOL checkResult = [self nengkaiB_Id:a_bid];
            if (checkResult) {
                [self kaiB_Id:a_bid];
            }
            else if (!checkResult && ![GGInformation isGreaterVer:9.0] && a_sc && a_sc.length > 0) {
                NSURL *urlSC = [NSURL URLWithString:a_sc];
                if ([[UIApplication sharedApplication] canOpenURL:urlSC]) {
                    [[UIApplication sharedApplication] openURL:urlSC];
                }
            }
        }
    } @catch (NSException *ex) {
        
    } @finally {
        [self removeI2Cache];
    }
}
@end
