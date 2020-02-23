//
//  KHJQRCodeScanVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJQRCodeScanVC.h"
#import "SGQRCode.h"

@interface KHJQRCodeScanVC () <SGQRCodeScanManagerDelegate, SGQRCodeAlbumManagerDelegate>
@property (nonatomic, strong) SGQRCodeScanManager *manager;
@property (nonatomic, strong) SGQRCodeScanningView *scanningView;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation KHJQRCodeScanVC

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanningView addTimer];
    [_manager resetSampleBufferDelegate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanningView removeTimer];
    [self removeFlashlightBtn];
    [_manager cancelSampleBufferDelegate];
}

- (void)dealloc {
    NSLog(@"KHJQRCodeScanVC - dealloc");
    [self removeScanningView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.scanningView];
    [self setupQRCodeScanning];
    [self.view addSubview:self.promptLabel];
    /// 为了 UI 效果
    [self.view addSubview:self.bottomView];
    [self setbackBtn];
}

- (void)setbackBtn
{
    self.titleLab.text = @"扫一扫";
    [self.leftBtn addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)popAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (SGQRCodeScanningView *)scanningView
{
    if (!_scanningView) {
        _scanningView = [[SGQRCodeScanningView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.9 * self.view.frame.size.height)];
    }
    return _scanningView;
}

- (void)removeScanningView
{
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

- (void)setupQRCodeScanning
{
    self.manager = [SGQRCodeScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeQRCode,
                     AVMetadataObjectTypeEAN13Code,
                     AVMetadataObjectTypeEAN8Code,
                     AVMetadataObjectTypeCode128Code];
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
    _manager.delegate = self;
}

#pragma mark - - - SGQRCodeAlbumManagerDelegate

- (void)QRCodeAlbumManagerDidCancelWithImagePickerController:(SGQRCodeAlbumManager *)albumManager
{
    [self.view addSubview:self.scanningView];
}

- (void)QRCodeAlbumManager:(SGQRCodeAlbumManager *)albumManager didFinishPickingMediaWithResult:(NSString *)result
{
//    if ([result hasPrefix:@"http"]) {
//        ScanSuccessJumpVC *jumpVC = [[ScanSuccessJumpVC alloc] init];
//        jumpVC.comeFromVC = ScanSuccessJumpComeFromWC;
//        jumpVC.jump_URL = result;
//        [self.navigationController pushViewController:jumpVC animated:YES];
//
//    } else {
//        ScanSuccessJumpVC *jumpVC = [[ScanSuccessJumpVC alloc] init];
//        jumpVC.comeFromVC = ScanSuccessJumpComeFromWC;
//        jumpVC.jump_bar_code = result;
//        [self.navigationController pushViewController:jumpVC animated:YES];
//    }
}

- (void)QRCodeAlbumManagerDidReadQRCodeFailure:(SGQRCodeAlbumManager *)albumManager
{
    NSLog(@"暂未识别出二维码");
}

#pragma mark - - - SGQRCodeScanManagerDelegate

- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects
{
    NSLog(@"metadataObjects - - %@", metadataObjects);
    if (metadataObjects != nil && metadataObjects.count > 0) {
        [scanManager playSoundName:@"SGQRCode.bundle/sound.caf"];
        [scanManager stopRunning];
        [scanManager videoPreviewLayerRemoveFromSuperlayer];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        //获取二维码信息
        NSString *string = [obj stringValue];
        NSLog(@"string = %@",string);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 有线添加设备，扫描二维码的结果
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveUID_Noti" object:string];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    else {
        NSLog(@"暂未识别出扫描的二维码");
    }
}

- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue
{
    if (brightnessValue < - 1) {
        [self.view addSubview:self.flashlightBtn];
    } else {
        if (self.isSelectedFlashlightBtn == NO) {
            [self removeFlashlightBtn];
        }
    }
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
        CGFloat promptLabelW = SCREEN_WIDTH;
        CGFloat promptLabelH = 26;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
//        _promptLabel.text = KHJLocalizedString(@"erweiTips", nil);
        _promptLabel.numberOfLines = 2;
        
//        [_promptLabel sizeToFit];
    }
    return _promptLabel;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanningView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.scanningView.frame))];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _bottomView;
}

#pragma mark - - - 闪光灯按钮
- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        // 添加闪光灯按钮
        _flashlightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        CGFloat flashlightBtnW = 30;
        CGFloat flashlightBtnH = 30;
        CGFloat flashlightBtnX = 0.5 * (self.view.frame.size.width - flashlightBtnW);
        CGFloat flashlightBtnY = 0.55 * self.view.frame.size.height;
        _flashlightBtn.frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightOpenImage"] forState:(UIControlStateNormal)];
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightCloseImage"] forState:(UIControlStateSelected)];
        [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashlightBtn;
}

- (void)flashlightBtn_action:(UIButton *)button {
    if (button.selected == NO) {
        [SGQRCodeHelperTool SG_openFlashlight];
        self.isSelectedFlashlightBtn = YES;
        button.selected = YES;
    } else {
        [self removeFlashlightBtn];
    }
}

- (void)removeFlashlightBtn {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SGQRCodeHelperTool SG_CloseFlashlight];
        self.isSelectedFlashlightBtn = NO;
        self.flashlightBtn.selected = NO;
        [self.flashlightBtn removeFromSuperview];
    });
}



@end

