//
//  KHJRecordListVC_Three.m
//  HDMiniCam
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJRecordListVC_Three.h"
#import "KHJCollectionViewCell_three.h"
#import <AVKit/AVKit.h>

@interface KHJRecordListVC_Three ()<KHJCollectionViewCell_threeDelegate>

{
    __weak IBOutlet UICollectionView *collectionView;
    BOOL delete;
    BOOL isDeleting;
    UIButton *rightBtn;
}

@property (nonatomic, strong) NSMutableArray *videoList;

@end

@implementation KHJRecordListVC_Three

- (NSMutableArray *)videoList
{
    if (!_videoList) {
        _videoList = [NSMutableArray array];
    }
    return _videoList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeApperance];
    [self customizeDataSource];
}

- (void)customizeApperance
{
    self.titleLab.text = self.date;
    [self addRightButton];
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self addCollectionView];
}

- (void)customizeDataSource
{
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *array = [NSArray array];
        if (self.currentIndex == 0) {
            array = [[[TTFileManager sharedModel] get_live_record_VideoArray_with_deviceID:self.info.deviceID] copy];
        }
        else if (self.currentIndex == 1) {
            array = [[[TTFileManager sharedModel] get_reback_record_videoArray_with_deviceID:self.info.deviceID] copy];
        }
        for (int i = 0; i < array.count; i++) {
            NSString *videoUrl = array[i];
            if ([videoUrl containsString:weakSelf.date]) {
                [weakSelf.videoList addObject:videoUrl];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->collectionView reloadData];
        });
    });
}

- (void)addRightButton
{
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0,0,44,44);
    [rightBtn setTitle:KHJLocalizedString(@"edit_", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:TTCommon.appMainColor forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem  = rightItem;
}

- (void)editAction
{
    delete = !delete;
    if (delete) {
        [rightBtn setTitle:KHJLocalizedString(@"finsh_", nil) forState:UIControlStateNormal];
    }
    else {
        [rightBtn setTitle:KHJLocalizedString(@"edit_", nil) forState:UIControlStateNormal];
    }
    [collectionView reloadData];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake((SCREEN_WIDTH - 40)/3.0, (SCREEN_WIDTH - 40)/3.0);
    layout.minimumLineSpacing = 10;
    collectionView.collectionViewLayout = layout;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"KHJCollectionViewCell_three" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"KHJCollectionViewCell_three"];
    [self.view addSubview:collectionView];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.videoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierCell = @"KHJCollectionViewCell_three";
    KHJCollectionViewCell_three *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierCell forIndexPath:indexPath];
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = UIColorFromRGB(0xf5f5f5).CGColor;
    
    cell.delegate = self;
    cell.deleteBtn.hidden = !delete;
    cell.tag = indexPath.row + FLAG_TAG;
    NSString *name = self.videoList[indexPath.row];
    
    NSString *path = @"";
    if (self.currentIndex == 0) {
        path = [[TTFileManager sharedModel] get_live_recordVideo_DocPath_with_deviceID:self.info.deviceID];
    }
    else if (self.currentIndex == 1) {
        path = [[TTFileManager sharedModel] get_reback_recordVideo_DocPath_with_deviceID:self.info.deviceID];
    }
    NSString *dir   = KHJString(@"%@/%@",path,name);
    cell.videoImgView.image = [self getScreenShotImageFromVideoPath:dir];
    
    NSDictionary *infoDict = [self getFileInfo:dir];
    NSDate *start   = infoDict[NSFileCreationDate];
    NSDate *end     = infoDict[NSFileModificationDate];
    
    long long startTimestamp    = [self getDateTimeTOMilliSeconds:start];
    long long endTimestamp      = [self getDateTimeTOMilliSeconds:end];
    long long time = endTimestamp - startTimestamp;
    
    int hour = (int)time / 3600;
    int min  = (int)(time - hour * 3600) / 60;
    int sec  = (int)(time - hour * 3600 - min * 60);
    if (hour > 0) {
        cell.videoTimeLab.text = KHJString(@"%02d:%02d:%02d", hour, min, sec);
    }
    else {
        cell.videoTimeLab.text = KHJString(@"%02d:%02d", min, sec);
    }
    return cell;
}


/// 获取视频预览图
/// @param filePath 视频路径
- (UIImage *)getScreenShotImageFromVideoPath:(NSString *)filePath
{
    UIImage *shotImage;
    NSURL *fileURL      = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset   = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}

- (NSDictionary*)getFileInfo:(NSString *)path
{
    NSError *error;
    NSDictionary *reslut =  [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (error) {
        NSLog(@"getFileInfo Failed:%@",[error localizedDescription]);
    }
    return reslut;
}

- (long long)getDateTimeTOMilliSeconds:(NSDate *)datetime
{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    NSLog(@"转换的时间戳 = %f",interval);
    long long totalMilliseconds = interval;
    NSLog(@"totalMilliseconds = %llu",totalMilliseconds);
    return totalMilliseconds;
}

#pragma mark - KHJCollectionViewCell_threeDelegate

- (void)chooseItemWith:(NSInteger)row
{
    if (isDeleting) {
        return;
    }
    NSString *name = self.videoList[row];
    NSString *path = @"";
    if (self.currentIndex == 0) {
        path = [[TTFileManager sharedModel] get_live_recordVideo_DocPath_with_deviceID:self.info.deviceID];
    }
    else if (self.currentIndex == 1) {
        path = [[TTFileManager sharedModel] get_reback_recordVideo_DocPath_with_deviceID:self.info.deviceID];
    }
    AVPlayerViewController * av = [[AVPlayerViewController alloc] init];
    av.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:KHJString(@"%@/%@",path,name)]];
    [self presentViewController:av animated:YES completion:^{}];
}

- (void)deleteItemWith:(NSInteger)row
{
    if (isDeleting) {
        return;
    }
    isDeleting = YES;
    [[TTHub shareHub] showText:@"dltFailing_" addToView:[[UIApplication sharedApplication] keyWindow]];
    NSString *name = self.videoList[row];
    NSString *path = @"";
    if (self.currentIndex == 0) {
        path = [[TTFileManager sharedModel] get_live_recordVideo_DocPath_with_deviceID:self.info.deviceID];
    }
    else if (self.currentIndex == 1) {
        path = [[TTFileManager sharedModel] get_reback_recordVideo_DocPath_with_deviceID:self.info.deviceID];
    }
    NSString *dir = KHJString(@"%@/%@",path,name);
    BOOL success = [[TTFileManager sharedModel] delete_videoFile_With_path:dir];
    
    if (success) {
        [self.videoList removeObjectAtIndex:row];
        [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
        
        NSInteger tag = 0;
        for (KHJCollectionViewCell_three *cell in collectionView.visibleCells) {
            cell.tag = tag + FLAG_TAG;
            TLog(@"cell.tag = %ld",(long)tag);
            tag++;
        }
        isDeleting = NO;
        [TTHub shareHub].hud.hidden = YES;
    }
    else {
        [self.view makeToast:KHJLocalizedString(@"dltFail_", nil)];
        isDeleting = NO;
        [TTHub shareHub].hud.hidden = YES;
    }
}

@end
