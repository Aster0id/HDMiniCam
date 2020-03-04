//
//  KHJRecordListVC_Three.m
//  HDMiniCam
//
//  Created by khj888 on 2020/3/4.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJRecordListVC_Three.h"
#import "KHJCollectionViewCell_three.h"

@interface KHJRecordListVC_Three ()

{
    __weak IBOutlet UICollectionView *collectionView;
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
    self.titleLab.text = self.info.deviceName;
    self.videoList = [[[KHJHelpCameraData sharedModel] getmp4VideoArray_with_deviceID:self.info.deviceID] copy];
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self addCollectionView];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(100, 70);
    layout.minimumLineSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionView.collectionViewLayout = layout;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"KHJCollectionViewCell_three" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"KHJCollectionViewCell_three"];
    [self.view addSubview:collectionView];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierCell = @"KHJPicture_oneCell";
    KHJCollectionViewCell_three *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierCell forIndexPath:indexPath];
    cell.tag = indexPath.row + FLAG_TAG;
    return cell;
}


@end
