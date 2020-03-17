//
//  KHJPicker.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJPicker.h"

static const NSInteger HZWDefaultHeight = 248;

@interface KHJPicker()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSMutableArray *hourArr;
    NSMutableArray *minArr;
    NSMutableArray *secArr;

    UIPickerView *picker;
    UIView *backgroundView;
}

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation KHJPicker


- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect cg  = frame;
    cg.size.height = HZWDefaultHeight-44;
    frame = cg;
    self = [super initWithFrame:frame];
    if (self) {
        hourArr = [NSMutableArray array];
        minArr = [NSMutableArray array];
        secArr = [NSMutableArray array];

    }
    return self;
}
- (void)initSubViews:(NSString *)sTime

{
    if (_tKind == 2) {
        
        for (int i = 1; i <11; i++) {
           
            NSString *str = [NSString stringWithFormat:@"%2d", i];
            [hourArr addObject:str];
        }
    }else{
        for (int i = 0; i < 60; i++) {
            NSString *str = [NSString stringWithFormat:@"%02d", i];
            if (i<24) {
                [hourArr addObject:str];
            }
            [minArr addObject:str];
            [secArr addObject:str];
        }
    }
    
    self.backgroundColor = [KHJUtility ios13Color:UIColor.blackColor ios12Coloer:UIColor.whiteColor];
    
    UIView *llView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    llView.backgroundColor = [KHJUtility ios13Color:UIColor.darkGrayColor ios12Coloer:KHJRGB(240, 240, 240)];
    [llView addSubview:self.confirmButton];
    [llView addSubview:self.cancelButton];
    llView.userInteractionEnabled = YES;
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 24, SCREEN_WIDTH, 204)];
    picker.delegate = self;
    picker.dataSource = self;
    if(_tKind == 1){//时间
        NSArray * tArr = [sTime componentsSeparatedByString:@":"];
        if ([tArr count]>0) {
            [picker selectRow:[[tArr objectAtIndex:0] intValue] inComponent:0 animated:YES];
            [picker selectRow:[[tArr objectAtIndex:1] intValue] inComponent:2 animated:YES];
            [picker selectRow:[[tArr objectAtIndex:2] intValue] inComponent:4 animated:YES];
        }

    }else if(_tKind == 2){//分钟
        [picker selectRow:0 inComponent:0 animated:YES];

    }else{
        [picker selectRow:8 inComponent:0 animated:YES];
    }
    
    [self addSubview:llView];
    [self addSubview:picker];
    [self addShadow];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -100, 0, 100, 44)];
        _confirmButton.backgroundColor = UIColor.clearColor;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        NSString *title = KHJLocalizedString(@"确认", nil);
        [_confirmButton setTitle:title forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        _cancelButton.backgroundColor = UIColor.clearColor;
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        NSString *title =KHJLocalizedString(@"取消", nil);
        [_cancelButton setTitle:title forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (void)confirm:(UIButton *)but
{
    if (_tKind == 1) {//时间
        
        NSString *hourString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)[picker selectedRowInComponent:0],[picker selectedRowInComponent:2],[picker selectedRowInComponent:4]];
        self.confirmBlock(hourString);
    }else if(_tKind == 2){//分钟
        NSString *hourString = [NSString stringWithFormat:@"%ld", [picker selectedRowInComponent:0]+1];
        self.confirmBlock(hourString);
    }else{
        
        NSString *hourString = [NSString stringWithFormat:@"%02ld:%02ld", (long)[picker selectedRowInComponent:0],[picker selectedRowInComponent:2]];
        self.confirmBlock(hourString);
    }
    [self tapBgview];
}
- (void)cancel:(UIButton *)but
{
    [self tapBgview];
}
#pragma mark - PickerDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    if (_tKind == 1) {
        return 6;

    }else if(_tKind == 2){
        return 1;
    }else{
        return 4;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    switch (component) {
        case 0:
            return [hourArr count];
            break;
        case 1:
            return 1;
            break;
        case 2:
            return [minArr count];
            break;
        case 3:
            return 1;
            break;
        case 4:
            return [secArr count];
            break;
        case 5:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            return [hourArr objectAtIndex:row];
        }
            break;
        case 1:
        {
            return KHJLocalizedString(@"时", nil);
        }
            break;
        case 2:
        {
            return [minArr objectAtIndex:row];
        }
            break;
        case 3:
            return KHJLocalizedString(@"分", nil);
            break;
        case 4:
            return [secArr objectAtIndex:row];
            break;
        case 5:
            return KHJLocalizedString(@"秒", nil);
            break;
        default:
            break;
    }
    return 0;
}

#pragma mark - PickerDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 30;
}

//添加遮罩
- (void)addShadow
{
    backgroundView = [[UIView alloc] init];
    backgroundView.frame = CGRectMake(0, 1,SCREEN_WIDTH,SCREEN_HEIGHT);
    backgroundView.backgroundColor = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0f];
    backgroundView.alpha = 0.6;
    [[[UIApplication sharedApplication] keyWindow] addSubview:backgroundView];
    
    UITapGestureRecognizer *gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgview)];
    backgroundView.userInteractionEnabled = YES;
    [backgroundView addGestureRecognizer:gest];
}

- (void)tapBgview
{
    [backgroundView removeFromSuperview];
    [self removeFromSuperview];
}


@end
