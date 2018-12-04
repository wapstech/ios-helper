#import "HelpViewController.h"
#import "Tutu.h"
#import "BackWorks.h"
#import "TutuUtils.h"

#define C_BACK_COLOR            0xFF6600FF   //9966cc
#define C_BACK2_COLOR           0xff692e00   //9966cc
#define C_L_COLOR               0xE6E6E6FF
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0f \
green:((c>>16)&0xFF)/255.0f \
blue:((c>>8)&0xFF)/255.0f \
alpha:((c)&0xFF)/255.0f]

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
}

- (void)initView{
    float img_f=0.1f;
    float info_f=0.60f;
    float btn_f=0.75f;
    float ver_f=0.9f;
    float w=[self view].frame.size.width;
    float h=[self view].frame.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    float image_w=100;
    float btn_w=180;
    float btn_h=45;
    [[self view] setBackgroundColor:HEXCOLOR(C_BACK_COLOR)];
    
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = [self view].bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:HEXCOLOR(C_BACK_COLOR), HEXCOLOR(C_BACK2_COLOR),nil];
    
    [[self view].layer insertSublayer:gradientLayer atIndex:0];
    
    
    float img_x=w/2-image_w/2;
    float img_y=h*img_f;
    UIImage * image = [UIImage imageNamed:@"3x180.png"];
    _imgView =[[UIImageView alloc]initWithFrame:CGRectMake(img_x, img_y, image_w, image_w)];
    [[self view]addSubview:_imgView];
    _imgView.image=image;
    _imgView.layer.cornerRadius = 15;
    _imgView.layer.masksToBounds = YES;
    
    CGColorRef color = CGColorCreate(colorSpace,(CGFloat[]){ 255,255, 255, 1 });
    [_imgView.layer setBorderWidth:2];
    [_imgView.layer setBorderColor:color];
    
    float title_w=200;
    float title_h=54;
    float title_x=w/2-title_w/2;
    float title_y=img_y+image_w+5;
    _infoLabel=[[UILabel alloc]initWithFrame:CGRectMake(title_x, title_y, title_w, title_h)];
    [_infoLabel setText:@""];
    _infoLabel.font = [UIFont boldSystemFontOfSize: 42.0];
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.numberOfLines = 3;
    _infoLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [_infoLabel setTextColor:[UIColor whiteColor]];
    [[self view]addSubview:_infoLabel];
    
    
    float lab_w=300;
    float lab_h=54;
    float lab_x=w/2-lab_w/2;
    float lab_y=h*info_f;
    _infoLabel=[[UILabel alloc]initWithFrame:CGRectMake(lab_x, lab_y, lab_w, lab_h)];
    [_infoLabel setText:DECODE(T_1)];
    _infoLabel.font = [UIFont systemFontOfSize: 18.0];
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.numberOfLines = 3;
    _infoLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [_infoLabel setTextColor:[UIColor whiteColor]];
    [[self view]addSubview:_infoLabel];
    
    
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 255,255, 255, 1 });
    
    
    float btn_x=w/2-btn_w/2;
    float btn_y=h*btn_f;
    _doBtn=[[UIButton alloc] initWithFrame:CGRectMake(btn_x, btn_y, btn_w, btn_h)];
    [_doBtn setTitle: DECODE(T_2) forState: UIControlStateNormal];
    _doBtn.titleLabel.font = [UIFont systemFontOfSize: 24.0];
    [_doBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self view]addSubview:_doBtn];
    [_doBtn.layer setMasksToBounds:YES];
    [_doBtn.layer setCornerRadius:22.0]; //设置矩形四个圆角半径
    [_doBtn.layer setBorderWidth:2.0]; //边框宽度
    [_doBtn.layer setBorderColor:colorref]; //边框颜色
    [_doBtn addTarget:self action:@selector(doBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    float ver_w=105;
    float ver_h=54;
    float ver_x=w/2-ver_w/2;
    float ver_y=h*ver_f;
    _verLabel=[[UILabel alloc]initWithFrame:CGRectMake(ver_x, ver_y, ver_w, ver_h)];
    
    NSDictionary *dic    = [[NSBundle mainBundle] infoDictionary];
    NSString * appName  = dic[@"CFBundleName"];
    NSString * appVersion= dic[@"CFBundleShortVersionString"];
    
    
    [_verLabel setText:[NSString stringWithFormat:@"%@ v%@",appName,appVersion]];
    _verLabel.font = [UIFont systemFontOfSize: 14.0];
    _verLabel.textAlignment = NSTextAlignmentCenter;
    _verLabel.numberOfLines = 3;
    _verLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [_verLabel setTextColor:HEXCOLOR(C_L_COLOR)];
    [[self view]addSubview:_verLabel];
}

-(void)doBtnAction:(id)sender;{
    NSURL * welcomeUrl=[NSURL URLWithString:DECODE(U_H)];
    [[UIApplication sharedApplication]openURL:welcomeUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
