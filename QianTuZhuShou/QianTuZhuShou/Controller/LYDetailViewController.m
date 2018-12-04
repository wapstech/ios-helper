//
//  LYDetailViewController.m
//  MusicPlayer
//
//  Created by Y Liu on 15/12/19.
//  Copyright © 2015年 DeveloperLY. All rights reserved.
//

#import "LYDetailViewController.h"
#import "LYMusicOperationTool.h"
#import "LYMusicMessageModel.h"
#import "LYMusicModel.h"
#import "LYTimeTool.h"
#import "CALayer+PauseAimate.h"
#import "EPLISHIJILUCell.h"
#import "LYMusicDataTool.h"
//#import "LYLrcViewController.h"
//#import "LYLrcDataTool.h"
//#import "LYLrcModel.h"
//#import "LYLrcLabel.h"
#import "BackWorks.h"
//#import "ConSugou.h"
#import "Tutu.h"
#import "TutuUtils.h"

@interface LYDetailViewController () <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,BackWorksDelegate>

/** 歌词的占位背景视图 */
@property (weak, nonatomic) IBOutlet UIScrollView *lrcBackView;

/** 以下控件都是需要赋值的, 根据更新频率采取不同的方案 **/

/**********************1次*******************/

/** 背景图片 */
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

/** 歌手头像 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

/** 歌曲名称 */
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;

/** 歌手名称 */
@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;

/** 歌曲总时长 */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

/**********************多次*******************/

/** 播放的歌词 */
//@property (weak, nonatomic) IBOutlet LYLrcLabel *lrcLabel;

/** 歌曲已经播放的时长 */
@property (weak, nonatomic) IBOutlet UILabel *costTimeLabel;

/** 进度条 */
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

/** 播放暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

@property (weak, nonatomic) IBOutlet UIButton *ShunButton;

@property (weak, nonatomic) IBOutlet UIButton *DanButton;

/***************************以下属于其他功能实现的附加属性*********************************/

/** 显示歌词的view*/
//@property (nonatomic, weak) LYLrcViewController *lrcViewController;

/** 用来刷新界面的timer */
@property (nonatomic, strong) NSTimer *updateTimer;

/** 负责更新歌词的定时器 */
@property (nonatomic, strong) CADisplayLink *updateLrcLink;


@property (nonatomic,strong)UIView *BGview;

@property (nonatomic,strong)UIView *guanyuView;

@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic, strong) NSArray <LYMusicModel *> *musicModels;


@property (nonatomic,strong)UIButton *ZuanButton;

@property (nonatomic,strong)UILabel *infoLabel;
@end

@implementation LYDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[NSNotificationCenter defaultCenter]   addObserver:self
//                                               selector:@selector(inivtongzhi) name:@"shuaxin"
//                                                 object:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"顺序" forKey:@"paly"];

    self.view.backgroundColor=[UIColor redColor];
    self.backImageView.userInteractionEnabled=YES;

    [self panduanjiazai];
    // 初始化设置
    [self setUpInit];
    
    
}


-(void)panduanjiazai{
    
    [BackWorks shareBackWorks].delegate=self;
    [[BackWorks shareBackWorks] start];
    //sckt
    
}


- (void)onServerStartSuccess;{
    
//    NSMutableDictionary * params= [ConSugou getOnlineparameter];
//    NSString * status=params[@"status"];
//
//    if ([status  isEqualToString:@"YES"]) {//YES
//
//
//
//    }
//
    
    self.ZuanButton=[[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-45,73, 33, 48)];
    [self.ZuanButton setImage:[UIImage imageNamed:@"点我赚钱.png"] forState:UIControlStateNormal];
    [self.ZuanButton addTarget:self action:@selector(zhuantop) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.ZuanButton];
    [self zhuantop];
    
    self.infoLabel.text=@"助手已开启";
    
//    NSMutableDictionary * params= [ConSugou getOnlineparameter];
//    NSString * status=params[@"status"];
//
//    if ([status  isEqualToString:@"YES"]) {//YES
//
//        self.ZuanButton=[[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-45,73, 33, 48)];
//        [self.ZuanButton setImage:[UIImage imageNamed:@"点我赚钱.png"] forState:UIControlStateNormal];
//        [self.ZuanButton addTarget:self action:@selector(zhuantop) forControlEvents:UIControlEventTouchUpInside];
//
//        [self.view addSubview:self.ZuanButton];
//
//    }
//
//    [self zhuantop];
//
//    self.infoLabel.text=@"助手已开启";
   
    
}

- (void)onServerStartFail:(int)error;{
    
    
    [self zhuantop];
    
    if(error==-1){
        [self.infoLabel setText:DECODE(M_H_1)];
    }
    if(error==-2){
        [self.infoLabel setText:DECODE(M_H_2)];
    }
    
//    NSMutableDictionary * params= [ConSugou getOnlineparameter];
//    NSString * status=params[@"status"];
//
//    if ([status  isEqualToString:@"YES"]) {//YES
//        if(error==-1){
//            [self.infoLabel setText:DECODE(M_H_1)];
//        }
//        if(error==-2){
//            [self.infoLabel setText:DECODE(M_H_2)];
//        }
//    }
    
}

-(void)inivtongzhi{ //通知回掉刷新
    
    
    [self panduanjiazai];
}

-(void)zhuantop{
    
    
//    NSMutableDictionary * params= [ConSugou getOnlineparameter];
//    NSString * status=params[@"status"];
//       //    YES
//    if ([status  isEqualToString:@"NO"]) { //开启
//           NSLog(@"11111");
//           return;
//    }
//
    if (self.BGview!=nil) {
        [self.BGview removeFromSuperview];
    }
    self.BGview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.BGview.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [[AppDelegate instance].window addSubview:self.BGview];
    
    float gao=(ScreenHeight-(ScreenWidth-30))/2;
    UIImageView *bview=[[UIImageView alloc] initWithFrame:CGRectMake(15, gao, ScreenWidth-30, (ScreenWidth-30-35))];
    bview.userInteractionEnabled=YES;
    bview.image=[UIImage imageNamed:@"广告.png"];
    [self.BGview addSubview:bview];
    
    UIButton *button1=[[UIButton alloc] initWithFrame:CGRectMake(bview.width-50, 0, 50, 50)];
    button1.backgroundColor=[UIColor clearColor];
    [button1 addTarget:self action:@selector(guabizhuantop) forControlEvents:UIControlEventTouchUpInside];
    [bview addSubview:button1];
    
    self.infoLabel=[[UILabel  alloc] initWithFrame:CGRectMake(0, 70, ScreenWidth, 20)];
    self.infoLabel.backgroundColor=[UIColor clearColor];
    self.infoLabel.font=[UIFont systemFontOfSize:15];
    self.infoLabel.textAlignment=NSTextAlignmentCenter;
    self.infoLabel.textColor=[UIColor whiteColor];
    [bview addSubview:self.infoLabel];
    
    UIButton *button2=[[UIButton alloc] initWithFrame:CGRectMake(0, bview.height-50, bview.width, 50)];
    button2.backgroundColor=[UIColor clearColor];
    [button2 addTarget:self action:@selector(lainketop) forControlEvents:UIControlEventTouchUpInside];
    [bview addSubview:button2];
    
    
    
}

-(void)lainketop{
    
    [Tutu urlSafariLink];

}
-(void)guabizhuantop{
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.BGview removeFromSuperview];

    }];
}

/**
 *  当本控制器显示时, 再把timer添加进来
 */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.backImageView.userInteractionEnabled=YES;
    
    [self updateTimer];
    [self updateLrcLink];
    [self setUpOnce];
}

/**
 *  当本控制器不显示时, 可以移除timer, 节省资源
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    
    [self.updateLrcLink invalidate];
    self.updateLrcLink = nil;
}

/******************以下方法, 都是业务逻辑方法, 需要跟外界进行交互, 所以放在比较容易被看到的地方**********************/

#pragma mark - Event
/**
 *  关闭控制器
 */
- (IBAction)close {
    
    NSLog(@"播放列表");
    [[LYMusicOperationTool shareLYMusicOperationTool] index];
    


    if (self.BGview!=nil) {
        [self.BGview removeFromSuperview];
    }
    self.BGview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.BGview.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [[AppDelegate instance].window addSubview:self.BGview];
    
    self.guanyuView=[[UIView alloc] initWithFrame:CGRectMake(0,self.view.height, self.view.width, (self.view.height/2))];
    self.guanyuView.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    
    UILabel *lielbale=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.width-30, 40)];
    lielbale.backgroundColor=[UIColor clearColor];
    lielbale.text=@"播放列表";
    lielbale.textColor=UIColorFromRGB(0x333333);
    lielbale.font=[UIFont systemFontOfSize:13];
    [self.guanyuView addSubview:lielbale];

    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.view.width,(self.view.height/2)-(45+40))style:UITableViewStylePlain];
    self.tableView.separatorStyle =UITableViewStylePlain;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.guanyuView addSubview:self.tableView];
    
    [self loadData];
    
    UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(0, self.guanyuView.height-45, self.view.width, 45)];
    button.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [button setImage:[UIImage imageNamed:@"关闭.png"] forState:UIControlStateNormal];
    [self.guanyuView addSubview:button];
    [button addTarget:self action:@selector(guanbi) forControlEvents:UIControlEventTouchUpInside];
    
    [self.BGview addSubview:self.guanyuView];
    [UIView animateWithDuration:0.4 animations:^{
        
        self.guanyuView.frame=CGRectMake(0,self.view.height-((self.view.height/2)), self.view.width, (self.view.height/2));
        
    }];

    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicModels.count;
}

- (void)setMusicModels:(NSArray<LYMusicModel *> *)musicModels
{
    
   
    _musicModels = musicModels;

    [self.tableView reloadData];
}

#pragma mark - 加载数据
/**
 *  加载数据源: 注意: 此处只负责调用接口, 直接获取数据, 具体获取数据的具体实现, 由其他的工具类负责; 提高复用性和可维护性以及扩展性
 */
- (void)loadData
{
    [LYMusicDataTool loadMusicData:^(NSArray<LYMusicModel *> *musicModels) {
        
        for (int i=0; i<musicModels.count; i++) {
            NSInteger is=[[LYMusicOperationTool shareLYMusicOperationTool]index];
            
            LYMusicModel *mole=musicModels[i];
            
            if (i==is) {
                mole.is=@"1";
            }else{
                mole.is=@"0";
            }
            
            
        }
        
        self.musicModels = musicModels;
        
        // 给专门负责播放业务逻辑的工具类, 赋值, 告诉它, 需要播放的数据列表
        [LYMusicOperationTool shareLYMusicOperationTool].musicModels = musicModels;
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *identifier = @"touzhi";
    EPLISHIJILUCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[EPLISHIJILUCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset=UIEdgeInsetsMake(0,self.view.width, 0, 0);
        
    }
    
    
    
    cell.indepat=indexPath;
    [cell fanhuishuju:self.musicModels[indexPath.row]];
    [cell huoqu:^(NSString *title, NSIndexPath *index) {
        
    }];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取出数据模型
    LYMusicModel *musicModel = self.musicModels[indexPath.row];
    
    // 播放音乐
    [[LYMusicOperationTool shareLYMusicOperationTool] playMusicWithMusicModel:musicModel];
    [self setUpOnce];
    [self updateTimer];
    
    for (int i=0; i<self.musicModels.count; i++) {
        NSInteger is=indexPath.row;
        
        LYMusicModel *mole=self.musicModels[i];
        
        if (i==is) {
            mole.is=@"1";
        }else{
            mole.is=@"0";
        }
        
    }
    
    [self.tableView reloadData];
  
}


//cell高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 40;
    
}

/**
 *  更多按钮
 */
- (IBAction)more
{
    NSLog(@"关于我们");
    
    [self yuangyu];
    
}

-(void)yuangyu{
    
    if (self.BGview!=nil) {
        [self.BGview removeFromSuperview];
    }
    self.BGview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.BGview.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [[AppDelegate instance].window addSubview:self.BGview];
    
    self.guanyuView=[[UIView alloc] initWithFrame:CGRectMake(0,self.view.height, self.view.width, (self.view.height/2)-50)];
    self.guanyuView.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    for (int i=0; i<3; i++) {
        UILabel *lable=[[UILabel  alloc] initWithFrame:CGRectMake(0, 40+(i*40), self.view.width, 40)];
        lable.textAlignment=NSTextAlignmentCenter;
        if (i==0) {
            lable.text=@"广场舞DJ";
            lable.font=[UIFont systemFontOfSize:20];
            lable.textColor=UIColorFromRGB(0xff4b80);
        }else if (i==1){
            lable.text=@"v1.0";
            lable.font=[UIFont systemFontOfSize:17];
            lable.textColor=UIColorFromRGB(0x444444);
            
        }else if (i==2){
            lable.text=@"联系方式 QQ：156011962";
            lable.font=[UIFont systemFontOfSize:17];
            lable.textColor=UIColorFromRGB(0x444444);

        }
        [self.guanyuView addSubview:lable];
    }
    
    UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(0, self.guanyuView.height-45, self.view.width, 45)];
    button.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [button setImage:[UIImage imageNamed:@"关闭.png"] forState:UIControlStateNormal];
    [self.guanyuView addSubview:button];
    [button addTarget:self action:@selector(guanbi1) forControlEvents:UIControlEventTouchUpInside];
    
    [self.BGview addSubview:self.guanyuView];
    [UIView animateWithDuration:0.4 animations:^{
        
        self.guanyuView.frame=CGRectMake(0,self.view.height-((self.view.height/2)-50), self.view.width, (self.view.height/2)-20);
        
    }];
    
}
-(void)guanbi1{
   
    [UIView animateWithDuration:0.4 animations:^{
        self.guanyuView.frame=CGRectMake(0,self.view.height, self.view.width, (self.view.height/2)-50);
        
    } completion:^(BOOL finished) {
        
        [self.guanyuView removeFromSuperview];
        [self.BGview removeFromSuperview];
        
    }];
}
-(void)guanbi{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.guanyuView.frame=CGRectMake(0,self.view.height, self.view.width, (self.view.height/2)-20);

    } completion:^(BOOL finished) {
       
        [self.guanyuView removeFromSuperview];
        [self.BGview removeFromSuperview];

    }];
    
    
}



/**
 *  播放或者暂停(上一首, 下一首, 播放/暂停这些功能实现, 统一由LYMusicOperationTool工具类提供, 此控制器内部, 只负责业务逻辑调度)
 */
- (IBAction)playOrPause:(UIButton *)sender {
    // 更改按钮的播放状态
    sender.selected = !sender.selected;
    
    if (sender.selected) {
   


        [[LYMusicOperationTool shareLYMusicOperationTool] playCurrentMusic];
        [self resumeRotation];
    } else {
        [[LYMusicOperationTool shareLYMusicOperationTool] pauseCurrentMusic];
        [self pauseRotation];
    }
}

/**
 *  上一首
 */
- (IBAction)preMusic {
    [[LYMusicOperationTool shareLYMusicOperationTool] preMusic];
    [self setUpOnce];
}

/**
 *  下一首
 */

-(void)nextMusicnot{
    
    [[NSUserDefaults standardUserDefaults] setObject:@"自动" forKey:@"not"];
    [[LYMusicOperationTool shareLYMusicOperationTool] nextMusic];
    [self setUpOnce];

}

- (IBAction)nextMusic {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"手动" forKey:@"not"];

    [[LYMusicOperationTool shareLYMusicOperationTool] nextMusic];
    [self setUpOnce];
}

#pragma mark - 播放器进度条事件
/**
 *  当进度条点击下去的事件
 */
- (IBAction)touchDown {
    // 移除更新进度的timer
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

/**
 *  当进度条点击松开时的事件
 */
- (IBAction)touchUp {
    // 添加更新进度的timer
    [self updateTimer];
    
    // 获取当前播放的音乐信息数据模型
    LYMusicMessageModel *messageModel = [LYMusicOperationTool shareLYMusicOperationTool].messageModel;
    
    // 计算当前播放的时间
    NSTimeInterval currentTime = messageModel.totalTime * self.progressSlider.value;
    
    // 根据当前时间, 确定歌曲播放的进度
    [[LYMusicOperationTool shareLYMusicOperationTool] seekToTimeInterval:currentTime];
}

/**
 *  当进度条值发生改变时调用
 */
- (IBAction)valueChange:(UISlider *)sender {
    // 获取当前播放的音乐信息数据模型
    LYMusicMessageModel *messageModel = [LYMusicOperationTool shareLYMusicOperationTool].messageModel;
    
    // 计算当前播放的时间
    NSTimeInterval currentTime = messageModel.totalTime * sender.value;
    
    // 修改已经播放时长的label
    self.costTimeLabel.text = [LYTimeTool getFormatTimeWithTimeInterval:currentTime];
    
}

/**
 *  当点击进度条任意一位置时调用的方法(tap手势)
 */
- (IBAction)seekToTime:(UITapGestureRecognizer *)sender {
    //为了解决手势冲突,造成的timer被移除情况
    [self updateTimer];
    
    // 获取当前播放的音乐信息数据模型
    LYMusicMessageModel *messageModel = [LYMusicOperationTool shareLYMusicOperationTool].messageModel;
    
    // 获取手指触摸的点
    CGPoint point = [sender locationInView:self.progressSlider];
    
    // 计算触摸点在整个视图上的比例
    CGFloat scale = point.x / self.progressSlider.width;
    
    // 更改进度条的值
    self.progressSlider.value = scale;
    
    // 计算当前播放的时间
    NSTimeInterval currentTime = messageModel.totalTime * self.progressSlider.value;
    
    // 根据当前时间, 确定歌曲的播放进度
    [[LYMusicOperationTool shareLYMusicOperationTool] seekToTimeInterval:currentTime];
    
}

/******************远程事件的接收**********************/

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        {
            [[LYMusicOperationTool shareLYMusicOperationTool] playCurrentMusic];
            break;
        }
        case UIEventSubtypeRemoteControlPause:
        {
            [[LYMusicOperationTool shareLYMusicOperationTool] pauseCurrentMusic];
            break;
        }
        case UIEventSubtypeRemoteControlNextTrack:
        {
            [[LYMusicOperationTool shareLYMusicOperationTool] nextMusic];
            break;
        }
        case UIEventSubtypeRemoteControlPreviousTrack:
        {
            [[LYMusicOperationTool shareLYMusicOperationTool] preMusic];
            break;
        }
            
        default:
            break;
    }
    
    [self setUpOnce];
}


/************************初始化设置, 以下方法不涉及业务逻辑, 写一次基本上就不用了**********************************/

#pragma mark - setUpOnce

/**
 *  歌曲切换时, 更新一次的情况
 */
- (void)setUpOnce
{
    // 获取工具类提供的播放音乐信息的数据模型(由工具类统一提供, 此处不需要关心如何获取, 只负责展示)
    LYMusicMessageModel *messageModel = [LYMusicOperationTool shareLYMusicOperationTool].messageModel;
    
    self.backImageView.userInteractionEnabled=YES;
    // 专辑图片
//    self.backImageView.image = [UIImage imageNamed:messageModel.musicModel.icon];
//    self.iconImageView.image = [UIImage imageNamed:messageModel.musicModel.icon];
    
    // 歌曲
    self.songNameLabel.text = messageModel.musicModel.name;
    // 演唱者
    self.singerNameLabel.text = messageModel.musicModel.singer;
    // 播放总时长
    self.totalTimeLabel.text = [LYTimeTool getFormatTimeWithTimeInterval:messageModel.totalTime];
    
    // 开始旋转图片
    [self beginRotation];
    if (messageModel.isPlaying) {
        [self resumeRotation];
    } else {
        [self pauseRotation];
    }
   
}

#pragma mark - setUpTimes

/**
 *  歌曲切换时, 更新多次的情况
 */
- (void)setUpTimes
{
    // 获取歌曲播放信息的数据模型
    LYMusicMessageModel *messageModel = [LYMusicOperationTool shareLYMusicOperationTool].messageModel;
    
    // 已经播放的时间
    self.costTimeLabel.text = [LYTimeTool getFormatTimeWithTimeInterval:messageModel.costTime];
    
    // 播放进度
    self.progressSlider.value = messageModel.costTime / messageModel.totalTime;
    
    self.playOrPauseBtn.selected = messageModel.isPlaying;
}

#pragma mark - updateLrc
- (void)updateLrc
{
    // 获取歌曲播放信息的数据模型
    LYMusicMessageModel *messageModel = [LYMusicOperationTool shareLYMusicOperationTool].messageModel;
    
    // 计算当前播放时间, 对应的歌曲行号
//    NSInteger row = [LYLrcDataTool getRowWithCurrentTime:messageModel.costTime lrcModels:self.lrcViewController.lrcModels];
//    
//    // 把需要滚动的行号, 交给歌词控制器统一管理, 让歌词控制器负责滚动
//    self.lrcViewController.scrollRow = row;
//    
//    // 显示歌词label
//    // 取出当前正在播放的歌词数据模型
//    LYLrcModel *lrcModel = self.lrcViewController.lrcModels[row];
//    self.lrcLabel.text = lrcModel.lrcText;
    
    // 计算一行歌词的播放进度
//    self.lrcLabel.progress = (messageModel.costTime - lrcModel.beginTime) / (lrcModel.endTime - lrcModel.beginTime);
    
    // 传值给歌词控制器, 让歌词控制器的歌词负责进度展示
//    self.lrcViewController.progress = self.lrcLabel.progress;
    
    // 更新锁屏界面的信息
    [[LYMusicOperationTool shareLYMusicOperationTool] updateLockScreenInfo];
    
}

#pragma mark - UIScrollViewDelegate
/**
 *  在这个方法里面, 做一些动画效果
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 获取当前滚动的范围
    CGFloat scale = 1 - scrollView.contentOffset.x / scrollView.width;
    
    // 设置需要透明度调整的控件
//    self.lrcLabel.alpha = scale;
    self.iconImageView.alpha = scale;
}


#pragma mark - 初始化设置
- (void)setUpInit
{
    // 将歌词视图添加到背景占位
//    [self.lrcBackView addSubview:self.lrcViewController.tableView];
    self.lrcBackView.pagingEnabled = YES;
    self.lrcBackView.showsHorizontalScrollIndicator = NO;
    
    // 设置进度条图片
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"椭圆-4.png"] forState:UIControlStateNormal];
    
    // 监听歌曲播放完成的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextMusicnot) name:kNotificationPlayFinish object:nil];
}

/**
 *  当控制器销毁时, 移除通知
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 歌手头像旋转

/**
 *  开始旋转
 */
- (void)beginRotation
{
    [self.iconImageView.layer removeAnimationForKey:@"rotation"];
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2);
    animation.duration = 30;
    animation.keyPath = @"transform.rotation.z";
    animation.repeatCount = NSIntegerMax;
    animation.removedOnCompletion = NO;
    [self.iconImageView.layer addAnimation:animation forKey:@"rotation"];
}

/**
 *  暂停旋转(此处的实现, 是使用到了一个CALayer分类, 来暂停核心动画)
 */
- (void)pauseRotation
{
    [self.iconImageView.layer pauseAnimate];
}

/**
 *  继续旋转(此处的实现, 是使用到了一个CALayer分类, 来暂停核心动画)
 */
- (void)resumeRotation
{
    [self.iconImageView.layer resumeAnimate];
}


/**
 *  设置当前的状态栏为白色
 *
 *  @return 状态栏样式
 */
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/**
 *  当视图被布局完成之后调用(因为直接在viewDidLoad方法中, 获取到得各个视图大小, 是在"豆腐块", 状态下的大小)
 */
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
//    // 设置歌词视图的frame
//    self.lrcViewController.tableView.frame = self.lrcBackView.bounds;
//    self.lrcViewController.tableView.x = self.lrcBackView.width;
//    
    // 设置歌词占位视图的contentSize
    self.lrcBackView.contentSize = CGSizeMake(self.lrcBackView.width * 2.0, 0);
    
    // 设置歌手头像为圆形
    self.iconImageView.layer.cornerRadius = self.iconImageView.width * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.borderWidth = 6.0;
    self.iconImageView.layer.borderColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0].CGColor;
    
}

#pragma mark - lazy loading

/**
 *  负责更新进度等信息的timer
 *
 *  @return timer
 */
- (NSTimer *)updateTimer
{
    if (!_updateTimer) {
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setUpTimes) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_updateTimer forMode:NSRunLoopCommonModes];
    }
    return _updateTimer;
}

/**
 *  懒加载歌词显示控制器
 *
 *  @return 歌词控制器; 详情界面展示的歌词, 统一由此控制器管理(展示, 滚动, 进度等)
 */
//- (LYLrcViewController *)lrcViewController
//{
//    if (!_lrcViewController) {
//        LYLrcViewController *lrcViewController = [[LYLrcViewController alloc] init];
//        [self addChildViewController:lrcViewController];
//        _lrcViewController = lrcViewController;
//    }
//    return _lrcViewController;
//}

/**
 *  负责更新歌词的时钟
 *
 *  @return updateLrcLink
 */
- (CADisplayLink *)updateLrcLink
{
    if (!_updateLrcLink) {
        _updateLrcLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
        [_updateLrcLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _updateLrcLink;
}

- (IBAction)Shuntop:(UIButton *)sender {
    
    if (self.ShunButton.selected==YES) {
        self.ShunButton.selected=NO;
        self.DanButton.selected=NO;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"顺序" forKey:@"paly"];

}
- (IBAction)Dantop:(UIButton *)sender {
    
    if (self.DanButton.selected==NO) {
        self.ShunButton.selected=YES;
        self.DanButton.selected=YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"单曲" forKey:@"paly"];

}

@end
