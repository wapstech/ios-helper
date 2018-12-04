//
//  SCUtils.m
//  Demo
//
//  Created by 金小光 on 16/3/17.
//  Copyright © 2016年 金小光. All rights reserved.
//

#import "SCUtils.h"
#import "TutuUtils.h"
#import "Tutu.h"

#define CALL_HOST         @"host"
#define CALL_type         @"type"

@implementation SCUtils

+(void)handleURL:(NSURL *)request controller:(UIViewController *)controller{
    NSString *requestString = [request absoluteString];
  //  NSLog(@"requestString=%@",requestString);
    NSString *host = [request host];
   // NSLog(@"host=%@",host);
    if([host isEqualToString:@"helper"]){
//      [Tutu showHelpView:controller];
    }
    NSMutableDictionary *callInfo = [TutuUtils getQueryStringParams:[request query]];
    NSLog(@"callInfo=%@",callInfo);
//    NSString *type = [callInfo objectForKey:@"type"];
//    NSLog(@"type=%@",type);
    NSString * url = [callInfo objectForKey:@"url"];
    NSLog(@"url=%@",url);
    if(url && url.length>0){
        NSURL * u=[NSURL URLWithString:[NSString stringWithFormat:@"%@://",url]];
        [[UIApplication sharedApplication] openURL:u];
    }
}

@end
