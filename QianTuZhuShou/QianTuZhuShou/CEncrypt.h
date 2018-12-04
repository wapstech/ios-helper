//
//  main.m
//  3DES研究
//
//  Created by apple on 15/10/22.
//  Copyright © 2015年 apple. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface CEncrypt : NSObject

+(NSString *)doEncrypt:(NSString *)plainText k:(NSString *)key ;

+(NSString*)doDecEncrypt:(NSString *)encryptText k:(NSString *)key ;

+ (NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key;

//+ (NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key ;
//
//+ (NSString *) parseByte2HexString:(Byte *) bytes;
//
//+ (NSString *) parseByteArray2HexString:(Byte[]) bytes;
+ (NSString *)md5WithString:(NSString *)input;
@end
