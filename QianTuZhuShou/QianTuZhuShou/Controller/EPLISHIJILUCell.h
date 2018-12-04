//
//  EPLISHIJILUCell.h
//  aiyilove
//
//  Created by 向日葵 on 15/11/21.
//  Copyright © 2015年 Expai. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "EPLISHIJILUmodel.h"
#import "LYMusicModel.h"

typedef void (^dianji)(NSString *title,NSIndexPath *index);


@interface EPLISHIJILUCell : UITableViewCell

@property (nonatomic, strong)dianji returnBlock;

-(void)huoqu:(dianji)block;

@property (nonatomic,strong)UILabel *lbale;
@property (nonatomic,strong)UIView *bgview;
@property (nonatomic,strong)UIButton *button;


@property (nonatomic,assign)NSIndexPath *indepat;

-(void)fanhuishuju:(LYMusicModel *)model;




@end
