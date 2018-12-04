//
//  main.m
//  3DES研究
//
//  Created by apple on 15/10/22.
//  Copyright © 2015年 apple. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface THEncrypt : NSObject

+(NSString *)doEncrypt:(NSString *)plainText k:(NSString *)key ;

+(NSString*)doDecEncrypt:(NSString *)encryptText k:(NSString *)key ;

@end
