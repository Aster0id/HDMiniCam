//
//  KHJPictureListVC.m

//
//  Created by kevin on 2018/6/5.


#import "KHJPictureListVC.h"
#import "KHJPicture_oneCell.h"
#import "AIPhotoZoom.h"
#import "KHJHadBindDeviceVC.h"
//#import "AISDCard_VideoPlayerVC.h"
//#import "AIDeviceManager.h"

@interface KHJPictureListVC ()<UIScrollViewDelegate, UICollectionViewDataSource,KHJPicture_oneCellDelegate>
{
    NSInteger scrollHeight;//scroll高度
    NSInteger totalNumber;//总共所有的视频或者图片个数
    NSMutableArray *imagePathArr;//保存所有路径
    
    __weak IBOutlet UICollectionView *collectionView;
}

@property (strong, nonatomic)UIScrollView *scroll_one;

@property (weak, nonatomic) IBOutlet UILabel *imageContentSizeLab;

@property (assign, nonatomic) NSInteger currenDeleteIndex;
//保存可见的视图
@property (nonatomic, strong) NSMutableSet * visibleImageViews;
//保存可重用的视图
@property (nonatomic, strong) NSMutableSet * reusedImageViews;

@end

@implementation KHJPictureListVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        imagePathArr        = [NSMutableArray array];
        _Datadic            = [[NSMutableDictionary alloc] init];
        _visibleImageViews  = [[NSMutableSet alloc] initWithCapacity:0];
        _reusedImageViews   =[[NSMutableSet alloc] initWithCapacity:0];
    }
    return self;
}

- (UIScrollView *)scroll_one
{
    if (!_scroll_one) {
        _scroll_one = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, scrollHeight)];
        _scroll_one.pagingEnabled = YES;
        _scroll_one.showsVerticalScrollIndicator = NO;
        _scroll_one.showsHorizontalScrollIndicator = NO;
        _scroll_one.delegate = self;
        _scroll_one.contentSize = CGSizeMake(imagePathArr.count * SCREEN_WIDTH, scrollHeight);
    }
    return _scroll_one;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNoti];
    scrollHeight = SCREEN_HEIGHT - 120 - Height_TabBar - 44;
    [imagePathArr addObjectsFromArray:[[KHJHelpCameraData sharedModel] getAllFile]];
    totalNumber = imagePathArr.count;
    [self.view addSubview:self.scroll_one];
    [self.view sendSubviewToBack:self.scroll_one];
    [self addCollectionView];

    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self->imagePathArr.count > 0) {
            NSMutableArray *arr1 = [NSMutableArray array];
            for (NSString *imagePth  in self->imagePathArr) {
                NSString *imageName  = [[[imagePth componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"-"].lastObject componentsSeparatedByString:@"."][0];
                [arr1 addObject:imageName];
            }
            NSArray *array = [[KHJCalculate bubbleDescendingOrderSortWithArray:arr1] mutableCopy];
            NSArray *array2 = [self->imagePathArr copy];
            [self->imagePathArr removeAllObjects];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *string = KHJString(@"%@",obj);
                [array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj containsString:string]) {
                        [self->imagePathArr addObject:obj];
                        *stop = YES;
                    }
                }];
            }];
            CLog(@"imagePathArr = %@",self->imagePathArr);
            [arr1 removeAllObjects];
            for (NSString *imagePth  in self->imagePathArr) {
                NSArray *aa  = [imagePth componentsSeparatedByString:@"/"];
                NSString *imageName = KHJString(@"%@/%@",aa[1],aa[2]);
                [arr1 addObject:imageName];
            }
            self->imagePathArr = [arr1 mutableCopy];
            CLog(@"imagePathArr = %@",self->imagePathArr);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showImageViewAtIndex:weakSelf.currentIndex];
                [weakSelf setShowPage];
            });
        }
    });
}

- (void)addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadScrollView_CollectionView) name:@"reloadPictureVC_noti" object:nil];
}

- (void)reloadScrollView_CollectionView
{
    [imagePathArr removeAllObjects];
    [imagePathArr addObjectsFromArray:[[KHJHelpCameraData sharedModel] getAllFile]];
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self->imagePathArr.count > 0) {
            NSMutableArray *arr1 = [NSMutableArray array];
            for (NSString *imagePth  in self->imagePathArr) {
                NSString *imageName  = [[[imagePth componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"-"].lastObject componentsSeparatedByString:@"."][0];
                [arr1 addObject:imageName];
            }
            NSArray *array = [[KHJCalculate bubbleDescendingOrderSortWithArray:arr1] mutableCopy];
            NSArray *array2 = [self->imagePathArr copy];
            [self->imagePathArr removeAllObjects];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *string = KHJString(@"%@",obj);
                [array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj containsString:string]) {
                        [self->imagePathArr addObject:obj];
                        *stop = YES;
                    }
                }];
            }];
            [arr1 removeAllObjects];
            for (NSString *imagePth  in self->imagePathArr) {
                NSArray *aa  = [imagePth componentsSeparatedByString:@"/"];
                NSString *imageName = KHJString(@"%@/%@",aa[1],aa[2]);
                [arr1 addObject:imageName];
            }
            self->imagePathArr = [arr1 mutableCopy];
            self->totalNumber = arr1.count;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.currentIndex = 0;
                [weakSelf showImageViewAtIndex:weakSelf.currentIndex];
                [weakSelf setShowPage];
                [self->collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                             atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            });
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [collectionView reloadData];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - 构建大图 - 继承 APPhotoZoom 视图

- (void)showImageViewAtIndex:(NSInteger)index
{
    // 先从复用池中找 imageView
    AIPhotoZoom *ZoomView = [self.reusedImageViews anyObject];
    if (!ZoomView) {
        ZoomView = [[AIPhotoZoom alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.scroll_one.frame.size.height)];
        ZoomView.imageNormalWidth = SCREEN_WIDTH;
        ZoomView.imageNormalHeight = 250;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [ZoomView addGestureRecognizer:tap];
    }
    else {
        // 有的话就 把 imageView 移除
        [self.reusedImageViews removeObject:ZoomView];
    }
    //在这里可以配置imageview
    CGRect bounds = self.scroll_one.bounds;
    CGRect imageViewFrame = bounds;
    imageViewFrame.origin.x = CGRectGetWidth(bounds) * index;
    ZoomView.tag = index;
    ZoomView.frame = imageViewFrame;
    NSString *path = imagePathArr[index];
    if([path containsString:@".mp4"]){
        
//        NSFileManager *fileManager =  [NSFileManager defaultManager];
//        NSString *path_document = NSHomeDirectory();
//        NSString *pString = [NSString stringWithFormat:@"/Documents/MP4Image"];
//        NSString *imagePath = [path_document stringByAppendingString:pString];
//
//        BOOL existed = [fileManager fileExistsAtPath:imagePath];
//        if (!existed) {
//            [fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
//        }
//        NSString *outFileName = [[path componentsSeparatedByString:@"_"] lastObject];
//        outFileName = [imagePath stringByAppendingPathComponent:outFileName];
//
//        UIImage *image = [AIDeviceManager getCoverImage:path outPutName:outFileName width:(SCREEN_WIDTH - 20)/3.0 height:(SCREEN_WIDTH - 20)/3.0];
//        ZoomView.imageView.image = image;
//        ZoomView.needScale = NO;
//        [ZoomView showCover];
    }
    else {
        ZoomView.needScale = YES;
        path = KHJString(@"%@/%@",[[KHJHelpCameraData sharedModel] getTakeCameraDocPath_deviceID:@""],imagePathArr[index]);;
        ZoomView.imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
        [ZoomView showNoCover];
    }
    ZoomView.zoomScale = 1;
    [ZoomView pictureZoomWithScale:1.0];
    //把刚才从reusedImageViews移除的对象添加到visibleImageViews对象中
    [self.visibleImageViews addObject:ZoomView];
    [self.scroll_one addSubview:ZoomView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scroll_one) {
        [self showImages];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scroll_one) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _currentIndex = currentPage;
        _showLabel.text = [NSString stringWithFormat:@"%d/%ld",currentPage+1,(long)totalNumber];
        [self reloadCurrentImageSize:_currentIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
        CLog(@"indexPath.row = %ld",indexPath.row);
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void)showImages
{
    //获取当前显示范围内的图片的索引
    CGRect bounds = self.scroll_one.bounds;
    CGFloat minX = CGRectGetMinX(bounds);
    CGFloat maxX = CGRectGetMaxX(bounds);
    CGFloat width = CGRectGetWidth(bounds);
    //第一个索引
    NSInteger firstIndex = (NSInteger)floor(minX / width);
    //最后一个索引
    NSInteger lastIndex = (NSInteger)floor(maxX / width);
    //处理越界情况
    if (firstIndex < 0) firstIndex = 0;
    if (lastIndex >= imagePathArr.count) {
        lastIndex = imagePathArr.count - 1;
    }
    //回收不再显示的imageview
    NSInteger imageViewIndex = 0;
    for (AIPhotoZoom *ZoomView in self.visibleImageViews) {
        imageViewIndex = ZoomView.tag;
        //不在显示范围内的
        if (imageViewIndex < firstIndex || imageViewIndex > lastIndex) {
            //添加到复用池中
            [self.reusedImageViews addObject:ZoomView];
            [ZoomView removeFromSuperview];
        }
    }
    //取出复用池中的图片
    [self.visibleImageViews minusSet:self.reusedImageViews];
    //是否需要显示新的视图
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        BOOL isShow = NO;
        //遍历可见数据的对象
        for (AIPhotoZoom *ZoomView in self.visibleImageViews) {
            //当前显示的index
            if (ZoomView.tag == index) {
                isShow = YES;
            }
        }
        if (!isShow) {
            [self showImageViewAtIndex:index];
        }
    }
}

#pragma mark - 设置滚动视图

- (void)setShowPage
{
    self.scroll_one.contentSize = CGSizeMake(totalNumber * (int)SCREEN_WIDTH, 0);
    if (_currentIndex == totalNumber) {
        _showLabel.text = KHJString(@"%ld/%ld",(long)_currentIndex,(long)totalNumber);
        [self.scroll_one setContentOffset:CGPointMake(SCREEN_WIDTH *(_currentIndex - 1), 0)];
        [self reloadCurrentImageSize:_currentIndex - 1];
    }
    else {
        _showLabel.text = KHJString(@"%ld/%ld",_currentIndex + 1,(long)totalNumber);
        [self.scroll_one setContentOffset:CGPointMake(SCREEN_WIDTH *_currentIndex, 0)];
        [self reloadCurrentImageSize:_currentIndex];
    }
}

- (void)reloadCurrentImageSize:(NSInteger)index
{
    NSString *path = imagePathArr[index];
    self.imageContentSizeLab.text = [KHJCalculate valueImageSize:path];
}

//如果是视频点击进入下一个界面播放视频，图片则不变，但是图片需要支持放大手势

- (void)tapImageView:(UITapGestureRecognizer *)tap
{
    AIPhotoZoom *zoomView = (AIPhotoZoom *)tap.view;
    NSString *sPath = imagePathArr[zoomView.tag];
    if ([sPath containsString:@".mp4"]) {
//        AISDCard_VideoPlayerVC *playView = [[AISDCard_VideoPlayerVC alloc] init];;
//        playView.urlPath = sPath;
//        [self.navigationController pushViewController:playView animated:YES];
    }
}

- (IBAction)deleteVedio:(UIButton *)sender
{
    //删除图片或者视频
    //删除字典中的路径，同时删除本地沙盒图片
    [self showAlert:imagePathArr[_currentIndex]];
    CLog(@"deleteVedio");
}

- (void)showAlert:(NSString *)pathStr
{
    WeakSelf
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"dltFile_", nil) message:KHJLocalizedString(@"sureDlt_", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        BOOL ret = [[KHJHelpCameraData sharedModel] DeleateFileWithPath:pathStr];
        if (ret) {
            CLog(@"删除成功");
            if (weakSelf.deleteBlock) {
                weakSelf.deleteBlock(pathStr);
            }
            [self->imagePathArr removeObject:pathStr];
            [weakSelf setCurrentIndex];
            [[KHJToast share] showToastActionWithToastType:_SuccessType toastPostion:_CenterPostion tip:@""
                                                   content:KHJLocalizedString(@"dltSuc_", nil)];
        }
        else {
            CLog(@"删除失败");
            [[KHJToast share] showToastActionWithToastType:_ErrorType toastPostion:_CenterPostion tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"dltFail_", nil)];
        }
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)setCurrentIndex
{
    self.scroll_one.contentSize = CGSizeMake(imagePathArr.count*(int)SCREEN_WIDTH, 0);
    totalNumber --;
    if (totalNumber > 0) {
        if (_currentIndex > 0) {
            [self showImageViewAtIndex:(_currentIndex-1)];
            _currentIndex --;
        }
        else {
            [self showImageViewAtIndex:_currentIndex];
        }
        [self setShowPage];
        [self showImages];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    [collectionView registerNib:[UINib nibWithNibName:@"KHJPicture_oneCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"KHJPicture_oneCell"];
    [self.view addSubview:collectionView];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imagePathArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierCell = @"KHJPicture_oneCell";
    KHJPicture_oneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierCell forIndexPath:indexPath];
    cell.delegate = self;
    cell.tag = indexPath.row + FLAG_TAG;
    WeakSelf
    cell.block = ^(NSString *path) {
        NSInteger row = [self->imagePathArr indexOfObject:path];
        weakSelf.currentIndex = row;
        [weakSelf.scroll_one setContentOffset:CGPointMake(row*SCREEN_WIDTH, 0) animated:YES];
    };
    cell.path = imagePathArr[indexPath.row];
    NSString *path = KHJString(@"%@/%@",[[KHJHelpCameraData sharedModel] getTakeCameraDocPath_deviceID:@""],imagePathArr[indexPath.row]);
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    cell.imageView.image = image;
    return cell;
}

- (IBAction)chooseDevice:(id)sender
{
    [self shareClick];
}

- (void)shareClick
{
    NSString *path = KHJString(@"%@/%@",[[KHJHelpCameraData sharedModel] getTakeCameraDocPath_deviceID:@""],imagePathArr[_currentIndex]);
    NSURL *urlToShare = [NSURL fileURLWithPath:path];
    NSArray *activityItems = [[NSArray alloc] initWithObjects:urlToShare,nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    //不出现在活动项目
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList];
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray * returnedItems, NSError * activityError) {
        CLog(@"activityType :%@", activityType);
        if (completed){
            CLog(@"completed");
        }
        else {
            CLog(@"cancel");
        }
    };
    
    // 初始化completionHandler，当post结束之后（无论是done还是cancell）该blog都会被调用
    activityVC.completionWithItemsHandler = myBlock;
    UIViewController * rootVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc presentViewController:activityVC animated:TRUE completion:nil];
}


#pragma mark - KHJPicture_oneCellDelegate

- (void)longPressWith:(NSString *)path
{
    NSInteger row = [imagePathArr indexOfObject:path];
    CLog(@"长按 row = %ld",row);
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"isDltPic_", nil) message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel
                                                   handler:nil];
    WeakSelf
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deletePic:row];
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)deletePic:(NSInteger)row
{
    NSString *path = KHJString(@"%@/%@",[[KHJHelpCameraData sharedModel] getTakeCameraDocPath_deviceID:@""],imagePathArr[row]);
    if ([[KHJHelpCameraData sharedModel] DeleateFileWithPath:path]) {
        [self deleteImageWith:row];
        [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
    }
}

- (void)deleteImageWith:(NSInteger)row
{
    [imagePathArr removeObjectAtIndex:row];
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self->imagePathArr.count > 0) {
            NSMutableArray *arr1 = [NSMutableArray array];
            for (NSString *imagePth  in self->imagePathArr) {
                NSString *imageName  = [[[imagePth componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"-"].lastObject componentsSeparatedByString:@"."][0];
                [arr1 addObject:imageName];
            }
            NSArray *array = [[KHJCalculate bubbleDescendingOrderSortWithArray:arr1] mutableCopy];
            NSArray *array2 = [self->imagePathArr copy];
            [self->imagePathArr removeAllObjects];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *string = KHJString(@"%@",obj);
                [array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj containsString:string]) {
                        [self->imagePathArr addObject:obj];
                        *stop = YES;
                    }
                }];
            }];
            [arr1 removeAllObjects];
            for (NSString *imagePth  in self->imagePathArr) {
                NSArray *aa  = [imagePth componentsSeparatedByString:@"/"];
                NSString *imageName = @"";
                if (aa.count == 3) {
                    imageName = KHJString(@"%@/%@",aa[1],aa[2]);
                }
                else {
                    imageName = imagePth;
                }
                [arr1 addObject:imageName];
            }
            self->imagePathArr = [arr1 mutableCopy];
            self->totalNumber = arr1.count;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self->imagePathArr.count == row) {
                    weakSelf.currentIndex = row - 1;
                }
                else {
                    weakSelf.currentIndex = row;
                }
                [weakSelf showImageViewAtIndex:weakSelf.currentIndex];
                [weakSelf setShowPage];
                [self->collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0]
                                             atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (AIPhotoZoom *zoom in self.scroll_one.subviews) {
                    [zoom removeFromSuperview];
                }
            });
        }
    });
}

@end








