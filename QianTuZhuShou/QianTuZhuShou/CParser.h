//
//  CParser.h
//  apilib
//
//  Created by  on 15/11/4.
//  Copyright © 2015年  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CParser : NSObject <NSXMLParserDelegate>

//+ (NSArray *)convertDictionaryArray:(NSArray *)dictionaryArray toObjectArrayWithClassName:(NSString *)className classVariables:(NSArray *)classVariables;

+ (id)getDataAtPath:(NSString *)path fromResultObject:(NSDictionary *)resultObject;

//+ (NSArray *)getAsArray:(id)object; //Utility function to get single NSDictionary object inside a array, if array is passed return the same

- (NSDictionary *)parseData:(NSData *)XMLData;

@end