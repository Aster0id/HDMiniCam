//
//  TTZoomPictureListVC.m
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTZoomPictureListVC.h"
#import "TTZoomPictureCell.h"
#import "TTSinglePictureScale.h"

static NSString *cellID = @"TTZoomPictureCell";

@interface TTZoomPictureListVC ()
<
UIScrollViewDelegate,
UICollectionViewDataSource,
TTZoomPictureCellDelegate
>

{
    // 当前第几张图片
    NSInteger imageIndex;
    // 图片总数
    NSInteger imageNumber;
    // 图片所有路径
    NSMutableArray *imagePathArr;
    // 可重用 scaleView
    NSMutableSet * imgViewScaleViewArray;
    // 可见 scaleView
    NSMutableSet * scaleVisiableImgViewArray;
    // collectionView
    __weak IBOutlet UICollectionView *bottomCollectionView;
    // 图片 scrollView
    UIScrollView *imageScrollView;
}

@end

@implementation TTZoomPictureListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
}

- (void)customizeDataSource
{
    imagePathArr                = [NSMutableArray array];
    scaleVisiableImgViewArray   = [[NSMutableSet alloc] init];
    imgViewScaleViewArray       = [[NSMutableSet alloc] init];
    [imagePathArr addObjectsFromArray:[[TTFileManager sharedModel] getAllVideoAndPictureFile]];
    imageNumber                 = imagePathArr.count;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadScrollView_CollectionView)
                                                 name:@"reloadPictureVC_noti"
                                               object:nil];
}

- (void)customizeAppearance
{
    // 添加 UIScrollView
    [self addUIScrollView];
    // 添加 UICollectionView
    [self addUICollectionView];
    // 加载图片数组
    [self loadAllImageView];
}

#pragma mark - 添加ScrollView

- (void)addUIScrollView
{
    imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,
                                                                TTNavBarHeight,
                                                                SCREEN_WIDTH,
                                                                SCREEN_HEIGHT - 120 - TTTabBarHeight - TTNavBarHeight)];
    imageScrollView.delegate = self;
    imageScrollView.pagingEnabled = YES;
    imageScrollView.showsVerticalScrollIndicator = NO;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.contentSize = CGSizeMake(imagePathArr.count * SCREEN_WIDTH,
                                         SCREEN_HEIGHT - 120 - TTTabBarHeight - TTNavBarHeight);
    [self.view addSubview:imageScrollView];
    [self.view sendSubviewToBack:imageScrollView];
}

#pragma mark - 添加 UICollectionView

- (void)addUICollectionView
{
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize                     = CGSizeMake(100, 70);
    layout.minimumLineSpacing           = 10;
    layout.scrollDirection              = UICollectionViewScrollDirectionHorizontal;
    bottomCollectionView.showsVerticalScrollIndicator     = NO;
    bottomCollectionView.showsHorizontalScrollIndicator   = NO;
    bottomCollectionView.collectionViewLayout             = layout;
    [bottomCollectionView registerNib:[UINib nibWithNibName:cellID bundle:[NSBundle mainBundle]]
     forCellWithReuseIdentifier:cellID];
    [self.view addSubview:bottomCollectionView];
}

#pragma mark - 加载图片数组

- (void)loadAllImageView
{
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if (self->imagePathArr.count > 0) {
            
            [weakSelf forImagePathArrAddSomething];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loadImageViewWithIndex:self->imageIndex];
                [weakSelf getScrollViewContentSize];
            });
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [bottomCollectionView reloadData];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == imageScrollView) {
        [self loadScaleViewImages];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == imageScrollView) {
        imageIndex = floor((scrollView.contentOffset.x - scrollView.frame.size.width/2) / scrollView.frame.size.width) + 1;
        [bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:imageIndex inSection:0]
                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

#pragma mark - Action

- (IBAction)shareImageToOthers:(id)sender
{
    if (imagePathArr.count > 0 &&
        imageIndex < imagePathArr.count) {
        NSURL *urlToShare       = [NSURL fileURLWithPath:TTStr(@"%@/%@",[[TTFileManager sharedModel] getliveScreenShotWithDeviceID:@""],imagePathArr[imageIndex])];
        NSArray *activityItems  = [[NSArray alloc] initWithObjects:urlToShare,nil];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint,
                                             UIActivityTypeCopyToPasteboard,
                                             UIActivityTypeAssignToContact,
                                             UIActivityTypeSaveToCameraRoll,
                                             UIActivityTypeAddToReadingList];
        UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray * returnedItems, NSError * activityError) {};
        activityVC.completionWithItemsHandler = myBlock;
        UIViewController * rootVc = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootVc presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imagePathArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierCell = @"TTZoomPictureCell";
    TTZoomPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierCell forIndexPath:indexPath];
    cell.delegate = self;
    cell.tag = indexPath.row + FLAG_TAG;
    
    cell.block = ^(NSString *path) {

        self->imageIndex = [self->imagePathArr indexOfObject:path];
        
        [self->imageScrollView setContentOffset:CGPointMake(self->imageIndex * SCREEN_WIDTH, 0) animated:YES];
        
    };
    cell.imagePath = imagePathArr[indexPath.row];
    NSString *path = TTStr(@"%@/%@",[[TTFileManager sharedModel] getliveScreenShotWithDeviceID:@""],imagePathArr[indexPath.row]);
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    cell.showImageView.image = image;
    return cell;
}

#pragma mark - TTZoomPictureCellDelegate 长按删除

- (void)longPressWith:(NSString *)path
{
    NSInteger row = [imagePathArr indexOfObject:path];
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:TTLocalString(@"isDeletPicture_", nil) message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cacel_", nil) style:UIAlertActionStyleCancel
                                                   handler:nil];
    TTWeakSelf
    UIAlertAction *defult = [UIAlertAction actionWithTitle:TTLocalString(@"sure", nil) style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deletePic:row];
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)deletePic:(NSInteger)row
{
    NSString *path = TTStr(@"%@/%@",[[TTFileManager sharedModel] getliveScreenShotWithDeviceID:@""],imagePathArr[row]);
    if ([[TTFileManager sharedModel] deleteVideoFileWithFilePath:path]) {
        [self deleteImageWith:row];
        [bottomCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
    }
}

- (void)deleteImageWith:(NSInteger)row
{
    [imagePathArr removeObjectAtIndex:row];
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self->imagePathArr.count > 0) {
            [weakSelf forDeleteImagePathArr];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self->imagePathArr.count == row) {
                    self->imageIndex = row - 1;
                }
                else {
                    self->imageIndex = row;
                }
                [weakSelf loadImageViewWithIndex:self->imageIndex];
                [weakSelf getScrollViewContentSize];
                [self->bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self->imageIndex inSection:0]
                                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTSinglePictureScale *zoom in self->imageScrollView.subviews) {
                    [zoom removeFromSuperview];
                }
            });
        }
    });
}


#pragma mark - 刷新通知执行方法

- (void)reloadScrollView_CollectionView
{
    [imagePathArr removeAllObjects];
    [imagePathArr addObjectsFromArray:[[TTFileManager sharedModel] getAllVideoAndPictureFile]];
    
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if (self->imagePathArr.count > 0) {
            [weakSelf forImagePathArrAddSomething];
            self->imageNumber = self->imagePathArr.count;
            dispatch_async(dispatch_get_main_queue(), ^{
                self->imageIndex = 0;
                [weakSelf loadImageViewWithIndex:self->imageIndex];
                [weakSelf getScrollViewContentSize];
                [self->bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                             atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            });
        }
    });
}

#pragma mark - 设置滚动视图

- (void)getScrollViewContentSize
{
    imageScrollView.contentSize = CGSizeMake(imageNumber * SCREEN_WIDTH, 0);
    if (imageIndex == imageNumber) {
        [imageScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * (imageIndex - 1), 0)];
    }
    else {
        [imageScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * imageIndex, 0)];
    }
}


#pragma mark - 为 imagePathArr 添加数据

- (void)forImagePathArrAddSomething
{
    NSMutableArray *imageNameArray = [NSMutableArray array];
    for (NSString *imagePth  in imagePathArr) {
        NSString *imageName  = [[[imagePth componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"-"].lastObject componentsSeparatedByString:@"."][0];
        [imageNameArray addObject:imageName];
    }
    NSMutableArray *copyArr             = [NSMutableArray arrayWithArray:[[TTCommon bubbleDescendingOrderSortWithArray:imageNameArray] mutableCopy]];
    NSMutableArray *imagePathCopyArr    = [NSMutableArray arrayWithArray:imagePathArr];
    // 移除所有图片
    [imagePathArr removeAllObjects];
    // 重新添加图片
    [copyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *string = TTStr(@"%@",obj);
        [imagePathCopyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:string]) {
                [self->imagePathArr addObject:obj];
                *stop = YES;
            }
        }];
    }];
    [imageNameArray removeAllObjects];
    for (NSString *imagePth  in imagePathArr) {
        NSArray *aa  = [imagePth componentsSeparatedByString:@"/"];
        NSString *imageName = TTStr(@"%@/%@",aa[1],aa[2]);
        [imageNameArray addObject:imageName];
    }
    imagePathArr = [imageNameArray mutableCopy];
}

#pragma mark - 为 imagePathArr 删除数据逻辑操作

- (void)forDeleteImagePathArr
{
    NSMutableArray *imageNameArray = [NSMutableArray array];
    for (NSString *imagePth in imagePathArr) {
        NSString *imageName = [[[[imagePth componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"-"].lastObject componentsSeparatedByString:@"."] firstObject];
        [imageNameArray addObject:imageName];
    }
    NSMutableArray *copyArr             = [NSMutableArray arrayWithArray:[[TTCommon bubbleDescendingOrderSortWithArray:imageNameArray] mutableCopy]];
    NSMutableArray *imagePathCopyArr    = [NSMutableArray arrayWithArray:imagePathArr];
    [self->imagePathArr removeAllObjects];
    [copyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *string = TTStr(@"%@",obj);
        [imagePathCopyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:string]) {
                [self->imagePathArr addObject:obj];
                *stop = YES;
            }
        }];
    }];
    [imageNameArray removeAllObjects];
    for (NSString *imagePth  in imagePathArr) {
        NSArray *aa  = [imagePth componentsSeparatedByString:@"/"];
        NSString *imageName = @"";
        if (aa.count == 3) {
            imageName = TTStr(@"%@/%@",aa[1],aa[2]);
        }
        else {
            imageName = imagePth;
        }
        [imageNameArray addObject:imageName];
    }
    imagePathArr = [imageNameArray mutableCopy];
    imageNumber = imagePathArr.count;
}

#pragma mark - 加载视图

- (void)loadScaleViewImages
{
    CGRect bounds           = imageScrollView.bounds;
    NSInteger firstIndex    = floor(CGRectGetMinX(bounds) / CGRectGetWidth(bounds));
    NSInteger lastIndex     = floor(CGRectGetMaxX(bounds) / CGRectGetWidth(bounds));
    
    if (firstIndex < 0)
        firstIndex = 0;
    if (lastIndex >= imagePathArr.count)
        lastIndex = imagePathArr.count - 1;
    
    NSInteger imageViewIndex = 0;
    for (TTSinglePictureScale *scaleView in scaleVisiableImgViewArray) {
        imageViewIndex = scaleView.tag;
        if (imageViewIndex < firstIndex || imageViewIndex > lastIndex) {
            [imgViewScaleViewArray addObject:scaleView];
            [scaleView removeFromSuperview];
        }
    }
    
    [scaleVisiableImgViewArray minusSet:imgViewScaleViewArray];
    
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        BOOL isShow = NO;
        for (TTSinglePictureScale *scaleView in scaleVisiableImgViewArray) {
            if (scaleView.tag == index) {
                isShow = YES;
            }
        }
        if (!isShow) {
            [self loadImageViewWithIndex:index];
        }
    }
}

#pragma mark - 构建大图 - 继承 APPhotoZoom 视图

- (void)loadImageViewWithIndex:(NSInteger)index
{
    TTSinglePictureScale *scaleView = [imgViewScaleViewArray anyObject];
    if (scaleView == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, imageScrollView.frame.size.height);
        
        scaleView = [[TTSinglePictureScale alloc] initWithFrame:rect];
        
        // 缩放比
        scaleView.minimumZoomScale  = 1.0f;
        scaleView.maximumZoomScale  = 3.0f;
        
        /// 图片原始大小
        scaleView.originWidth       = SCREEN_WIDTH;
        scaleView.originHeight      = SCREEN_WIDTH * 9/16.0;
        scaleView.showsVerticalScrollIndicator       = NO;
        scaleView.showsHorizontalScrollIndicator     = NO;
    }
    else {
        // 复用池移除 scaleView
        [imgViewScaleViewArray removeObject:scaleView];
    }
    
    CGRect imageViewFrame   = imageScrollView.bounds;
    imageViewFrame.origin.x = CGRectGetWidth(imageScrollView.bounds) * index;
    
    scaleView.tag           = index;
    scaleView.frame         = imageViewFrame;
    scaleView.canScale      = YES;
    scaleView.zoomScale = 1;
    [scaleView photoBecomeZoomWithScale:1.0];
    
    scaleView.imageView.image = [[UIImage alloc] initWithContentsOfFile:TTStr(@"%@/%@",[[TTFileManager sharedModel] getliveScreenShotWithDeviceID:@""],imagePathArr[index])];
    
    [scaleVisiableImgViewArray addObject:scaleView];
    [imageScrollView addSubview:scaleView];
}


@end








