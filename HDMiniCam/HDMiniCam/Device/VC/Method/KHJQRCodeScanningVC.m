//
//  KHJQRCodeScanningVC.m
//  SGQRCodeExample
//
//  Created by kevin on 20/3/20.
//  Copyright © 2020年 kevin. All rights reserved.
//

#import "KHJQRCodeScanningVC.h"
#import "TTQRCode.h"

@interface KHJQRCodeScanningVC ()
<TTScanManagerDelegate>

{
    UILabel *SHABI;
    UIView *boV;
}

@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, assign) BOOL isFlash;
@property (nonatomic, strong) TTScanManager *manager;
@property (nonatomic, strong) TTScanningView *scanningView;

@end

@implementation KHJQRCodeScanningVC

- (TTScanManager *)manager
{
    if (!_manager) {
        _manager = [[TTScanManager alloc] init];
    }
    return _manager;
}

- (UIButton *)flashBtn
{
    if (!_flashBtn) {
        // 添加闪光灯按钮
        _flashBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        CGFloat flashBtnW = 30;
        CGFloat flashBtnH = 30;
        CGFloat flashBtnX = 0.5 * (self.view.frame.size.width - flashBtnW);
        CGFloat flashBtnY = 0.55 * self.view.frame.size.height;
        _flashBtn.frame = CGRectMake(flashBtnX, flashBtnY, flashBtnW, flashBtnH);
        [_flashBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightOpenImage"] forState:(UIControlStateNormal)];
        [_flashBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightCloseImage"] forState:(UIControlStateSelected)];
        [_flashBtn addTarget:self action:@selector(flashBtn_action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashBtn;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.scanningView addTimer];
    [_manager resetSampleBufferDelegate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.scanningView removeTimer];
    [self removeFlashlightBtn];
    [_manager cancelSampleBufferDelegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"二维码扫描", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.manager setupSessionPreset:AVCaptureSessionPreset1920x1080
                 metadataObjectTypes:@[AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode128Code]
                   currentController:self];
    self.manager.delegate = self;
    [self.view addSubview:self.scanningView];
    SHABI = [[UILabel alloc] init];
    SHABI.numberOfLines = 2;
    SHABI.textAlignment = NSTextAlignmentCenter;
    SHABI.backgroundColor = [UIColor clearColor];
    SHABI.font = [UIFont boldSystemFontOfSize:13.0];
    SHABI.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    SHABI.frame = CGRectMake(0, 0.73 * self.view.frame.size.height, SCREEN_WIDTH, 26);
    [self.view addSubview:SHABI];
    boV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanningView.frame), self.view.frame.size.width,
                                                   self.view.frame.size.height - CGRectGetMaxY(self.scanningView.frame))];
    boV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:boV];
}

- (void)backAction
{
    [self removeScanningView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (TTScanningView *)scanningView
{
    if (!_scanningView) {
        _scanningView = [[TTScanningView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.9 * self.view.frame.size.height)];
    }
    return _scanningView;
}

- (void)removeScanningView
{
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

#pragma mark - - - TTScanManagerDelegate

- (void)QRCodeScanManager:(TTScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects
{
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [scanManager playSoundName:@"SGQRCode.bundle/sound.caf"];
        [scanManager stopRunning];
        [scanManager videoPreviewLayerRemoveFromSuperlayer];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        //获取二维码信息
        NSString *string = [obj stringValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getQRCode_noti" object:string];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    else
        TLog(@"暂未识别出二维码");
}

- (void)QRCodeScanManager:(TTScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue
{
    if (brightnessValue < - 1) {
        [self.view addSubview:self.flashBtn];
    }
    else {
        if (self.isFlash == NO) {
            [self removeFlashlightBtn];
        }
    }
}

- (void)flashBtn_action:(UIButton *)button
{
    if (button.selected == NO) {
        [TTQRCodeTool openFlash];
        self.isFlash = YES;
        button.selected = YES;
    } else {
        [self removeFlashlightBtn];
    }
}

- (void)removeFlashlightBtn
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TTQRCodeTool closeFlash];
        self.isFlash = NO;
        self.flashBtn.selected = NO;
        [self.flashBtn removeFromSuperview];
    });
}



@end

