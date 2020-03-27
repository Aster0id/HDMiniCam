//
//  TTScanningVC.m
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTScanningVC.h"
#import "TTQRCode.h"

@interface TTScanningVC ()
<TTScanManagerDelegate>

{
    BOOL isFlash;
    UILabel *SHABI;
    UIView *boV;
    
    UIButton *flashBtn;
    TTScanManager *manager;
    TTScanningView *scanningView;
}

@end

@implementation TTScanningVC

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [scanningView addTimer];
    [manager resetSampleBufferDelegate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [scanningView removeTimer];
    [self removeFlashlightBtn];
    [manager cancelSampleBufferDelegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
}

- (void)customizeDataSource
{
    manager = [[TTScanManager alloc] init];
    manager.delegate = self;
    [manager setupSessionPreset:AVCaptureSessionPreset1920x1080
            metadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
              currentController:self];
    scanningView = [[TTScanningView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.9 * self.view.frame.size.height)];
}

- (void)customizeAppearance
{
    self.automaticallyAdjustsScrollViewInsets   = NO;
    self.view.backgroundColor                   = [UIColor clearColor];
    self.titleLab.text = TTLocalString(@"二维码扫描", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanningView];
    [self addShabi];
    [self addBov];
    
    flashBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    flashBtn.frame = CGRectMake(0.5 * (self.view.frame.size.width - 30), 0.55 * self.view.frame.size.height, 30, 30);
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightOpenImage"] forState:(UIControlStateNormal)];
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightCloseImage"] forState:(UIControlStateSelected)];
    [flashBtn addTarget:self action:@selector(flashBtn_action:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addShabi
{
    SHABI = [[UILabel alloc] init];
    SHABI.numberOfLines = 2;
    SHABI.textAlignment = NSTextAlignmentCenter;
    SHABI.backgroundColor = [UIColor clearColor];
    SHABI.font = [UIFont boldSystemFontOfSize:13.0];
    SHABI.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    SHABI.frame = CGRectMake(0, 0.73 * self.view.frame.size.height, SCREEN_WIDTH, 26);
    [self.view addSubview:SHABI];
}

- (void)addBov
{
    boV = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                   CGRectGetMaxY(scanningView.frame),
                                                   self.view.frame.size.width,
                                                   self.view.frame.size.height - CGRectGetMaxY(scanningView.frame))];
    boV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:boV];
}

- (void)backAction
{
    [self removeScanningView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeScanningView
{
    [scanningView removeTimer];
    [scanningView removeFromSuperview];
    scanningView = nil;
}

#pragma mark - - - TTScanManagerDelegate

- (void)QRCodeScanManager:(TTScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects
{
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [scanManager playSoundName:@"SGQRCode.bundle/sound.caf"];
        [scanManager stopRunning];
        [scanManager videoPreviewLayerRemoveFromSuperlayer];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
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
        [self.view addSubview:flashBtn];
    }
    else {
        if (isFlash == NO) {
            [self removeFlashlightBtn];
        }
    }
}

- (void)removeFlashlightBtn
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TTQRCodeTool closeFlash];
        self->isFlash = NO;
        self->flashBtn.selected = NO;
        [self->flashBtn removeFromSuperview];
    });
}

#pragma mark -

- (void)flashBtn_action:(UIButton *)button
{
    if (button.selected == NO) {
        [TTQRCodeTool openFlash];
        isFlash = YES;
        button.selected = YES;
    }
    else
        [self removeFlashlightBtn];
}



@end

