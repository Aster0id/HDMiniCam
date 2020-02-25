//
//  KHJPickerView.m
//  TimeLineView
//
//  Created by hezewen on 2018/9/6.
//  Copyright © 2018年 zengjia. All rights reserved.
//

#import "KHJPickerView.h"
#import "JKUIPickDate.h"
#import "KHJCalculate.h"

//#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
//#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface KHJPickerView()
{
    UIButton *leftBtn;
    UIButton *rightBtn;
    UIButton *showButton;
    dateChanged myBlock;
}
@end

@implementation KHJPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setDatePicker];
    }
    return self;
}
#pragma mark - setDataPicker
- (void)setDatePicker
{
    showButton = [self getShowButton];
    leftBtn = [self getLeftButton];
    [self addSubview:leftBtn];
    [self addSubview:showButton];
}
//懒加载
- (UIButton *)getShowButton
{
    if(!showButton){
        
        showButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-60, 0, 120, 40)];
        [showButton setImage:[UIImage imageNamed:@"videotape_icon_calendar_nor"] forState:UIControlStateNormal];
        [showButton setTitleColor:[KHJUtility ios13Color:[UIColor whiteColor] ios12Coloer:[UIColor blackColor]] forState:UIControlStateNormal];
        showButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [showButton addTarget:self action:@selector(clickCalendar) forControlEvents:UIControlEventTouchUpInside];
    }
    NSString *currentDateString = [KHJCalculate getCurrentTimes];
    [showButton setTitle:currentDateString forState:UIControlStateNormal];
    return showButton;
}
- (UIButton *)getLeftButton
{
    if(!leftBtn){
        leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [leftBtn setFrame:CGRectMake(showButton.frame.origin.x-80, 4, 60, 32)];
        [leftBtn setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [leftBtn setTitle:KHJLocalizedString(@"pre", nil) forState:UIControlStateNormal];
        leftBtn.contentMode = UIViewContentModeScaleAspectFit;
        [leftBtn addTarget:self action:@selector(clickLeft:) forControlEvents:UIControlEventTouchUpInside];
    }
    return leftBtn;
}

- (UIButton *)getRightButton
{
    if(rightBtn == nil){
        rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [rightBtn setFrame:CGRectMake(showButton.frame.origin.x+showButton.frame.size.width+20, 4, 60, 32)];
        [rightBtn setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [rightBtn setTitle:KHJLocalizedString(@"nextDay", nil) forState:UIControlStateNormal];
//        rightBtn.contentMode = UIViewContentModeScaleAspectFit;
        [rightBtn addTarget:self action:@selector(clickRight:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 37, 0, 0);
        rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
        
        rightBtn.hidden = YES;
    }
    return rightBtn;
}
- (void)clickCalendar
{
    [self setPiker];
}
- (void)clickLeft:(UIButton *)button//点击左翻按钮
{
    NSString *setDatestring = [KHJCalculate prevDay:showButton.currentTitle];
    [showButton setTitle:setDatestring forState:UIControlStateNormal];
    [self getRightButton];
    rightBtn.hidden = NO;
    [self handleDate:setDatestring];

}
- (void)clickRight:(UIButton*)button//点击右翻按钮
{
    NSString *setDatestring = [KHJCalculate nextDay:showButton.currentTitle];
    NSString *currentDate = [KHJCalculate getCurrentTimes];
    if ([KHJCalculate compareDate:setDatestring withDate:currentDate] == 0) {

        rightBtn.hidden = YES;

    }else{
        rightBtn.hidden = NO;
    }
    [showButton setTitle:setDatestring forState:UIControlStateNormal];
    
    [self handleDate:setDatestring];

}
- (void)changeRightBtnState:(BOOL)isH
{
    [self getRightButton];
    if (isH) {
        rightBtn.hidden = YES;

    }else{
        rightBtn.hidden = NO;

    }
}
- (void)setPiker//日期选择
{
    JKUIPickDate *pickdate = [JKUIPickDate setDate];
    __weak typeof(showButton) weekShowButton = showButton;
    WeakSelf
    [pickdate passvalue:^(NSString *str) {
        
        NSLog(@"str==%@",str);//时间字符串需要转换 nsdate
        dispatch_async(dispatch_get_main_queue(), ^{//点击选择日期，确定按钮
            [weekShowButton setTitle:str forState:UIControlStateNormal];
            [weakSelf handleDate:str];
        });
    }];
}
- (void)handleDate:(NSString *)str
{
    myBlock(str);
}
- (void)dateChanged:(dateChanged)block
{
    myBlock = block;
}
@end



