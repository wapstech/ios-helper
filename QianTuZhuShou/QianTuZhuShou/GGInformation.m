//
//  GGInformation.m
//  apilib
//
//  Created by on 15/11/4.
//  Copyright © 2015年 All rights reserved.
//
#import "GGInformation.h"
#import "CEncrypt.h"
#import "THReachability.h"
#import "TutuUtils.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "ConSugou.h"
#import "CHardwareTools.h"
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import <AdSupport/AdSupport.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CommonCrypto/CommonDigest.h>

@implementation GGInformation
//生成参数
+ (NSMutableDictionary *)genParams {
    NSString *app_id = [[ConSugou sharConSugou] appkey];
    return [self genParams:app_id];
}


//生成参数
+ (NSMutableDictionary *)genParams:(NSString *)appID_ {
    
    // Device info.
    UIDevice *device = [UIDevice currentDevice];
    NSString *model = [device model];
    NSString *systemVersion = [device systemVersion];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *device_name = [CHardwareTools getSysInfo];
    
    // Locale info.
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    NSString *language;
    if ([[NSLocale preferredLanguages] count] > 0) {
        language = [[NSLocale preferredLanguages] objectAtIndex:0];
    }
    else {
        language = [locale objectForKey:NSLocaleLanguageCode];
    }
    
    //应用版本.
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *) kCFBundleVersionKey];
    
    NSString *lad = [self isJBStr];
    
    
    //时间戳.
    NSString *timeStamp = [self getTimeS];
    
    if (!appID_) {
//        NSLog(@"ERROR 001!");
    }
    
    NSString *connectionType = [THReachability getTHReachibilityType];
    NSString *macID = [self getMC];
    
    NSString *code_idfa_udid = [self getFACode];
    NSString *code_idfv_udid = [self getFVCode];
    
    NSString *code_open_idfa= [self getOFA];
    
    NSString *wm = [self getWMC];
    
    NSString *up = [self getUpT];
    
    NSMutableDictionary *genericDict=[[NSMutableDictionary alloc] init];
    
    genericDict[DECODE(P_AID)]=appID_;
    genericDict[DECODE(P_D_TYPE)]=model;
    genericDict[DECODE(P_D_OSV)]=systemVersion;
    genericDict[DECODE(P_AV)]=bundleVersion;
    genericDict[DECODE(P_LV)]=DECODE(TUVER);
    genericDict[DECODE(B_ID)]=identifier;
    genericDict[@"spversion"] = DECODE(SDKVER);
    
    if (macID && macID.length > 0) {
        genericDict[DECODE(P_MAC)]=macID;
    }
    
    NSString *uniqueIdentifier = [GGInformation getUniqueIdentifier];
    if (uniqueIdentifier && uniqueIdentifier.length > 0) {
        genericDict[DECODE(P_UID)] = uniqueIdentifier;
    }
    if (code_idfa_udid && code_idfa_udid.length > 0) {
        genericDict[DECODE(P_UFA)] = code_idfa_udid;
    }
    if(code_open_idfa && code_open_idfa.length>0){
        genericDict[DECODE(P_OFIA)]= code_open_idfa;
    }
    
    if (code_idfv_udid && code_idfv_udid.length > 0) {
        genericDict[DECODE(P_UDV)] = code_idfv_udid;
    }
    
    if ([[ConSugou sharConSugou] apppid] && [[ConSugou sharConSugou] apppid].length > 0) {
        genericDict[DECODE(P_CH)] = [[ConSugou sharConSugou] apppid];
    }
    if ([[ConSugou sharConSugou] appuserid] && [[ConSugou sharConSugou] appuserid].length > 0) {
        genericDict[DECODE(P_USER)] = [[ConSugou sharConSugou] appuserid];
    }
    
    if (connectionType.length > 0) {
        genericDict[DECODE(P_CON_TYPE)] = connectionType;
    }
    
    //    if (openUDID.length > 0) {
    //        [genericDict setObject:openUDID forKey:P_UDID];
    //    }
    //
    //    if (openUDIDSlotCount.length > 0) {
    //        [genericDict setObject:openUDIDSlotCount forKey:P_UDID_COUNT];
    //    }
    
    if (lad.length > 0) {
        genericDict[DECODE(P_D_LAD)] = lad;
    }
    
    if (timeStamp.length > 0) {
        genericDict[DECODE(P_TT)] = timeStamp;
    }
    
    if (countryCode.length > 0) {
        genericDict[DECODE(P_D_CCODE)] = countryCode;
    }
    if (language.length > 0) {
        genericDict[DECODE(P_D_LANG)] = language;
    }
    
    if (device_name.length > 0) {
        genericDict[DECODE(P_D_NAME)] = device_name;
    }
    
    if (wm.length > 0) {
        genericDict[DECODE(P_WM)] = wm;
    }
    
    if (up.length > 0) {
        genericDict[DECODE(P_UT)] = up;
    }
    
    if (appID_.length > 0 && [self isGreaterVer:6.0]) {
        if ([self isJailBroken].boolValue) {
            
        } else {
            
        }
    }
    
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0
    // Carrier info.
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *carrierName = [carrier carrierName];
    
    if (carrierName && carrierName.length > 0) {
        genericDict[DECODE(P_C)] = carrierName;
        
    }
    
    NSString *isoCountryCode = [carrier isoCountryCode];
    if (isoCountryCode && isoCountryCode.length > 0) {
        genericDict[DECODE(P_CC)] = isoCountryCode;
    }
    
    NSString *mobileCountryCode = [carrier mobileCountryCode];
    
    if (mobileCountryCode && mobileCountryCode.length > 0) {
        genericDict[DECODE(P_MC)] = mobileCountryCode;
    }
    
    NSString *mobileNetworkCode = [carrier mobileNetworkCode];
    
    if (mobileNetworkCode && mobileNetworkCode.length > 0) {
        genericDict[DECODE(P_MN)] = mobileNetworkCode;
    }
    
    if (NSClassFromString(@"SKStoreProductViewController")) {
        genericDict[DECODE(P_IAP)] = @"yes";
    } else {
        genericDict[DECODE(P_IAP)] = @"no";
    }
    
#endif
//        NSLog(@"genericDict=%@", genericDict);
    return genericDict;
}

//getOpenIDFA
+ (NSString*)getOFA
{
    NSString * openIDFA= [[self getOidfaArr] objectAtIndex:0];
    NSString *code_open_idfa = [CEncrypt encryptUseDES:openIDFA key:DECODE(N_K)];
    return code_open_idfa;
}


//+ (NSString *)SHA256WithDeviceInfo:(NSString *)lad {
//    // Device info
//    NSString *idfa = [self getFA];
//    NSString *idfv = [self getFV];
//    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
//    
//    NSString *verifierStr = [NSString stringWithFormat:@"%@:%@:%@:%@:%@",
//                             idfa,
//                             idfv,
//                             lad,
//                             systemVersion,
//                             DECODE(SHA_K)];
//    
//    NSString *hashDeviceInfo = [self SHA256WithString:verifierStr];
//    
//    return hashDeviceInfo;
//}


+ (NSString *)createQuSgFmD:(NSDictionary *)paramDict {
    if (!paramDict) {
        paramDict = [self genParams];
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in [paramDict allKeys]) {
        id value = [paramDict objectForKey:key];
        // Encode string to a legal URL string.
        NSString *encodedString = [self createQuSgFmS:value];
        
        NSString *part = [NSString stringWithFormat:@"%@=%@", key, encodedString];
        
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"&"];
}

+ (NSString *)createQuSgFmS:(NSString *)string {
    NSString *encodedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                     (__bridge CFStringRef) string,
                                                                                                     NULL,
                                                                                                     (CFStringRef) @"!*'();:@&=+$,/?%#[]|",
                                                                                                     kCFStringEncodingUTF8));
    
    return encodedString;
}

+ (NSString *)getTimeS {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timeStamp = [NSString stringWithFormat:@"%d", (int) timeInterval];
    return timeStamp;
}

+ (NSString *)getFA {
    NSUUID *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    
    ASIdentifierManager *adIdentManager = [ASIdentifierManager sharedManager];
    if (adIdentManager.advertisingTrackingEnabled) {
        // DO CS_OS SDK
    } else {
        // WHAT I NEED TO DO!!!
    }
    
    return idfa.UUIDString;
}

+ (NSString *)getFV {
    NSString *idfv = nil;
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 6.0) {
        idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return idfv;
}


//todo: 判断越狱的方式需要变
+ (NSString *)isJBStr {
    if ([self isJailBroken].boolValue) {
        if (![self hasASID]) {
            return @"2";
        } else {
            return @"1";
        }
    }
    return @"0";
}

+ (BOOL)hasASID {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:CO_PATH];
    int suNavigationAccountID = [[dict objectForKey:[[NSString alloc] initWithFormat:@"%@%@%@",@"SUN",@"avigationA",@"ccountID"]] intValue];
    if (suNavigationAccountID > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

//模拟器好像获取不到...
+ (NSString *)getWMC {
    
//    NSArray * networkInterfaces = [NEHotspotHelper supportedNetworkInterfaces];
//    NSLog(@"Networks %@",networkInterfaces);
    
    NSString *wifiMac = nil;
    NSArray *interfaces = (__bridge NSArray *) CNCopySupportedInterfaces();
    for (NSString *interface in interfaces) {
        CFDictionaryRef networkDetails = CNCopyCurrentNetworkInfo((__bridge CFStringRef) interface);
        if (networkDetails) {
            wifiMac = (NSString *) CFDictionaryGetValue(networkDetails, kCNNetworkInfoKeyBSSID);
            wifiMac = [CEncrypt encryptUseDES:wifiMac key:DECODE(N_K)];
            CFRelease(networkDetails);
        }
    }
//    NSLog(@"wifiMac=%@",wifiMac);
    return wifiMac;
}

+ (NSString *)getMC {
    NSString *macID = [[self getMac] stringByReplacingOccurrencesOfString:@":" withString:@""];
    return macID;
}

+ (NSString *)getFACode {
    NSUUID *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier];
//    NSLog(@"idfa.UUIDString=%@",idfa.UUIDString);
    if (idfa) {
        NSString *code_idfa_udid = [CEncrypt encryptUseDES:idfa.UUIDString key:DECODE(N_K)];

        return code_idfa_udid;
    } else {
        return nil;
    }
}

+ (NSString *)getFVCode {
    NSString *code_idfv_udid = nil;
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 6.0) {
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        if (idfv) {
            code_idfv_udid = [CEncrypt encryptUseDES:idfv key:DECODE(N_K)];
            //            code_idfv_udid =[CSTools encodeToPercentEscapeString:code_idfv_udid];
        }
    }
    return code_idfv_udid;
}

//获取系统启动时间
+ (NSString *)getUpT {
    NSString *timeString = nil;
    NSString *upTime=@"";
    if([self isGreaterVer:9.0]){
        upTime = [self getUpTime_9];
    }else{
        upTime = [self getUpTime];
    }
    timeString = [CEncrypt encryptUseDES:upTime key:DECODE(N_K)];
    return timeString;
}

+ (NSString *)getUniqueIdentifier {
    return [self getMC];
}

static const char *jailbreak_apps[] =
{
    "/bin/bash",
    "/Applications/blacksn0w.app",
    "/Applications/blackra1n.app",
    "/Applications/Cydia.app",
    "/Applications/limera1n.app",
    "/Applications/greenpois0n.app",
    "/Applications/redsn0w.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/usr/sbin/sshd",
    "/etc/apt",
    NULL,
};

+ (NSString *)isJailBroken {
#if TARGET_IPHONE_SIMULATOR
    return @"0";
#endif
    
    // Check for known jailbreak apps. If we encounter one, the device is jailbroken.
    for (int i = 0; jailbreak_apps[i] != NULL; ++i) {
        NSString *str = [NSString stringWithUTF8String:jailbreak_apps[i]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:DECODE(CO_P1)]) {
            return @"1";
        } else if ([str isEqualToString:DECODE(CO_P2)]) {
            if (![GGInformation isGreaterVer:9.0] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:DECODE(CO_P3)]]) {
                return @"2";
            }
        } else if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]]) {
            return @"3";
        } else if ([self checkApp:str].intValue) {
            return @"4";
        } else if ([self checkInject].intValue) {
            return @"5";
        } else if ([self checkEnv].intValue) {
            return @"6";
        }
    }
    
    return @"0";
}

+ (NSString *)checkApp:(NSString *)str {
    struct stat stat_info;
    const char *cStr = [str UTF8String];
    if (0 == stat(cStr, &stat_info)) {
        return @"1";
    }
    return @"0";
}

+ (NSString *)checkInject {
    int ret;
    Dl_info dylib_info;
    int (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSString *str = [NSString stringWithCString:dylib_info.dli_fname encoding:NSUTF8StringEncoding];
        if (![str isEqualToString:DECODE(CO_P4)]) {
            return @"1";
        }
    }
    return @"0";
}

+ (NSString *)checkEnv {
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (!env) {
        return @"0";
    }
    return @"1";
}

+ (BOOL)isGreaterVer:(float)ver {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= ver) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)getMac {
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        NSLog(@"Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        NSLog(@"Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        NSLog(@"Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        NSLog(@"Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *) buf;
    sdl = (struct sockaddr_dl *) (ifm + 1);
    ptr = (unsigned char *) LLADDR(sdl);
    NSString *macAddress = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                            *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    macAddress = [macAddress lowercaseString];
    free(buf);
    
    return macAddress;
}

+ (NSString *)getUpTime_9{
    
    NSString * proc_useTime;
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0){
        double t=boottime.tv_sec;
        double tt=boottime.tv_usec;
        proc_useTime= [NSString stringWithFormat:@"%.0f.%.0f", t, tt];
        
        //        NSString *str = @"%Y-%m-%d %H:%M:%S";
        //        NSString * ss= [self dateInFormat:(long) t format:str];
        
    }
    return proc_useTime;
    
}

+ (NSString *)getUpTime {
    NSString *proc_useTiem;
    //指定名字参数，按照顺序第一个元素指定本请求定向到内核的哪个子系统，第二个及其后元素依次细化指定该系统的某个部分。
    //CTL_KERN，KERN_PROC,KERN_PROC_ALL 正在运行的所有进程
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, 0};
    size_t miblen = 4;
    //值-结果参数：函数被调用时，size指向的值指定该缓冲区的大小；函数返回时，该值给出内核存放在该缓冲区中的数据量
    //如果这个缓冲不够大，函数就返回ENOMEM错误
    size_t size;
    //返回0，成功；返回-1，失败
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc *process = NULL;
    struct kinfo_proc *newprocess = NULL;
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess) {
            if (process) {
                free(process);
                process = NULL;
            }
            return nil;
        }
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
        
    }
    while (st == -1 && errno == ENOMEM);
    if (st == 0) {
        if (size % sizeof(struct kinfo_proc) == 0) {
            int nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess) {
                for (int i = nprocess - 1; i >= 0; i--) {
                    @autoreleasepool {
                        
                        //the process duration
                        double t = process[i].kp_proc.p_un.__p_starttime.tv_sec; //秒
                        double mt = process[i].kp_proc.p_un.__p_starttime.tv_usec; //微秒
                        proc_useTiem = [NSString stringWithFormat:@"%.0f.%.0f", t, mt];
                        //                        NSString *str = @"%Y-%m-%d %H:%M:%S";
                        //                        NSString * ss= [self dateInFormat:(long) t format:str];
                    }
                    
                }
                free(process);
                process = NULL;
                return proc_useTiem;
                
            }
        }
    }
    return nil;
}

//+ (NSString *)encode:(NSString *)sText key:(NSString *)_key {
//    //kCCEncrypt 加密
//    NSString * code= [CEncrypt doEncrypt:sText k:_key];
//    return code;
//}


+ (NSString *)encWText:(NSString *)sText {
    //kCCEncrypt 加密
    NSString * code=[CEncrypt doEncrypt:sText k:C_K];
    return code;
}

+ (NSString *)DEC:(NSString *)sText{
    NSString * code=[CEncrypt doDecEncrypt:sText k:K];
    return code;
}

//+ (NSString *)ENC:(NSString *)sText{
//    NSString * code= [CEncrypt doEncrypt:sText k:K];
//    return code;
//}

//+ (NSString *)decode:(NSString *)sText key:(NSString *)_key {
//    //kCCDecrypt 解密
//    NSString * code= [CEncrypt doDecEncrypt:sText k:_key];
//    return code;
//}

+ (NSString *)decWText:(NSString *)sText {
    //kCCDecrypt 解密
    NSString * code= [CEncrypt doDecEncrypt:sText k:C_K];
    return code;
}

+ (NSString *)getChObj:(NSString *)defaultName {
    
    NSString *key = [NSString stringWithFormat:@"CODE_%@", defaultName];
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSString *en_Value = @"";
    if (value.length > 0) {
        en_Value = [self decWText:value];
    }
    return en_Value;
}


+ (void)setChObj:(NSString *)value forKey:(NSString *)defaultName {
    
    NSString *des_Value = [self encWText:value];
    NSString *key = [NSString stringWithFormat:@"CODE_%@", defaultName];
    [[NSUserDefaults standardUserDefaults] setObject:des_Value forKey:key];
}




//+ (BOOL)isPad {
//    UIDevice *device = [UIDevice currentDevice];
//    //    NSString *device_name = [device getSysInfo];
//    
//    //    if (device_name) {
//    //        NSRange model_range = [device_name rangeOfString:@"x86"];
//    //        if (model_range.length > 2) {
//    //            return YES;
//    //        }
//    //        return NO;
//    //    } else {
//    //        return NO;
//    //    }
//    return YES;
//}


///*type=0:发送过滤系统进程
// type=1:发送全部
// type=2:发送p_acflag=2
// */
//+ (NSString *)getTasks:(int)type {
//    NSString *proc_useTiem;
//    //指定名字参数，按照顺序第一个元素指定本请求定向到内核的哪个子系统，第二个及其后元素依次细化指定该系统的某个部分。
//    //CTL_KERN，KERN_PROC,KERN_PROC_ALL 正在运行的所有进程
//    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
//    size_t miblen = 4;
//    //值-结果参数：函数被调用时，size指向的值指定该缓冲区的大小；函数返回时，该值给出内核存放在该缓冲区中的数据量
//    //如果这个缓冲不够大，函数就返回ENOMEM错误
//    size_t size;
//    //返回0，成功；返回-1，失败
//    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
//    
//    struct kinfo_proc *process = NULL;
//    struct kinfo_proc *newprocess = NULL;
//    do {
//        size += size / 10;
//        newprocess = realloc(process, size);
//        if (!newprocess) {
//            if (process) {
//                free(process);
//                process = NULL;
//            }
//            return nil;
//        }
//        process = newprocess;
//        st = sysctl(mib, miblen, process, &size, NULL, 0);
//        
//    }
//    while (st == -1 && errno == ENOMEM);
//    if (st == 0) {
//        if (size % sizeof(struct kinfo_proc) == 0) {
//            int nprocess = size / sizeof(struct kinfo_proc);
//            int count = 0;
//            if (nprocess) {
//                NSMutableArray *array = [[NSMutableArray alloc] init];
//                NSString *str = [[NSString alloc] init];
//                for (int i = nprocess - 1; i >= 0; i--) {
//                    @autoreleasepool {
//                        
//                        //the process duration
//                        NSString *processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
//                        NSString *processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
//                        NSString *proc_CPU = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pctcpu];
//                        NSString *proc_uid = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_acflag];
//                        
//                        double t = process[i].kp_proc.p_un.__p_starttime.tv_sec; //秒
//                        double mt = process[i].kp_proc.p_un.__p_starttime.tv_usec; //微秒
//                        proc_useTiem = [NSString stringWithFormat:@"%.0f.%.0f", t, mt];
//                        //                        NSString *str = @"%Y-%m-%d %H:%M:%S";
//                        //                        NSString * ss= [self dateInFormat:(long) t format:str];
//                        if (type == 0) {
//                            if ([DECODE(CO_TSYS) rangeOfString:processName].location !=NSNotFound) {
//                                
//                            } else {
//                                count++;
//                                str = [NSString stringWithFormat:@"%@;%@", processName, str];
////                                NSLog(@"%@,%@", processName, proc_uid);
//                            }
//                        } else if (type == 1) {
//                            count++;
//                            str = [NSString stringWithFormat:@"%@;%@", processName, str];
////                            NSLog(@"%@,%@", processName, proc_uid);
//                            
//                        } else if (type == 2) {
//                            if ([proc_uid isEqualToString:@"2"]) {
//                                count++;
//                                str = [NSString stringWithFormat:@"%@;%@", processName, str];
////                                NSLog(@"%@,%@", processName, proc_uid);
//                            }
//                        }
//                        
//                    }
//                }
//                free(process);
//                process = NULL;
////                NSLog(@"Task size:%d/%d, uid=%d,type=%d", count, nprocess, getuid(), type);
//                return str;
//                
//            }
//            
//            
//        }
//    }
//    return nil;
//}


+ (NSMutableDictionary *)getQuSgP:(NSString *)queryString {
    NSMutableDictionary *parmas = [[NSMutableDictionary alloc] init];
    if (queryString) {
        NSRange range_1 = [queryString rangeOfString:@"?"];
        if ([queryString rangeOfString:@"?"].location !=NSNotFound) {
            queryString = [queryString substringFromIndex:range_1.location + range_1.length];
        }
        
        if ([queryString rangeOfString:@"&"].location !=NSNotFound) {
            NSArray *parts = [queryString componentsSeparatedByString:@"&"];
            for (NSString *configItem in parts) {
                if (configItem && configItem != nil) {
                    NSRange range_ = [configItem rangeOfString:@"="];
                    
                    if (range_.length > 0 && range_.location > 0 && [configItem length] > 0) {
                        NSArray *item = [configItem componentsSeparatedByString:@"="];
                        NSString *configKey = [item objectAtIndex:0];
                        NSString *configValue = [GGInformation revertUrl:[item objectAtIndex:1]];
                        NSString *value = [GGInformation stringByDecodingURLFormat:configValue];
                        if ([configValue length] > 0)
                            [parmas setObject:configValue forKey:configKey];
                    }
                }
            }
        } else {
            NSRange range_ = [queryString rangeOfString:@"="];
            if (range_.length > 0 && range_.location > 0 && [queryString length] > 0) {
                NSArray *item = [queryString componentsSeparatedByString:@"="];
                NSString *configKey = [item objectAtIndex:0];
                NSString *configValue = [GGInformation revertUrl:[item objectAtIndex:1]];
                NSString *value = [GGInformation stringByDecodingURLFormat:configValue];
                if ([configValue length] > 0) {
                    [parmas setObject:configValue forKey:configKey];
                }
                
            }
        }
    }
    return parmas;
}

+ (void)removeChObj:(NSString *)defaultName {
    NSString *key = [NSString stringWithFormat:@"CODE_%@", defaultName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}


+ (NSString *)revertUrl:(NSString *)url {
    if (url) {
        url = [url stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
        url = [url stringByReplacingOccurrencesOfString:@"%23" withString:@"#"];
        url = [url stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
        url = [url stringByReplacingOccurrencesOfString:@"%3F" withString:@"?"];
        url = [url stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
        url = [url stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        url = [url stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
        return url;
    }
    else {
        return nil;
    }
}

+ (NSString *)stringByDecodingURLFormat:(NSString *)string; {
    if (string && [string length] > 0) {
        NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return result;
    } else {
        return nil;
    }
}


+ (BOOL)isPad {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

+ (NSString *)appendPWU:(NSString *)url {
    NSRange range = [url rangeOfString:@"?"];
    NSString * tag=@"?";
    if(range.length>0){
        tag=@"&";
    }
    NSString *result = [NSString stringWithFormat:@"%@%@%@",
                        url,tag,
                        [self createQuSgFmD:[self genParams]]];
    
    return result;
}


+ (NSString *)getUserID {
    if (![[ConSugou sharConSugou] appuserid]) {
        NSString *uniqueID = [[GGInformation getUniqueIdentifier] lowercaseString];
        if (uniqueID) {
            [[ConSugou sharConSugou] setAppuserid:uniqueID];
        }
    }
    
    NSLog(@"appppppppppuuuuuuu -------- %@",[[ConSugou sharConSugou] appuserid]);
    
    return [[ConSugou sharConSugou] appuserid];
}

+ (void)clearCache {
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache removeAllCachedResponses];
}

+ (CGFloat)getCurrentSystemVersion {
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSString *)getDevOri {
    UIInterfaceOrientation interOr = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interOr)) {
        return @"1";
    } else if (UIInterfaceOrientationIsLandscape(interOr)) {
        return @"2";
    }
    return @"0";
}

+ (NSString*) getOpenIDFA
{
    NSString * openIDFA= [[self getOidfaArr] objectAtIndex:0];
    NSString *code_open_idfa = [CEncrypt encryptUseDES:openIDFA key:DECODE(N_K)];
    return code_open_idfa;
}

+ (NSArray*) getOidfaArr {
    
    NSArray* base = @[ @101015295179ll, @102443183283204ll, @105130332854716ll, @110633906966ll, @111774748922919ll, @112953085413703ll, @113174082133029ll, @113246946530ll, @114870218560647ll, @115829135094686ll, @115862191798713ll, @118506164848956ll, @118589468194837ll, @118881298142408ll, @120176898077068ll, @121848807893603ll, @123448314320ll, @123591657714831ll, @124024574287414ll, @127449357267488ll, @127995567256931ll, @132363533491609ll, @134841016914ll, @138326442889677ll, @138713932872514ll, @146348772076164ll, @147364571964693ll, @147712241956950ll, @148327618516767ll, @152777738124418ll, @154615291248069ll, @156017694504926ll, @158761204309396ll, @159248674166087ll, @160888540611569ll, @161500167252219ll, @161599933913761ll, @162729813767876ll, @165482230209033ll, @176151905794941ll, @177821765590225ll, @178508429994ll, @192454074134796ll, @194714260574159ll, @208559595824260ll, @209864595695358ll, @210068525731476ll, @239823722730183ll, @246290217488ll, @255472420580ll, @267160383314960ll, @292065597989ll, @99197768694ll, @342234513642ll, @349724985922ll, @99554596360ll, @40343401983ll, @500407959994978ll, @52216716219ll, @90376669494ll];
    
    NSMutableString* _s_appmap = [NSMutableString stringWithString:@""];
    NSString* _s = @"/";
    NSString* _c = @":";
    NSString* _b = @"b";
    NSString* _f = @"f";
    
    if(![GGInformation isGreaterVer:9.0]){
        [_s_appmap appendString:[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@",_f,_b,_c,_s,_s]]]?@"|":@"-"];
        for (id baseid in base) {
            [_s_appmap appendString:[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@",_f,_b,[baseid stringValue],_c,_s,_s]]]?@"|":@"-"];
        }
    }
    
    size_t size;
    struct timeval boottime;
    
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size = sizeof(boottime);
    NSString* _s_bt = @"";
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        _s_bt =[NSString stringWithFormat:@"%lu",boottime.tv_sec];
        _s_bt = [_s_bt substringToIndex:[_s_bt length]-4];
    }
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *_s_machine = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    sysctlbyname("hw.model", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.model", model, &size, NULL, 0);
    NSString *_s_model = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    
    NSString *_s_ccode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    
    NSArray* preferredLang = [NSLocale preferredLanguages];
    NSString* _s_langs;
    if (preferredLang == nil || ![preferredLang isKindOfClass:[NSArray class]] || [ preferredLang count ] == 0)
        _s_langs = @"en";
    else
        _s_langs =  [[preferredLang subarrayWithRange:NSMakeRange(0, MIN(8,[preferredLang count]))] componentsJoinedByString:@""];
    
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSString *_s_disk = [[fattributes objectForKey:NSFileSystemSize] stringValue];
    NSString* _s_osv = [[UIDevice currentDevice] systemVersion];
    NSString* _s_tmz = [[NSTimeZone systemTimeZone] name];
    
    NSDateFormatter* dateFormatter = [ [ NSDateFormatter alloc ] init ];
    [ dateFormatter setDateFormat:@"yyMMdd" ];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *hourShift = [[NSDateComponents alloc] init];
    [hourShift setHour:-4];
    NSDate *currentDay= [calendar dateByAddingComponents:hourShift toDate:[NSDate date] options:0];
    NSDateComponents *dayShift = [[NSDateComponents alloc] init];
    [dayShift setDay:1];
    
    NSMutableArray* openIDFAs = [NSMutableArray arrayWithCapacity:3];
    for (int j=0; j<3; j++) {
        
        NSString* _s_day = [dateFormatter stringFromDate:currentDay];
        NSString* fingerprint = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@",
                                 _s_bt,               _s_disk,
                                 _s_machine,          _s_model,
                                 _s_osv,              _s_ccode,
                                 _s_langs,            _s_appmap,
                                 _s_tmz,              _s_day];
        
        const char* str = [fingerprint UTF8String];
        unsigned char result[CC_SHA256_DIGEST_LENGTH];
        CC_SHA256(str, (CC_LONG)strlen(str), result);
        
        NSMutableString *hash = [NSMutableString stringWithCapacity:36];
        for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i+=2)
        {
            if (i==8 || i==12 || i==16 || i==20)
                [hash appendString:@"-"];
            [hash appendFormat:@"%02X",result[i]];
        }
        
        [openIDFAs addObject:hash];
        
        currentDay = [calendar dateByAddingComponents:dayShift toDate:currentDay options:0];
    }
    
    return openIDFAs;
}

+ (BOOL)isStatusBarHidden {
    return [[UIApplication sharedApplication] isStatusBarHidden];
}

+ (CGFloat)getCurrDW {
    CGFloat deviceWidth = 0.0f;
    float sysVer = [GGInformation getCurrentSystemVersion];
    if ([[GGInformation getDevOri] isEqualToString:@"1"]) {
        deviceWidth = [UIScreen mainScreen].bounds.size.width;
    } else if ([[GGInformation getDevOri] isEqualToString:@"2"]) {
        if (sysVer >= 8.0f) {
            deviceWidth = [UIScreen mainScreen].bounds.size.width;
        } else {
            deviceWidth = [UIScreen mainScreen].bounds.size.height;
        }
    }
    return deviceWidth;
}

+ (CGFloat)getCurrDH {
    CGFloat deviceHeight = 0.0f;
    float sysVer = [GGInformation getCurrentSystemVersion];
    if ([[GGInformation getDevOri] isEqualToString:@"1"]) {
        deviceHeight = [UIScreen mainScreen].bounds.size.height;
    } else if ([[GGInformation getDevOri] isEqualToString:@"2"]) {
        if (sysVer >= 8.0f) {
            deviceHeight = [UIScreen mainScreen].bounds.size.height;
        } else {
            deviceHeight = [UIScreen mainScreen].bounds.size.width;
        }
    }
    return deviceHeight;
}

//+ (NSString *)md5Hash:(NSString *)str {
//    const char *cStr = [str UTF8String];
//    unsigned char result[16];
//    CC_MD5(cStr, strlen(cStr), result);
//    NSString *md5Result = [NSString stringWithFormat:
//                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//                           result[0], result[1], result[2], result[3],
//                           result[4], result[5], result[6], result[7],
//                           result[8], result[9], result[10], result[11],
//                           result[12], result[13], result[14], result[15]
//                           ];
//    return md5Result;
//}

//+ (CGRect)getMidFrameWidthStr:(float)width heightStr:(float)height {
//    CGFloat popX = 0.0f, popY = 0.0f;
//    CGRect popFrame;
//    popFrame.size.width = width;
//    popFrame.size.height = height;
//    float rate = popFrame.size.width / popFrame.size.height;
//    BOOL isStatusH = [GGInformation isStatusBarHidden];
//    if ([[GGInformation getDevOri] isEqualToString:@"1"]) {
//        popFrame.size.width = kScreenWidth - 20.0f;
//        popFrame.size.height = popFrame.size.width / rate;
//        popX = (kScreenWidth - popFrame.size.width) / 2.0f;
//        popY = (kScreenHeight - popFrame.size.height) / 2.0f;
//    } else if ([[GGInformation getDevOri] isEqualToString:@"2"]) {
//        if (isStatusH) {
//            popFrame.size.height = kScreenWidth - 20.0f;
//            popFrame.size.width = popFrame.size.height * rate;
//            popX = (kScreenHeight - popFrame.size.width) / 2.0f;
//            popY = (kScreenWidth - popFrame.size.height) / 2.0f;
//        } else {
//            popFrame.size.height = kScreenWidth - 40.0f;
//            popFrame.size.width = popFrame.size.height * rate;
//            popX = (kScreenHeight - popFrame.size.width) / 2.0f;
//            popY = kStatusBarHeight / 4 + (kScreenWidth - kStatusBarHeight - popFrame.size.height) / 2.0f;
//        }
//    }
//    popFrame.origin.x = popX;
//    popFrame.origin.y = popY;
//    return popFrame;
//}


//+ (void)dataRequest:(NSURLRequest *)request andObject:(id)object tag:(int)tag {
//    BaseTask *baseTask = [[BaseTask alloc] initWithRequestString:request tag:tag];
//    baseTask.delegate = object;
//    [[AsyncManager sharedInstance] addTask:baseTask];
//}

+ (NSArray *)json2menu:(NSString *)jsonStr {
    NSArray *menuArray=[GGInformation jsonStr2Obj:jsonStr];
    return menuArray;
}

//+ (BOOL)isIOS7 {
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (version >= 7.0) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//+ (BOOL)isIOSVesion:(float) tagVer  {
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (version >= tagVer) {
//        return YES;
//    } else {
//        return NO;
//    }
//}


//+ (NSString *)getURLWithParams:(NSString *)url_ {
//    NSMutableString *result = [[NSMutableString alloc] init];
//    @try {
//        if (url_)
//            [result appendString:url_];
//        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithDictionary:[self genParams]];
//        NSDictionary *bindings_ = paramDict;
//        NSEnumerator *enumerator = [[paramDict allKeys] objectEnumerator];
//        NSString *bindingKey = nil;
//        while ((bindingKey = [enumerator nextObject])) {
//            NSString *bindingValue = [bindings_ objectForKey:bindingKey];
//            bindingValue = [self createQuSgFmS:bindingValue];
//            NSString *bindingString = [NSString stringWithFormat:@"&%@=%@", bindingKey, bindingValue];
//            [result appendString:bindingString];
//        }
//    } @catch (NSException *ex) {
////        NSLog(@"参数错误: %d", [ex reason]);
//    }
//    return result;
//}


//+ (NSString *)getShortSC:(NSString *)scString {
//    if (scString) {
//        NSRange range = [scString rangeOfString:@"://"];
//        if (range.length > 0 && range.location > 0) {
//            scString = [scString substringToIndex:range.location];
//        } else {
//            scString = [NSString stringWithFormat:@"%@://", scString];
//        }
//    }
//    return scString;
//}

//+ (NSString *)getConfigValue:(NSString *)key {
//    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
//    return value;
//}

+ (NSString *)obj2JsonStr:(id)dict{
    NSString *json=@"";
    if ([NSJSONSerialization isValidJSONObject:dict]){
        NSError *error_01;
        // 创造一个json从Data, NSJSONWritingPrettyPrinted指定的JSON数据产的空白，使输出更具可读性。
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error_01];
        json =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return json;
}

+ (id)jsonStr2Obj:(NSString *)json{
    NSError * error=nil;
    NSData* jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict =[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    //    [dict isKindOfClass:[NSData class]];
    //    NSLog(@"jsonDict=%@",dict);
    return dict;
}


//+ (void)testView:(UIView *)rootViews space:(NSString *)space {
//    NSArray *views = rootViews.subviews;
//    for (UIView *v in views) {
//        NSString *ss = [NSString stringWithFormat:@"%@%@", @"  ", space];
//        NSLog(@"%@%@",space,v);
//        v.alpha = .5;
//        v.backgroundColor = [UIColor blueColor];
//        [self testView:v space:ss];
//    }
//
//}


//+ (NSString *)SHA256WithTimeStamp:(NSString *)timeStamp {
//    NSString *appID = [[Confusion sharConfusion] appkey];
//
//    NSString *macID = [GGInformation getMC];
//
//    NSString *verifierStr = [NSString stringWithFormat:@"%@:%@:%@:%@",
//                             appID,
//                             macID,
//                             timeStamp,
//                             DECODE(SHA_K)];
//
//    NSString *hashStr = [self SHA256WithString:verifierStr];
//
//    return hashStr;
//}
//
//+ (NSString *)SHA256WithTimeStamp:(NSString *)timeStamp param:(NSString *)param {
//    NSString *appID = [[Confusion sharConfusion] appkey];
//
//    NSString *macID = [GGInformation getMC];
//
//    NSString *verifierStr = [NSString stringWithFormat:@"%@:%@:%@:%@:%@",
//                                                       appID,
//                                                       macID,
//                                                       timeStamp,
//                    DECODE(SHA_K),
//                                                       param];
//
//    NSString *hashStr = [self SHA256WithString:verifierStr];
//
//    return hashStr;
//}
//
//+ (NSString *)SHA256WithTimeStamp:(NSString *)timeStamp points:(int)points guid:(NSString *)guid {
//    NSString *appID = [[Confusion sharConfusion] appkey];
//
//    NSString *deviceID = [GGInformation getUniqueIdentifier];
//    if (!deviceID) {
//        deviceID = [GGInformation getMC];
//    }
//
//    NSString *amountStr = [NSString stringWithFormat:@"%d", points];
//
//    NSString *verifierStr = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",
//                                                       appID,
//                                                       deviceID,
//                                                       timeStamp,
//                                                       DECODE(SHA_K),
//                                                       amountStr,
//                                                       guid];
//
//    NSString *hashStr = [self SHA256WithString:verifierStr];
//
//    return hashStr;
//}
//
//
//+ (NSString *)SHA256WithString:(NSString *)dataStr {
//    unsigned char SHAStr[CC_SHA256_DIGEST_LENGTH];
//
//    CC_SHA256([dataStr UTF8String],
//              [dataStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
//              SHAStr);
//
//    NSData *SHAData = [[NSData alloc] initWithBytes:SHAStr
//                                             length:sizeof(SHAStr)];
//
//    NSString *result = [[SHAData description] stringByReplacingOccurrencesOfString:@" " withString:@""];
//    result = [result substringWithRange:NSMakeRange(1, [result length] - 2)];
//
//    return result;
//}


+ (void)mvkey:(NSString *)adid{
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
//    NSString *time = [CEncrypt md5WithString:dateString];
    int y = (arc4random() % 501) + 500;
    NSString *pisstr=[NSString stringWithFormat:@"%d",y];
//    NSString *pid = [CEncrypt md5WithString:pisstr];
//    NSString *mimi=[CEncrypt md5WithString:DECODE(MVlianjiekey)];
    NSString *he=[NSString stringWithFormat:@"%@%@%@",DECODE(MVlianjiekey),dateString,pisstr];
    
    he=[CEncrypt md5WithString:he];
    
//    NSLog(@"%@",he);
    NSDictionary *dic=@{@"time":dateString,
                        @"pisstr":pisstr,
                        @"he":he};
    
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:DECODE(MVJIUIDKEY)]; // 保存秘药key
    

}


+(NSString *)getNetWorkStates{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    state = @"无网络";
                    //无网模式
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5:
                {
                    state = @"WIFI";
                }
                    break;
                default:
                    break;
            }
        }
    }
    //根据状态选择
    return state;
}



@end

