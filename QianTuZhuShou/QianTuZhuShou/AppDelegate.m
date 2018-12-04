//
//  AppDelegate.m
//  GUANGCHANGWUDJ
//
//  Created by 向日葵 on 2017/7/27.
//  Copyright © 2017年 向日葵. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayViewController.h"

//#import "LYDetailViewController.h"
//#import "LYMusicModel.h"
//#import "LYMusicDataTool.h"
//#import "LYMusicListCell.h"
//#import "LYMusicOperationTool.h"

#import "BackWorks.h"
#import "Tutu.h"
#import "THNetStatus.h"



@interface AppDelegate ()<TODelegate,BackWorksDelegate>{
    NSInteger connrt;

}


@property (nonatomic,strong) NSTimer *timer;



@end

@implementation AppDelegate


+ (AppDelegate *)instance {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];

    [Tutu shareTutu].ap=@"a8db0aa005c1648bf6b04dfb7583720b";
    [Tutu shareTutu].pd=@"appstore";
    [Tutu shareTutu].ud=@"xiao";

    NSString *boo = [THNetStatus getTHReachibilityType];
    
    if ([boo isEqualToString:@"none"]) { //没有网络
        
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerr) userInfo:nil repeats:YES];
        
    }else{
        
        [Tutu toLink:@"a8db0aa005c1648bf6b04dfb7583720b" pid:@"appstore" uid:@"xiao"];
        
    }
    
//    [LYMusicDataTool loadMusicData:^(NSArray<LYMusicModel *> *musicModels) {
//
//        // 给专门负责播放业务逻辑的工具类, 赋值, 告诉它, 需要播放的数据列表
//        [LYMusicOperationTool shareLYMusicOperationTool].musicModels = musicModels;
//    }];
//    NSLog(@"%ld",[LYMusicOperationTool shareLYMusicOperationTool].musicModels.count);

    //启动websocket
    [self startPocketSocket];
    
    return YES;
}

-(void)startPocketSocket{
    NSLog(@"===== startPocketSocket ====");
    //    [BackWorks shareBackWorks].delegate=self;
    //    [[BackWorks getBackWorks] startPocketSocket];
    [BackWorks shareBackWorks].delegate=self;
    [[BackWorks shareBackWorks] start];
}


- (void)timerr{
    
    connrt ++;
    if (connrt == 1) {
        
    }
    NSString *boo = [THNetStatus getTHReachibilityType];
    
    if ([boo isEqualToString:@"none"]) { //没有网络
        
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerr) userInfo:nil repeats:YES];
    }else{
        
        [Tutu toLink:@"a8db0aa005c1648bf6b04dfb7583720b" pid:@"appstore" uid:@"xiao"];
        
        [self.timer invalidate];
        self.timer = nil;
    }
    
}

-(void)onLinkSuccess{
    
    NSLog(@"sdk成功");
    
}

- (void)onServerStop{
    [[BackWorks shareBackWorks] restart];
}

- (void)onServerStartFail:(int)error{
    [[BackWorks shareBackWorks] restart];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    [[BackWorks shareBackWorks] stop];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"----applicationWillEnterForeground-----");
    
    [[BackWorks shareBackWorks] restart];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"----applicationDidBecomeActive-----");
    
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//- (void)applicationWillResignActive:(UIApplication *)application{//将要进入后台
//
//
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setActive:YES error:nil];
//        [session setCategory:AVAudioSessionCategoryPlayback error:nil];//后台播放
//        [application beginReceivingRemoteControlEvents]; // 让后台可以处理多媒体的事件
//
//
//
//}


@end
