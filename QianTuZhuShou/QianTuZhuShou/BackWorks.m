//
//  BackWorks.m
//  WapsDemo
//
//  Created by guang on 15/8/10.
//
//

#import "BackWorks.h"
#import "PSWebSocketServer.h"
#import <AVFoundation/AVFoundation.h>
#import "TutuUtils.h"
#import "Flow.h"
#import "THDesBase.h"
#import "Tutu.h"
#import "HttpRequest.h"
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "Constant.h"
#import "UIImageView+WebCache.h"
#import "Tutu.h"
#import "ConSugou.h"
#import "GGInformation.h"

#define WX_IDFA                 @"WX_IDFA"
#define WX_IDFA_DIC_KEY         @"WX_IDFA_DIC_KEY"
#define PORT   7001
#define kLocalNotificationKey @"kLocalNotificationKey"


@interface BackWorks ()<PSWebSocketServerDelegate,WXApiManagerDelegate>
{
    // 后台播放器
    AVAudioPlayer *_player;
    NSTimer *_timer;  // 定时器
    NSString *reter;
    
}

@property (nonatomic) enum WXScene currentScene;

@property(nonatomic, strong) PSWebSocketServer *server;

@property(nonatomic, strong) PSWebSocket *webSocket;

@property(nonatomic) BOOL isOpen;

@property(nonatomic, strong) UIImageView  *imgxiazai;
@end

@implementation BackWorks

static BackWorks *shareBackGroundManager = nil;
+ (BackWorks *)shareBackWorks {
    @synchronized(self)
    {
        if (shareBackGroundManager == nil)
        {
            shareBackGroundManager = [[self alloc] init];
        }
    }
    return shareBackGroundManager;
}

+ (BackWorks *)getBackWorks {
    @synchronized(self)
    {
        if (shareBackGroundManager == nil)
        {
            shareBackGroundManager = [[self alloc] init2];
        }
    }
    return shareBackGroundManager;
}

- (id)init2
{
    self = [super init];
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // 准备播放器
        [self prepAudio];
        [WXApiManager sharedManager].delegate = self;

        
        
        // 下载图片通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tongzhi)
                                                     name:@"xianzaitupian"
                                                   object:nil];
    }
    return self;
}


/**
 *  准备播放器
 *
 *  @return 准备播放的结果
 */
- (BOOL)prepAudio
{
    
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"2212" ofType:@"mp3"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        return NO;
    
    NSURL *url = [NSURL fileURLWithPath:path];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (!_player)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
        [_player prepareToPlay];
    [_player setVolume:0.0f];
    // 设置循环无限次播放
    [_player setNumberOfLoops:-1];
    [_player play];
    return YES;
}

/**
 *  播放音频的方法
 */
- (void)playAudio
{
    if ([_player isPlaying])
    {
        [_player stop];
    }
    [_player play];
}

- (void)start
{
    // 开启后台播放
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    
    [self startPocketSocket];
    // 每隔一分钟去检查剩余的时间
    if (_timer == nil){
        [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(tik) userInfo:nil repeats:YES];
    }
    
}

- (void)restart
{
    //如果websocketserver被回收变为null，则重新创建连接并启动，否则直接停止，再重新启动
    if (!_server) {
        _server = [PSWebSocketServer serverWithHost:nil port:PORT];
        _server.delegate = self;
        [_server start];
        
    }else{
        [_server stop];
        [_server start];
    }
}

- (void)stop
{
    if (!_server) {
        [_server stop];
    }
}




- (void)tik
{

    // 这个是定时检查后台剩余时间
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0)
    {
        // 此处是播放一段空的音乐，声音为零时间很短循环播放的特点
        [self playAudio];
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    }
    //启动websocket
    if (!_server) {
        _server = [PSWebSocketServer serverWithHost:nil port:PORT];
        _server.delegate = self;
        [_server start];
        
    }
}

#pragma mark 回调处理
- (void)onLinkSuccess;{
//    NSLog(@"连接成功");
    
    
    
//    NSMutableDictionary * params= [Tutu getConfigs];
//    
//    NSString *date = params[@"date"];
//    NSString *msg = params[@"msg"];
//    
        
//    if (![date isEqualToString:_DateStr]) {
//    
//        if (_DateStr == nil) {
//            
//            _DateStr = date;
//            _MsgStr = msg;
//            
//        }else{
//            [Tutu regLocalNotification:date andMessage:msg];
//            _DateStr = date;
//            _MsgStr = msg;
//        }
//        
//    }
//    
    
}

-(void)startPocketSocket{
//    NSLog(@"Starting");
    _server = [PSWebSocketServer serverWithHost:nil port:PORT];
    _server.delegate = self;
    [_server start];
}


#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    
    NSLog(@"Did start");
    if ([[[BackWorks shareBackWorks] delegate] respondsToSelector:@selector(onServerStartSuccess)]) {
        [[[BackWorks shareBackWorks] delegate] onServerStartSuccess];
    }
}

- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"Did stop");
    if ([[[BackWorks shareBackWorks] delegate] respondsToSelector:@selector(onServerStop)]) {
        [[[BackWorks shareBackWorks] delegate] onServerStop];
    }
}

- (void)serverStartFail:(PSWebSocketServer *)server error:(int)error{
    NSLog(@"Start error !!!");
    if ([[[BackWorks shareBackWorks] delegate] respondsToSelector:@selector(onServerStartFail:)]) {
        [[[BackWorks shareBackWorks] delegate] onServerStartFail:error];
    }
}

- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
//    NSLog(@"Accept request");
    return YES;
}

#pragma mark 接收信息，处理后返回信息
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
    NSMutableDictionary * receiveDict=[TutuUtils jsonStr2Obj:message];
    NSString * messageType =[receiveDict objectForKey:@"messageType"];
//    id t=[receiveDict objectForKey:@"text"];
//    if([t isKindOfClass:[NSString class]]){
//        NSLog(@"is NSString");
//    }else{
//        NSLog(@"not NSString");
//    }
    NSLog(@"---------------= %@",[receiveDict objectForKey:@"text"]);
    
//    if ([[receiveDict objectForKey:@"text" ]isEqualToString:@"os_version"]) {
//            [webSocket send:@"11.0"];
//
//    }

    NSString * text = [NSString stringWithFormat:@"%@",[receiveDict objectForKey:@"text"]];
    NSString * appid =[receiveDict objectForKey:@"appid"];
    if(appid && appid.length>0){
        [[ConSugou sharConSugou] setAppkey:appid];
    }
    
    if(messageType!=nil){
        if ([messageType isEqualToString:@"picture"]) {
            [self Downloadpictures:[NSURL URLWithString:text]];
            NSLog(@"%@",text);
        }
        
        NSString * returnStr=[self handle:messageType command:text];
        if(returnStr!=nil){
            [receiveDict setObject:returnStr forKey:@"value"];
            
            NSString * returnJson=[TutuUtils obj2JsonStr:receiveDict];
            NSLog(@"returnJson = %@",returnJson);
            [webSocket send:returnJson];
        }
        
    }else{
    }
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    _isOpen=YES;
    _webSocket=webSocket;
//    NSLog(@"open");
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    _isOpen=NO;
    NSLog(@"close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
}

- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    _isOpen=NO;
//    NSLog(@"close");
}

- (NSString *)handle:(NSString *)type command:(NSString *)comm;{
    
    if(comm!=nil){
        //通过助手发送信息到服务器,自动加参数
        if(type && [type isEqualToString:@"geturl"]){
            NSMutableDictionary * pa= [GGInformation genParams];
            [HttpRequest getRequestWithURL:comm withParams:pa response:^(int statusCode, NSString *dataString) {
                NSLog(@"dataString=%@",dataString);
                [self send:dataString];
            }];
        }
        
        //通过助手发送信息到服务器，不加任何参数
        if(type && [type isEqualToString:@"gettext"]){
            [HttpRequest getRequestWithURL:comm response:^(int statusCode, NSString *dataString) {
                [self send:dataString];
            }];
        }
        
        if(type && [type isEqualToString:@"device"]){
            if([comm isEqualToString:@"ffz"]){
                NSString * msgFromJs = [self getLoginParameter:@"isNew"];
                if (msgFromJs && msgFromJs.length > 0) {
                    return msgFromJs;
                }else{
                    return @"";
                }
            }else{
                return @"";
            }
        }
        //获取idfa, 可以根据需要扩充可获取参数  {"messageType":"params","text":"idfa"}
        if(type && [type isEqualToString:@"params"]){
            if([comm isEqualToString:@"idfa"]){
                return [TutuUtils getFA];
            }else{
                NSMutableDictionary * params= [GGInformation genParams];
                NSLog(@"%@",comm);
                NSString * value;
                if ([comm isEqualToString:@"sdk_version"]) {
                   
                    value=params[@"sdk_version"];
                    
                }else if ([comm isEqualToString:@"bundle_id"]){
                    
                    value=params[@"bundle_id"];

                }else if([comm isEqualToString:@"os_version"]){
                    
                    value=@"11.0";
                }else{
                    value=@"";

                    
                }
                return value;
            }
        }
        
        //打开一个url或scheme  {"messageType":"openurl","text":"http://dwap.com/ua.jsp"}
        if(type && [type isEqualToString:@"openurl"]){
            [[ConSugou sharConSugou] setOpenurl:comm];
            NSDictionary *dic    = [[NSBundle mainBundle] infoDictionary];//获取info－plist
            NSString * bundleID  =   [dic objectForKey:@"CFBundleIdentifier"];//获取Bundle identifier
            comm=bundleID;
            
            if([[Flow shareFlow] canCall:comm]){
                [[Flow shareFlow] call:comm];
                return @"YES";
            }else{
                return @"NO";
            }
        }
        
        if(type && [type isEqualToString:@"weburl"]){
            if ([[[BackWorks shareBackWorks] delegate] respondsToSelector:@selector(onWebShow:)]) {
                [[[BackWorks shareBackWorks] delegate] onWebShow:comm];
                NSDictionary *dic    = [[NSBundle mainBundle] infoDictionary];//获取info－plist
                NSString * bundleID  =   [dic objectForKey:@"CFBundleIdentifier"];//获取Bundle identifier
                comm=bundleID;
                
                if([[Flow shareFlow] canCall:comm]){
                    [[Flow shareFlow] call:comm];
                }
                
                return @"YES";
            }else{
                return @"NO";
            }
        }
        
        //直接通过包名打开某app  {"messageType":"openapp","text":"com.guang.Demo31m"}
        if(type && [type isEqualToString:@"openapp"]){
            if([comm isEqualToString:@"appstore"]){
                NSString * uuu=@"rabbit://?url=itms-apps";
                NSURL *url = [NSURL URLWithString:uuu];
                BOOL isOpen=[[UIApplication sharedApplication] openURL:url];
                if(isOpen){
                    return @"YES";
                }else{
                    return @"NO";
                }
            }
            if([[Flow shareFlow] canCall:comm]){
                [[Flow shareFlow] call:comm];
                return @"YES";
            }else{
                return @"NO";
            }
        }
        
        //通过包名判断app是否已安装  {"messageType":"openapp","text":"com.guang.Demo31m"}
        if(type && [type isEqualToString:@"hasapp"]){
            if([comm isEqualToString:@"*"]){
                return [[Flow shareFlow] allList];
            }
            if([[Flow shareFlow] canCall:comm]){
                return @"YES";
            }else{
                return @"NO";
            }
        }
        
        
        //将一个app放入扫描队列  {"messageType":"loop","text":"app=xxx&scheme=xxx&name=xxx&bid=xxxx"}
        if(type && [type isEqualToString:@"loop"]){
            if([[Flow shareFlow] saveInfoWithURLString:comm]){
                return @"YES";
            }else{
                return @"NO";
            }
        }
        
        if(type && [type isEqualToString:@"scanclear"]){
            if([comm isEqualToString:@"*"]){
                [[Flow shareFlow] removeSListFromChache];
                return @"YES";
            }else{
                return @"NO";
            }
        }
        
        //打开一个url或scheme  {"messageType":"actsubmit","text":"[appinfo]json格式"}
        if(type && [type isEqualToString:@"actsubmit"]){
            BOOL flg= [[Flow shareFlow] reqOpenByJson:comm];
            if(flg){
                return @"YES";
            }else{
                return @"NO";
            }
        }
//        {"shareTitle":"jiahongwei","shareImg":"https:等待dwap.com\/icon.png","shareType":"20160920171600" ,"shareImg":"20160920171600"  }

        //分享
        if(type && [type isEqualToString:@"share"]){
            
            NSMutableDictionary * shareDict=[TutuUtils jsonStr2Obj:comm];
            [[ConSugou sharConSugou] setShareDict:shareDict];

            
            NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];//获取info－plist
            NSString * bundleID  = [dic objectForKey:@"CFBundleIdentifier"];//获取Bundle identifier
            comm=bundleID;
            
            if([[Flow shareFlow] canCall:comm]){
                [[Flow shareFlow] call:comm];
                return @"YES";
            }else{
                return @"NO";
            }
        }
  
        
        if(type && [type isEqualToString:@"push"]){
            NSMutableDictionary * msgDict=[TutuUtils jsonStr2Obj:comm];
            BOOL flg=[self sendLocalNotification:msgDict];
            if(flg){
                return @"YES";
            }else{
                return @"NO";
            }
        }
        
        //保存到keychian
        if(type && [type isEqualToString:@"save"]){
            NSMutableDictionary * info=[TutuUtils loadKeyChain:@"kc_user"];
            NSMutableDictionary * obj=[TutuUtils jsonStr2Obj:comm];
            info=obj;
            [TutuUtils saveKeyChain:@"kc_user" data:info];
            return @"YES";
        }
        
        //读取到keychian
        if(type && [type isEqualToString:@"load"]){
            NSMutableDictionary * info=[TutuUtils loadKeyChain:@"kc_user"];
            if(info){
                return [TutuUtils obj2JsonStr:info];
            }else{
                return @"YES";
            }
        }
        
        //读取消息
        if(type && [type isEqualToString:@"getmessage"]){
            
            NSMutableArray * msgList=[[Flow shareFlow] getMessagegArray];
            if(msgList.count>0){
                NSString * appJson=[msgList objectAtIndex:0];
                [msgList removeObjectAtIndex:0];
                [[Flow shareFlow] setMessageArray:msgList];
                return appJson;
            }else{
                return @"";
            }
        }
        
        //复制到粘贴板
        if(type && [type isEqualToString:@"copy"]){
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:comm];
            return @"YES";
        }
        
        //系统命令，预留测试中
        if(type && [type isEqualToString:@"command"]){
            if([comm isEqualToString:@"stop"]){
                [self stop];
            }
            if([comm isEqualToString:@"restart"]){
                [self restart];
            }
            return @"ok";
        }
        
    }else{
        return @"param text is null";;
    }
    return @"params is null";;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error != NULL){
        NSLog(@"保存图片失败");
    }else{
        NSLog(@"保存成功");
    }
}

-(void)tongzhi{
    
    
    
    
    [self.imgxiazai removeFromSuperview];
    
}

-(void)Downloadpictures:(NSURL *)url{
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //这里是处理下载进度的,好像没必要管他
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {//下载完成后
            NSLog(@"下载成功");

            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }];
    
  
    
//    if (self.imgxiazai!=nil) {
//        [self.imgxiazai removeFromSuperview];
//    }
//    self.imgxiazai = [[UIImageView alloc] init];
//    self.imgxiazai.tag=10005;
//    [self.imgxiazai sd_setImageWithURL:url];
//
    
}





- (BOOL)sendLocalNotification:(NSMutableDictionary *)msgDict;
{
    
   // NSLog(@"msgDict=%@",msgDict);
    NSString * msg=msgDict[@"msg"];
    
    NSString * dataStr=msgDict[@"date"];
  //  NSLog(@"msg=%@  dataStr=%@",msg,dataStr);
    if(dataStr && msg){
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSDate* showDate = [inputFormatter dateFromString:dataStr];
        
       // NSLog(@"msg=%@",msg);
      //  NSLog(@"dataStr=%@",showDate);
     //   NSLog(@"showDate=%@",showDate);
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        //触发通知时间
        localNotification.fireDate = showDate;
        //重复间隔
        //        localNotification.repeatInterval = kCFCalendarUnitMinute;
        localNotification.timeZone = [NSTimeZone localTimeZone];
        
        //通知内容
        localNotification.alertBody = msg;
        localNotification.applicationIconBadgeNumber = 0;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        //通知参数
        localNotification.userInfo = msgDict;
        
        localNotification.category = kNotificationCategoryIdentifile;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        return YES;
    }else{
        return NO;
    }

}
#pragma mark - 添加本地通知
- (void) LocalNotificationSleep:(NSDate *)date andNotificationDic:(NSMutableDictionary *)msgDict{
    
   // NSLog(@"date -- %@",date);
    UILocalNotification * noti=[[UILocalNotification alloc] init];
    //设置开始时间
    noti.fireDate=date;
    //设置body
    noti.alertBody=msgDict[@"msg"];
    //设置action
    noti.alertAction=@"详情";
    //设置闹铃
    noti.soundName=UILocalNotificationDefaultSoundName;
    noti.userInfo = msgDict;
    noti.category = kNotificationCategoryIdentifile;
    //注册通知
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
}
#pragma mark 获取登陆界面需要的参数
- (NSString*)getLoginParameter:(NSString*)isNew{
    NSMutableDictionary *paras = [GGInformation genParams];
    
    
    NSString *udid = [paras objectForKey:@"ufa"];
    NSString *os_version = [paras objectForKey:@"os_version"];
   // NSLog(@"os_version ------  %@",os_version);
    NSString *mac = [paras objectForKey:@"mac"];
    NSString *sdk_version = [paras objectForKey:@"sdk_version"];;
   // NSLog(@"sdk_version  --------  %@",sdk_version);
    NSString *device_name = [paras objectForKey:@"device_name"];
   //  NSLog(@"device_name ------  %@",device_name);
    NSString *channel = [paras objectForKey:@"channel"];
    NSString *net = [paras objectForKey:@"net"];
    NSDictionary *dic    = [[NSBundle mainBundle] infoDictionary];
    NSString * app_version= [dic objectForKey:@"CFBundleShortVersionString"];
    
    
    //因为idfa是加密过的，但王洋需要明文，所以得解密 oldIdfa获取到的也是加密过的，但王洋也需要明文
    udid = [THDesBase decryptUseDES:udid key:DECODE(N_K)];
    
    NSMutableDictionary *genericDict = [[NSMutableDictionary alloc] init];
    if(udid){
        genericDict[@"udid"]=udid;
    }
    if(os_version){
        genericDict[@"os_version"]=os_version;
    }
    if(sdk_version){
        genericDict[@"sdk_version"]=sdk_version;
    }
    if(device_name){
        genericDict[@"device_name"]=device_name;
    }
    if(channel){
        genericDict[@"channel"]=channel;
    }
    if(net){
        genericDict[@"net"]=net;
    }
    if(app_version){
        genericDict[@"app_version"]=app_version;
    }
    
    //添加js返回的一个数据，用于websocket传输
    if (isNew && isNew.length > 0) {
        [genericDict setObject:isNew forKey:@"isNew"];
    }
    NSLog(@"genericDict::======%@",genericDict);

    
    //把字典转成王洋需要的字符串
    NSString *json = [TutuUtils obj2JsonStr:genericDict];
    
    //字符串加密
    json = [THDesBase encryptUseDES:json key:DECODE(N_K)];
    
    //对加密后的字符串进行编码
    json = [TutuUtils createQueryStringFromString:json];
    
    return json;
    
}

- (BOOL)sendWithType:(NSString *)type Text:(NSString *)text Value:(NSString *)value{
    if(_isOpen){
        NSMutableDictionary * sendDict=[[NSMutableDictionary alloc]init];
        sendDict[@"messageType"]=type;
        sendDict[@"text"]=text;
        if(value){
            sendDict[@"value"]=value;
        }
        NSString * returnJson=[TutuUtils obj2JsonStr:sendDict];
       // NSLog(@"sendJson=%@",returnJson);
        [_webSocket send:returnJson];
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)testStatus{
    if(_isOpen){
//        NSLog(@"isOpen:YES");
        return YES;
    }else{
//        NSLog(@"isOpen:NO");
        return NO;
    }
}

- (BOOL)send:(NSString *)msg;{
    if(_isOpen){
        [_webSocket send:msg];
        return YES;
    }else{
        return NO;
    }
}

/*  分享  */
- (void)shareWithTitle:(NSString *)shareTitle Text:(NSString *)shareText Link:(NSString *)shareLink Image:(NSString *)shareImg Desc:(NSString *)shareDesc Type:(NSString *)type{
    NSURL * imgUrl=[NSURL URLWithString:shareImg];
    UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
    
    //    UIImage *thumbImage = [UIImage imageNamed:@"res2.png"];
    NSString *kLinkURL = shareLink;
    NSString *kLinkTagName = shareText;
    NSString *kLinkTitle = shareTitle;
    NSString *kLinkDescription = shareDesc;
    if([type isEqualToString:@"0"]){
        _currentScene=WXSceneSession;
    }
    if([type isEqualToString:@"1"]){
        _currentScene=WXSceneTimeline;
    }
    
    NSLog(@"开始分享");
    NSLog(@"shareLink--%@  shareText -- %@ shareTitle -- %@ shareDesc -- %@",shareLink,shareText,shareTitle,shareDesc);
    [WXApiRequestHandler sendLinkURL:kLinkURL
                             TagName:kLinkTagName
                               Title:kLinkTitle
                         Description:kLinkDescription
                          ThumbImage:thumbImage
                             InScene:_currentScene];

    
}

//#pragma mark - WXApiManagerDelegate
- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {
    //errCode为0则为分享成功
    NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", response.errCode];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end
