//
//  TTMutilPlayerViewController.m
//  SuperIPC
//
//  Created by kevin on 2020/3/9.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTMutilPlayerViewController.h"
#import "AppDelegate.h"
#import "TTFirmwareInterface_API.h"

#pragma mark - 设备列表
extern NSMutableArray *mutliArr;
#pragma mark - 当前解码类型
extern TTDecordeType decoderType;

@interface TTMutilPlayerViewController ()
<
H264_H265_VideoDecoderDelegate
>
{
    __weak IBOutlet UIView *naviView;
    __weak IBOutlet UIButton *naviBtn;
}

@property (nonatomic, assign) NSInteger selectItems;

@property (weak, nonatomic) IBOutlet UIImageView *upLeftPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *upRightPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *downLeftPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *downRightPlayer;

@property (nonatomic, strong) NSMutableArray *onlineArr;

@end

@implementation TTMutilPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    decoderType = TTDecorde_moreLive;
    if (mutliArr) {
        for (int i = 0; i < 4; i++) {
            [mutliArr addObject:@""];
        }
    }
    else
        mutliArr = [NSMutableArray array];

    [self addDeviceNoti];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 多屏旋转
    [self gotoMutliScreen];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self backToOtherUI];
    [super viewWillDisappear:animated];
}

- (void)backToOtherUI
{
    [self turnAround];
    [self removeNoti];
    [self releaseSource];
}

- (void)turnAround
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.canLandscape = NO;
    [UIDevice TTurnAroundDirection:UIInterfaceOrientationPortrait];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)removeNoti
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TT_onStatus_noti_KEY object:nil];
}

- (void)releaseSource
{
    self.initMutliDecorder = NO;
    decoderType = TTDecorder_none;
#pragma mark - 停止播放视频
    [mutliArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[TTFirmwareInterface_API sharedManager] stopGetVideo_with_deviceID:obj reBlock:^(NSInteger code) {}];
    }];
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
    _selectItems = sender.tag;
    NSArray *passDeviceList = [self.onlineArr copy];
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:TTLocalString(@"adDev_", nil)
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    TTWeakSelf
    for (int i = 0; i < passDeviceList.count; i++) {
        UIAlertAction *config = [UIAlertAction actionWithTitle:passDeviceList[i] style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf selectItemAndIndex:i];
        }];
        [alertview addAction:config];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cacel_", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)selectItemAndIndex:(NSInteger)index
{
    NSString *deviceID = self.onlineArr[index];
    [mutliArr replaceObjectAtIndex:_selectItems withObject:deviceID];
    if (_selectItems == 0)
        _upLeftPlayer.alpha = 1;
    else if (_selectItems == 1)
        _upRightPlayer.alpha = 1;
    else if (_selectItems == 2)
        _downLeftPlayer.alpha = 1;
    else if (_selectItems == 3)
        _downRightPlayer.alpha = 1;
    if (!self.initMutliDecorder) {
        self.initMutliDecorder = YES;
    }
    TTWeakSelf
    [[TTFirmwareInterface_API sharedManager] startGetVideo_with_deviceID:deviceID quality:1 reBlock:^(NSInteger code) {
        if (code >= 0) {
            [weakSelf.onlineArr removeObject:deviceID];
        }
    }];
}

#pragma mark -

- (NSMutableArray *)onlineArr
{
    if (!_onlineArr) {
        _onlineArr = [NSMutableArray arrayWithArray:_list];
    }
    return _onlineArr;
}

#pragma mark - Notification

- (void)addDeviceNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceStatus:) name:TT_onStatus_noti_KEY object:nil];
}

#pragma mark - Notification Action

- (void)getDeviceStatus:(NSNotification *)noti
{
    NSDictionary *body = (NSDictionary *)noti.object;
    NSString *deviceID = TTStr(@"%@",body[@"deviceID"]);
    NSString *deviceStatus = TTStr(@"%@",body[@"deviceStatus"]);
    if ([deviceStatus isEqualToString:@"0"]) {
        TTWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf.onlineArr containsObject:deviceID]) {
                [weakSelf.onlineArr addObject:deviceID];
                [weakSelf.view makeToast:TTLocalString(@"caAdNewDev_", nil)];
            }
        });
    }
}

#pragma mark - system Action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    naviBtn.hidden  = !naviBtn.hidden;
    naviView.hidden = !naviView.hidden;
}

#pragma mark - 多屏旋转
- (void)gotoMutliScreen
{
    [UIApplication sharedApplication].statusBarHidden = YES;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.canLandscape = YES;
    [UIDevice TTurnAroundDirection:UIInterfaceOrientationLandscapeRight];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma MARK - H264_H265_VideoDecoderDelegate

- (void)getImageWith:(UIImage * _Nullable)image imageSize:(CGSize)imageSize deviceID:(NSString *)deviceID
{
    if ([mutliArr indexOfObject:deviceID] == 0)
        _upLeftPlayer.image = image;
    else if ([mutliArr indexOfObject:deviceID] == 1)
        _upRightPlayer.image = image;
    else if ([mutliArr indexOfObject:deviceID] == 2)
        _downLeftPlayer.image = image;
    else if ([mutliArr indexOfObject:deviceID] == 3)
        _downRightPlayer.image = image;
}

@end

