//
//  KHJPictureListVC.m

//
//  Created by kevin on 2018/6/5.


#import "KHJPictureListVC.h"
#import "KHJPicture_oneCell.h"
#import "AIPhotoZoom.h"
//#import "AISDCard_VideoPlayerVC.h"
//#import "AIDeviceManager.h"

@interface KHJPictureListVC ()<UIScrollViewDelegate, UICollectionViewDataSource>
{
    NSInteger scrollHeight;//scroll高度
    NSInteger totalNumber;//总共所有的视频或者图片个数
    NSMutableArray *tpathMarr;//保存所有路径
    NSString *currentPath;
    
    __weak IBOutlet UICollectionView *collectionView;
}


@property (strong, nonatomic)UIScrollView *scroll_one;

@property (weak, nonatomic) IBOutlet UILabel *imageContentSizeLab;

@property (assign, nonatomic) NSInteger currenDeleteIndex;
//保存可见的视图
@property (nonatomic, strong) NSMutableSet * visibleImageViews;
//保存可重用的视图
@property (nonatomic, strong) NSMutableSet * reusedImageViews;
//所有的图片
@property (nonatomic, strong) NSMutableArray * imageNames;

@end

@implementation KHJPictureListVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.Datadic = [[NSMutableDictionary alloc] init];
        tpathMarr = [NSMutableArray array];
        
        _visibleImageViews = [[NSMutableSet alloc] initWithCapacity:0];
        _reusedImageViews =[[NSMutableSet alloc] initWithCapacity:0];
        _imageNames = [[NSMutableArray alloc] initWithCapacity:0];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    #pragma mark - ！！！！！！！！！！！！修改 DataDic 总数据的传入方式
    [self add_tpathMarr];
    #pragma mark - ！！！！！！！！！！！！修改文件获取路径
    [self add_imageNames];
    [self common];
    [self addCollectionView];
}

#pragma mark - ！！！！！！！！！！！！修改 DataDic 总数据的传入方式

- (void)add_tpathMarr
{
    if (self.Datadic.count > 0) {
        //获取总个数
        NSMutableArray *keyArr = [NSMutableArray arrayWithArray:[self.Datadic allKeys]];
        [tpathMarr removeAllObjects];
        totalNumber = 0;
        NSArray *tArr = [NSArray array];
        keyArr = [KHJCalculate bubbleDescendingOrderSortWithArray:keyArr];
        keyArr = [KHJCalculate calCategoryArray:keyArr];
        for (int i = 0; i< keyArr.count ; i++) {//获取总个数
            NSString * ss = [NSString stringWithFormat:@"%@",keyArr[i]];
            tArr =  [self.Datadic objectForKey:ss];
            totalNumber += [tArr count];
            [tpathMarr addObjectsFromArray:tArr];
        }
    }
}

#pragma mark - ！！！！！！！！！！！！修改文件获取路径

- (void)add_imageNames
{
    for (int i = 0; i < totalNumber; i++) {
        NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *khjFileName = KHJString(@"KHJFileName_%@",SaveManager.userID);//关联账户
        khjFileName = [docPath stringByAppendingPathComponent:khjFileName];
        NSString * path = [tpathMarr objectAtIndex:i];
        path = [khjFileName stringByAppendingPathComponent:path];//得到完整路径
        [self.imageNames addObject:path];
    }
}

- (void)common
{
    totalNumber = 0;
    scrollHeight = SCREEN_HEIGHT - 64;
    _scroll_one = [self getShowScroll];
//    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES];
    
    if (self.imageNames.count > 0) {
        [self showImageViewAtIndex:0];
        [self setShowPage];
    }
}

#pragma mark - 构建大图 - 继承 APPhotoZoom 视图

- (void)showImageViewAtIndex:(NSInteger)index
{
    //先从复用池中找imageview
    AIPhotoZoom *ZoomView = [self.reusedImageViews anyObject];
    
    if (!ZoomView) {//没有就创建一个
        ZoomView = [[AIPhotoZoom alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _scroll_one.frame.size.height)];
        ZoomView.imageNormalWidth = SCREEN_WIDTH;
        ZoomView.imageNormalHeight = 250;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [ZoomView addGestureRecognizer:tap];
    }
    else {//有的话就 把imageview移除
        [self.reusedImageViews removeObject:ZoomView];
    }
    //在这里可以配置imageview
    CGRect bounds = self.scroll_one.bounds;
    CGRect imageViewFrame = bounds;
    imageViewFrame.origin.x = CGRectGetWidth(bounds) * index;
    ZoomView.tag = index;
    ZoomView.frame = imageViewFrame;
    NSString *path = self.imageNames[index];
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
        ZoomView.imageView.image = [[UIImage alloc] initWithContentsOfFile:path];
        [ZoomView showNoCover];
    }
    ZoomView.zoomScale = 1;
    [ZoomView pictureZoomWithScale:1.0];
    //把刚才从reusedImageViews移除的对象添加到visibleImageViews对象中
    [self.visibleImageViews addObject:ZoomView];
    [self.scroll_one addSubview:ZoomView];
}

#pragma mark - 滚动视图设置

- (UIScrollView *)getShowScroll
{
    if (_scroll_one == nil) {
        _scroll_one = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, (int)SCREEN_WIDTH, (int)scrollHeight-44)];
        _scroll_one.pagingEnabled = YES;
        _scroll_one.showsVerticalScrollIndicator = NO;
        _scroll_one.showsHorizontalScrollIndicator = NO;
        _scroll_one.delegate = self;
        _scroll_one.contentSize = CGSizeMake(self.imageNames.count*(int)SCREEN_WIDTH, (int)scrollHeight-44);
        [self.view addSubview:_scroll_one];
        [self.view sendSubviewToBack:_scroll_one];
    }
    return  _scroll_one;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self showImages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scroll_one) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _currentIndex = currentPage;
        _showLabel.text = [NSString stringWithFormat:@"%d/%ld",currentPage+1,(long)totalNumber];
        [self reloadCurrentImageSize:(_currentIndex)];
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
    if (lastIndex >= self.imageNames.count) lastIndex = self.imageNames.count - 1;
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
                NSLog(@"index111 = %ld",(long)index);
                isShow = YES;
            }
        }
        if (!isShow) {
            NSLog(@"index222 = %ld",(long)index);
            [self showImageViewAtIndex:index];
        }
    }
}

#pragma mark - 设置滚动视图

- (void)setShowPage
{
    if (_currentIndex == totalNumber) {
        _showLabel.text = KHJString(@"%ld/%ld",(long)_currentIndex,(long)totalNumber);
        [_scroll_one setContentOffset:CGPointMake(SCREEN_WIDTH *(_currentIndex-1), 0)];
        [self reloadCurrentImageSize:_currentIndex - 1];
    }
    else {
        _showLabel.text = KHJString(@"%ld/%ld",_currentIndex+1,(long)totalNumber);
        [_scroll_one setContentOffset:CGPointMake(SCREEN_WIDTH *_currentIndex, 0)];
        [self reloadCurrentImageSize:_currentIndex];
    }
}

- (void)reloadCurrentImageSize:(NSInteger)index
{
    NSString *path = self.imageNames[index];
    self.imageContentSizeLab.text = [KHJCalculate valueImageSize:path];
}

//如果是视频点击进入下一个界面播放视频，图片则不变，但是图片需要支持放大手势

- (void)tapImageView:(UITapGestureRecognizer *)tap
{
    AIPhotoZoom *zoomView = (AIPhotoZoom *)tap.view;
    NSString *sPath = self.imageNames[zoomView.tag];
    if ([sPath containsString:@".mp4"]) {
        
//        AISDCard_VideoPlayerVC *playView = [[AISDCard_VideoPlayerVC alloc] init];;
//        playView.urlPath = sPath;
//        [self.navigationController pushViewController:playView animated:YES];
    }
}
- (IBAction)deleteVedio:(UIButton *)sender {
    //删除图片或者视频
    //删除字典中的路径，同时删除本地沙盒图片
    [self showAlert:self.imageNames[_currentIndex]];
    CLog(@"deleteVedio");
}

- (void)showAlert:(NSString *)pathStr
{
    WeakSelf
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"deleteFile", nil) message:KHJLocalizedString(@"ensureDelete", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
//        BOOL ret = [[AICameraData sharedModel] DeleateFileWithPath:pathStr];
//        if (ret) {
//            CLog(@"删除成功");
//            if (weakSelf.deleteBlock) {
//                weakSelf.deleteBlock(pathStr);
//            }
//            [self.imageNames removeObject:pathStr];
//            [weakSelf setCurrentIndex];
//            [[AIToast share] showToastActionWithToastType:_SuccessType
//                                              toastPostion:_CenterPostion
//                                                       tip:@""
//                                                   content:KHJLocalizedString(@"deleteSuccess", nil)];
//        }
//        else {
//            CLog(@"删除失败");
//            [[AIToast share] showToastActionWithToastType:_ErrorType
//                                              toastPostion:_CenterPostion
//                                                       tip:KHJLocalizedString(@"tips", nil)
//                                                   content:KHJLocalizedString(@"deleteFail", nil)];
//        }
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)setCurrentIndex
{
//    _scroll_one.contentSize = CGSizeMake(self.imageNames.count*(int)SCREEN_WIDTH, 0);
//    totalNumber --;
//    if (totalNumber > 0) {
//        if (_currentIndex > 0) {
//            [self showImageViewAtIndex:(_currentIndex-1)];
//            _currentIndex --;
//        }
//        else {
//            [self showImageViewAtIndex:_currentIndex];
//        }
//        [self setShowPage];
//        [self showImages];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - chooseDevice

- (void)chooseDevice
{
    CLog(@"筛选设备");
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
    [collectionView registerNib:[UINib nibWithNibName:@"KHJPicture_oneCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:collectionView];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierCell = @"Cell";
    KHJPicture_oneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierCell forIndexPath:indexPath];
    cell.tag = indexPath.row + FLAG_TAG;
    cell.btn.backgroundColor = UIColor.blueColor;
    [cell.btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [cell.btn setTitle:KHJString(@"%ld",(long)indexPath.row) forState:UIControlStateNormal];
    cell.block = ^(NSInteger row) {
        CLog(@"rpw = %ld",(long)row);
    };
    return cell;
}
- (IBAction)chooseDevice:(id)sender{
    CLog(@"选择设备");
}

@end








