//
//  EPLISHIJILUCell.m
//  aiyilove
//
//  Created by 向日葵 on 15/11/21.
//  Copyright © 2015年 Expai. All rights reserved.
//

#import "EPLISHIJILUCell.h"

@implementation EPLISHIJILUCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    
    self.backgroundColor=[UIColor clearColor];
    self.bgview=[[UIView alloc] initWithFrame:CGRectMake(0, 0,ScreenWidth, 40)];
    self.bgview.backgroundColor=[UIColor clearColor];

    [self addSubview:self.bgview];
    
    self.lbale=[[UILabel alloc] initWithFrame:CGRectMake(15, (40-15)/2, self.width-100, 15)];
    self.lbale.backgroundColor=[UIColor clearColor];
    self.lbale.textColor=UIColorFromRGB(0x333333);
    self.lbale.font=[UIFont systemFontOfSize:15];
    [self.bgview addSubview:self.lbale];
    
    self.button=[[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-35,10, 20, 20)];
    self.button.backgroundColor=[UIColor clearColor];
    [self.button setImage:[UIImage imageNamed:@"播放-拷贝.png"] forState:UIControlStateNormal];
//    [self.button setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 0, 0)];
    [self.button addTarget:self action:@selector(dianji:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgview addSubview:self.button];
    
    return self;
}
-(void)huoqu:(dianji)block{
    self.returnBlock=block;
   
}


-(void)dianji:(UIButton *)button{
    
    
    if (self.returnBlock !=nil) {
        
        self.returnBlock(@"",self.indepat);
        
    }
}

-(void)fanhuishuju:(LYMusicModel *)model{
    
    self.lbale.text=model.name;
    NSLog(@"---------------*%@",model.is);
    
    if ([model.is isEqualToString:@"1"]) {
        self.lbale.textColor=UIColorFromRGB(0xff4b80);
        self.bgview.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.button setImage:[UIImage imageNamed:@"暂停-拷贝.png"] forState:UIControlStateNormal];

    }else{
        self.lbale.textColor=UIColorFromRGB(0x333333);
        self.bgview.backgroundColor=[UIColor clearColor];
        [self.button setImage:[UIImage imageNamed:@"播放-拷贝.png"] forState:UIControlStateNormal];


    }
    
//    self.button.indexpath=self.indepat;
//    self.button.title=model.name;
}
@end
