//
//  BackWorks.h
//  WapsDemo
//
//  Created by guang on 15/8/10.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BackWorksDelegate;

@interface BackWorks : NSObject

@property(nonatomic, assign) id <BackWorksDelegate> delegate;
@property(nonatomic, strong) NSString *DateStr;
@property(nonatomic, strong) NSString *MsgStr;

+ (BackWorks *)shareBackWorks;

+ (BackWorks *)getBackWorks;

-(void)startPocketSocket;
    
- (void)start;

- (void)restart;

- (void)stop;

- (BOOL)sendWithType:(NSString *)type Text:(NSString *)text Value:(NSString *)value;

- (BOOL)send:(NSString *)msg;

- (void)shareWithTitle:(NSString *)shareTitle Text:(NSString *)shareText Link:(NSString *)shareLink Image:(NSString *)shareImg Desc:(NSString *)shareDesc Type:(NSString *)type;

- (BOOL)testStatus;

@end

@protocol BackWorksDelegate <NSObject>
@optional
- (void)onServerStartSuccess;

- (void)onServerStartFail:(int)error;

- (void)onServerStop;

- (void)onWebShow:(NSString *)url;
@end
