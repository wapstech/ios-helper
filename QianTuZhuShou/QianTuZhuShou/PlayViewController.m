//
//  PlayViewController.m
//  GUANGCHANGWUDJ
//
//  Created by 向日葵 on 2017/7/28.
//  Copyright © 2017年 向日葵. All rights reserved.
//

#import "PlayViewController.h"
//#import "BackWorks.h"
#import "Tutu.h"

@interface PlayViewController ()

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor redColor];
    // Do any additional setup after loading the view.
    [self addButton];
    
//    [self startPocketSocket];
}

//-(void)startPocketSocket{
//    NSLog(@"===== startPocketSocket ====");
////    [BackWorks shareBackWorks].delegate=self;
////    [[BackWorks getBackWorks] startPocketSocket];
//    [BackWorks shareBackWorks].delegate=self;
//    [[BackWorks shareBackWorks] start];
//}

-(void)addButton{
    UIButton *button2=[[UIButton alloc] initWithFrame:CGRectMake(0, 20, 200, 50)];
    button2.backgroundColor=[UIColor whiteColor];
    [button2 setTitle:@"开始赚钱" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(lainketop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

-(void)lainketop{
    
    [Tutu urlSafariLink];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
