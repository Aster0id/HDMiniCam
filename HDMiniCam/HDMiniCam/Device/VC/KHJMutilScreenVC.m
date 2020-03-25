//
//  KHJMutilScreenVC.m
//  HDMiniCam
//
//  Created by kevin on 2020/3/9.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJMutilScreenVC.h"
#import "AppDelegate.h"
#import "UIDevice+TFDevice.h"
#import "KHJDeviceManager.h"

// 设备列表
extern NSMutableArray *mutliDeviceIDList;
// 当前解码类型
extern TTDecordeType currentDecorderType;

@interface KHJMutilScreenVC ()<H26xHwDecoderDelegate>
{
    __weak IBOutlet UIView *naviView;
    __weak IBOutlet UIButton *naviBtn;
    __weak IBOutlet UIImageView *oneImgView;
    __weak IBOutlet UIImageView *twoImgView;
    __weak IBOutlet UIImageView *threeImgView;
    __weak IBOutlet UIImageView *fourImgView;
    
    NSInteger chooseIndex;
}

@property (nonatomic, strong) NSMutableArray *deviceList;

@end

@implementation KHJMutilScreenVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentDecorderType = TTDecorde_mutli;
    if (mutliDeviceIDList) {
        [mutliDeviceIDList addObject:@""];
        [mutliDeviceIDList addObject:@""];
        [mutliDeviceIDList addObject:@""];
        [mutliDeviceIDList addObject:@""];
    }
    else {
        mutliDeviceIDList = [NSMutableArray array];
    }
    [self addDeviceNoti];
}

- (void)addDeviceNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceStatus:) name:noti_onStatus_KEY object:nil];
}

- (void)getDeviceStatus:(NSNotification *)noti
{
    NSDictionary *body      = (NSDictionary *)noti.object;
    NSString *deviceID      = KHJString(@"%@",body[@"deviceID"]);
    NSString *deviceStatus  = KHJString(@"%@",body[@"deviceStatus"]);
    if ([deviceStatus isEqualToString:@"0"]) {
        TTWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf.deviceList containsObject:deviceID]) {
                [weakSelf.deviceList addObject:deviceID];
                [weakSelf.view makeToast:KHJLocalizedString(@"caAdNewDev_", nil)];
            }
        });
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    naviBtn.hidden  = !naviBtn.hidden;
    naviView.hidden = !naviView.hidden;
}

- (void)viewWillDisappear:(BOOL)animated
{
    currentDecorderType = TTDecorder_none;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    /* 显示多个视频 */
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.canLandscape = NO;
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.initMutliDecorder = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti_onStatus_KEY object:nil];
    
    // 停止播放视频
    [mutliDeviceIDList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[KHJDeviceManager sharedManager] stopGetVideo_with_deviceID:obj resultBlock:^(NSInteger code) {}];
    }];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    /* 显示多个视频 */
    AppDelegate *appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.canLandscape   = YES;
    [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

/* 是否可以旋转 */
- (BOOL)shouldAutorotate
{
    return YES;
}

- (IBAction)btn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addDeviceBtnAction:(UIButton *)sender
{
    chooseIndex = sender.tag;
    NSArray *passDeviceList = [self.deviceList copy];
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"adDev_", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    TTWeakSelf
    for (int i = 0; i < passDeviceList.count; i++) {
        UIAlertAction *config = [UIAlertAction actionWithTitle:passDeviceList[i]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf chooseItemWith:i];
        }];
        [alertview addAction:config];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)chooseItemWith:(NSInteger)row
{
    NSString *deviceID = self.deviceList[row];
    [mutliDeviceIDList replaceObjectAtIndex:chooseIndex withObject:deviceID];
    if (chooseIndex == 0)
        oneImgView.alpha = 1;
    else if (chooseIndex == 1)
        twoImgView.alpha = 1;
    else if (chooseIndex == 2)
        threeImgView.alpha = 1;
    else if (chooseIndex == 3)
        fourImgView.alpha = 1;
    if (!self.initMutliDecorder) {
        self.initMutliDecorder = YES;
    }
    TTWeakSelf
    [[KHJDeviceManager sharedManager] startGetVideo_with_deviceID:deviceID quality:1 resultBlock:^(NSInteger code) {
        [weakSelf.deviceList removeObject:deviceID];
    }];
}

#pragma MARK - H26xHwDecoderDelegate

- (void)getImageWith:(UIImage * _Nullable)image imageSize:(CGSize)imageSize deviceID:(NSString *)deviceID
{
    NSInteger index = [mutliDeviceIDList indexOfObject:deviceID];
    switch (index) {
        case 0:
            oneImgView.image = image;
            break;
        case 1:
            twoImgView.image = image;
            break;
        case 2:
            threeImgView.image = image;
            break;
        case 3:
            fourImgView.image = image;
            break;
        default:
            break;
    }
}

#pragma mark -

- (NSMutableArray *)deviceList
{
    if (!_deviceList) {
        _deviceList = [NSMutableArray arrayWithArray:_list];
    }
    return _deviceList;
}

@end
