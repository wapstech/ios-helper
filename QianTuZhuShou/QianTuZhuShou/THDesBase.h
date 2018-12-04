#import <Foundation/Foundation.h>

@interface THDesBase : NSObject


+ (NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key;
+ (NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key ;
+ (NSString *) parseByte2HexString:(Byte *) bytes;
+ (NSString *) parseByteArray2HexString:(Byte[]) bytes;

@end
