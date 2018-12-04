//
//  main.m
//  3DES研究
//
//  Created by apple on 15/10/22.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "CEncrypt.h"
#import <CommonCrypto/CommonCryptor.h>
#import<CommonCrypto/CommonDigest.h>
//偏移量
#define gIv             @"12345678"

@implementation CEncrypt

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
    NSString *result = [myData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//    NSLog(@"%@=>%@",plainText,result);

    free((void *) bufferPtr);
    return result;
}



// MD5加密方法
+ (NSString *)md5WithString:(NSString *)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(str, (CC_LONG)strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return ret;
}



+ (NSString *)doDecEncrypt:(NSString *)encryptText k:(NSString *)key {
    
    encryptText = [encryptText stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    encryptText = [encryptText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
//    NSData *encryptData = [THGTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* encryptData = [[NSData alloc] initWithBase64EncodedString:encryptText options:0];
    
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



static Byte iv[] = {1,2,3,4,5,6,7,8};

+ (NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key
{
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          textBytes,
                                          dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    return ciphertext;
}

//+ (NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key {
//    NSData* cipherData = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
//    unsigned char buffer[1024];
//    memset(buffer, 0, sizeof(char));
//    size_t numBytesDecrypted = 0;
//    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
//                                          kCCAlgorithmDES,
//                                          kCCOptionPKCS7Padding,
//                                          [key UTF8String],
//                                          kCCKeySizeDES,
//                                          iv,
//                                          [cipherData bytes],
//                                          [cipherData length],
//                                          buffer,
//                                          1024,
//                                          &numBytesDecrypted);
//    NSString* plainText = nil;
//    if (cryptStatus == kCCSuccess) {
//        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
//        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    }
//    return plainText;
//}
//
//+(NSString *) parseByte2HexString:(Byte *) bytes
//{
//    NSMutableString *hexStr = [[NSMutableString alloc]init];
//    int i = 0;
//    if(bytes)
//    {
//        while (bytes[i] != '\0')
//        {
//            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
//            if([hexByte length]==1)
//                [hexStr appendFormat:@"0%@", hexByte];
//            else
//                [hexStr appendFormat:@"%@", hexByte];
//            i++;
//        }
//    }
//    return hexStr;
//}
//
//
//+(NSString *) parseByteArray2HexString:(Byte[]) bytes
//{
//    NSMutableString *hexStr = [[NSMutableString alloc]init];
//    int i = 0;
//    if(bytes)
//    {
//        while (bytes[i] != '\0')
//        {
//            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
//            if([hexByte length]==1)
//                [hexStr appendFormat:@"0%@", hexByte];
//            else
//                [hexStr appendFormat:@"%@", hexByte];
//            i++;
//        }
//
//    }
//    return hexStr;
//}


@end
