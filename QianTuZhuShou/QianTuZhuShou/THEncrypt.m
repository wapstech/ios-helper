//
//  main.m
//  3DES研究
//
//  Created by apple on 15/10/22.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "THEncrypt.h"
#import <CommonCrypto/CommonDigest.h>  
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>
#import "THGTMBase64.h"

//密匙 key
#define gkey            @"kingxiaoguang"
//偏移量
#define gIv             @"12345678"

@implementation THEncrypt

+ (NSString *)doEncrypt:plainText k:(NSString *)key {

    //把string 转NSData
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    const void *vplainText = (const void *) [data bytes];

    CCCryptorStatus ccStatus;
    uint8_t  *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;

    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    bufferPtr = malloc(bufferPtrSize * sizeof(uint8_t));
    memset((void *) bufferPtr, 0x0, bufferPtrSize);

    const void *vkey = (const void *) [key UTF8String];
    //偏移量
    const void *vinitVec = (const void *) [gIv UTF8String];

    //配置CCCrypt
    ccStatus = CCCrypt(kCCEncrypt,
            kCCAlgorithmDES, //3DES
            kCCOptionPKCS7Padding, //设置模式
            vkey,    //key
            kCCKeySizeDES,
            vinitVec,     //偏移量，这里不用，设置为nil;不用的话，必须为nil,不可以为@“”
            vplainText,
            plainTextBufferSize,
            (void *) bufferPtr,
            bufferPtrSize,
            &movedBytes);

    NSData *myData = [NSData dataWithBytes:(const void *) bufferPtr length:(NSUInteger) movedBytes];
    NSString *result = [THGTMBase64 stringByEncodingData:myData];
//    NSLog(@"%@=>%@",plainText,result);

    free((void *) bufferPtr);
    return result;
}


+ (NSString *)doDecEncrypt:(NSString *)encryptText k:(NSString *)key {



    NSData *encryptData = [THGTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];

    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];

    CCCryptorStatus ccStatus;
    uint8_t  *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;

    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    bufferPtr = malloc(bufferPtrSize * sizeof(uint8_t));
    memset((void *) bufferPtr, 0x0, bufferPtrSize);

    const void *vkey = (const void *) [key UTF8String];

    const void *vinitVec = (const void *) [gIv UTF8String];

    ccStatus = CCCrypt(kCCDecrypt,
            kCCAlgorithmDES,
            kCCOptionPKCS7Padding,
            vkey,
            kCCKeySizeDES,
            vinitVec,
            vplainText,
            plainTextBufferSize,
            bufferPtr,
            bufferPtrSize,
            &movedBytes);

    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *) bufferPtr
                                                                     length:(NSUInteger) movedBytes] encoding:NSUTF8StringEncoding];

//    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *) bufferPtr
//                                                                     length:(NSUInteger) movedBytes] encoding:NSUTF8StringEncoding];

    free((void *) bufferPtr);

    return result;
}


@end
