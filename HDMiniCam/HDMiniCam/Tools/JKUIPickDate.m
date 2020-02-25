//
//  JKUIPickDate.m
//  OCTest
//
//  Created by 王冲 on 2018/2/25.
//  Copyright © 2018年 希爱欧科技有限公司. All rights reserved.
//

#import "JKUIPickDate.h"

#define KWindowWidth   [UIScreen mainScreen].bounds.size.width
#define KWindowHeight   [UIScreen mainScreen].bounds.size.height
#define TitleBtnCOLOR [UIColor colorWithRed:(102)/255.0 green:(102)/255.0 blue:(102)/255.0 alpha:1]

@interface JKUIPickDate ()
{
    PassValue myBlock;
    UIDatePicker *datePicker;
    UIButton *viewPandle;
    NSString *string3;
    UIButton *buttonCancle;
    UIButton *buttonSure;
    UIView *viewbottom;
}
@end
@implementation JKUIPickDate

+(instancetype)setDate
{
    return [[self alloc]init];
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self windowframe];//显示window
        
        [self twoButton]; //设置取消和确定按钮
        
        [self datePicker];//布局datePicker
    }
    
    return self;
}

#pragma mark  年月日 与  小时
- (void)datePicker
{
    //创建一个UIPickView对象
    datePicker = [[UIDatePicker alloc]init];
    //自定义位置
    datePicker.frame = CGRectMake(0, CGRectGetMaxY(viewbottom.frame)-15, KWindowWidth, 200);
    //设置背景颜色
    datePicker.backgroundColor = [UIColor clearColor];
    //datePicker.center = self.center;
    //设置本地化支持的语言（在此是中文)
    NSDate *date = datePicker.date;
    datePicker.maximumDate = date;
    //显示方式是只显示年月日
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    [datePicker setDate:date animated:YES];
    
    //放在盖板上
    [self addSubview:datePicker];
}

-(void)windowframe
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    viewPandle = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, KWindowWidth, KWindowHeight)];
    
    viewPandle.backgroundColor = [UIColor clearColor];
    //viewPandle.alpha = 0.3;
    [viewPandle addTarget:self action:@selector(clickcancle) forControlEvents:UIControlEventTouchUpInside];
    
    [window addSubview:viewPandle];
    self.frame = CGRectMake(0, KWindowHeight-240+20, KWindowWidth, 240);
    
    #pragma mark - 适配iOS13
    UIColor *color = [KHJUtility ios13Color:UIColor.blackColor ios12Coloer:UIColor.whiteColor];
    self.backgroundColor = color;
    
    self.alpha = 1.0;
    [viewPandle addSubview:self];
    
}

-(void)twoButton
{
    viewbottom = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KWindowWidth, 40)];
    
    
    #pragma mark - 适配iOS13
    UIColor *color = [KHJUtility ios13Color:UIColor.blackColor ios12Coloer:KHJRGB(245, 245, 245)];
    viewbottom.backgroundColor = color;
    
    [self addSubview:viewbottom];
    
    buttonCancle = [[UIButton alloc]initWithFrame:CGRectMake(16,2, 80, 36)];
    [buttonCancle setTitle:KHJLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    buttonCancle.titleLabel.font = [UIFont systemFontOfSize:17];
    [buttonCancle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonCancle.titleLabel sizeToFit];
    [buttonCancle addTarget:self action:@selector(clickcancle) forControlEvents:UIControlEventTouchUpInside];
    [viewbottom addSubview: buttonCancle];
    
    buttonSure = [[UIButton alloc]initWithFrame:CGRectMake(KWindowWidth-56-44,2, 80, 36)];
//    buttonSure.titleLabel.font = [UIFont systemFontOfSize:14];
    [buttonSure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonSure setTitle:KHJLocalizedString(@"commit", nil) forState:UIControlStateNormal];
    buttonSure.titleLabel.font = [UIFont systemFontOfSize:17];
    [buttonSure.titleLabel sizeToFit];
    [buttonSure addTarget:self action:@selector(clickSure) forControlEvents:UIControlEventTouchUpInside];
    [viewbottom addSubview: buttonSure];
}

- (void)clickcancle
{
    [self getAllDate];
    [viewPandle removeFromSuperview];
}

- (void)getAllDate
{
    if (_cancelBlock) {
        _cancelBlock();
    }
}

-(void)clickSure
{
    NSDate *date = datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy_MM_dd"];
    string3 = [[NSString alloc]init];
    string3 = [dateFormatter stringFromDate:date];
    
    [viewPandle removeFromSuperview];
    myBlock(string3);
}

- (void)passvalue:(PassValue)block
{
    myBlock = block;
}




@end


















