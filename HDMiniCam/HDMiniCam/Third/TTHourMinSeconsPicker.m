//
//  TTHourMinSeconsPicker.h
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTHourMinSeconsPicker.h"

@interface TTHourMinSeconsPicker()
<UIPickerViewDelegate,UIPickerViewDataSource>
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

@implementation TTHourMinSeconsPicker


- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect cg  = frame;
    cg.size.height = 204;
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
    if (_pickerType == 2) {
        for (int i = 1; i < 11; i++) {
            [hourArr addObject:[NSString stringWithFormat:@"%2d", i]];
        }
    }
    else {
        for (int i = 0; i < 60; i++) {
            if (i < 24) {
                [hourArr addObject:[NSString stringWithFormat:@"%02d", i]];
            }
            [minArr addObject:[NSString stringWithFormat:@"%02d", i]];
            [secArr addObject:[NSString stringWithFormat:@"%02d", i]];
        }
    }
    
    self.backgroundColor = [TTCommon ios13_systemColor:UIColor.blackColor earlier_systemColoer:UIColor.whiteColor];
    
    UIView *llView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    llView.backgroundColor = [TTCommon ios13_systemColor:UIColor.darkGrayColor earlier_systemColoer:TTRGB(240, 240, 240)];
    [llView addSubview:self.confirmButton];
    [llView addSubview:self.cancelButton];
    llView.userInteractionEnabled = YES;
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 24, SCREEN_WIDTH, 204)];
    picker.delegate = self;
    picker.dataSource = self;
    if (_pickerType == 1)
    {
        NSArray * tArr = [sTime componentsSeparatedByString:@":"];
        if (tArr.count > 0) {
            [picker selectRow:[[tArr objectAtIndex:0] intValue] inComponent:0 animated:YES];
            [picker selectRow:[[tArr objectAtIndex:1] intValue] inComponent:2 animated:YES];
            [picker selectRow:[[tArr objectAtIndex:2] intValue] inComponent:4 animated:YES];
        }
        
    }
    else if(_pickerType == 2)
        [picker selectRow:0 inComponent:0 animated:YES];
    else
        [picker selectRow:8 inComponent:0 animated:YES];

    
    [self addSubview:llView];
    [self addSubview:picker];
    [self addShadow];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

- (UIButton *)confirmButton
{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -100, 0, 100, 44)];
        _confirmButton.backgroundColor = UIColor.clearColor;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        NSString *title = TTLocalString(@"sure", nil);
        [_confirmButton setTitle:title forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        _cancelButton.backgroundColor = UIColor.clearColor;
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        NSString *title =TTLocalString(@"cancel_", nil);
        [_cancelButton setTitle:title forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (void)confirm:(UIButton *)but
{
    if (_pickerType == 1)
        self.confirmBlock([NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)[picker selectedRowInComponent:0],[picker selectedRowInComponent:2],[picker selectedRowInComponent:4]]);
    else if (_pickerType == 2)
        self.confirmBlock([NSString stringWithFormat:@"%ld", [picker selectedRowInComponent:0]+1]);
    else
        self.confirmBlock([NSString stringWithFormat:@"%02ld:%02ld", (long)[picker selectedRowInComponent:0],[picker selectedRowInComponent:2]]);
    [self tapBgview];
}

- (void)cancel:(UIButton *)but
{
    [self tapBgview];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_pickerType == 1)
        return 6;
    else if (_pickerType == 2)
        return 1;
    else
        return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
        return [hourArr count];
    else if (component == 1)
        return 1;
    else if (component == 2)
        return [minArr count];
    else if (component == 3)
        return 1;
    else if (component == 4)
        return [secArr count];
    else if (component == 5)
        return 1;
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
        return [hourArr objectAtIndex:row];
    else if (component == 1)
        return TTLocalString(@"hous_", nil);
    else if (component == 2)
        return [minArr objectAtIndex:row];
    else if (component == 3)
        return TTLocalString(@"mins_", nil);
    else if (component == 4)
        return [secArr objectAtIndex:row];
    else if (component == 5)
        return TTLocalString(@"secs_", nil);
    return 0;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

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
