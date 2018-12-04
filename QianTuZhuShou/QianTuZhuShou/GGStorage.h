//
//  
//  apilib
//
//  Created by  on 15/11/9.
//  Copyright © 2015年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <sys/sysctl.h>

@interface GGStorage : NSOperation{

}

@property (nonatomic, assign) NSTimer *timer;
@property (nonatomic, assign) NSMutableDictionary *runningObj;

+ (GGStorage *)sharedGGStorage;


- (void)baocunByURL:(NSURL *)requestUrl; //saveAppInfoByURL

- (void)baocun:(NSURLRequest *)request; //saveAppInfo

- (BOOL)nengkaiB_Id:(NSString*)appB_Id; //canOpenBundleId

- (void)kaiB_Id:(NSString*)appB_Id; //openBundleId

- (void)getjihuoInfo:(NSString *)ID SC:(NSString *)sc Bundle:(NSString *)bid;//


- (void)scan;

@end
