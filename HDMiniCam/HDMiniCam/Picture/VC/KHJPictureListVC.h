//
//  KHJPictureListVC.h

//
//  Created by kevin on 2018/6/5.


#import <UIKit/UIKit.h>

typedef void(^KHJDeleteItemBlock)(NSString *path);

@interface KHJPictureListVC : KHJBaseVC

@property (nonatomic, copy) KHJDeleteItemBlock deleteBlock;

@property (weak, nonatomic) IBOutlet UILabel *showLabel;


@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

- (IBAction)deleteVedio:(UIButton *)sender;


@property (nonatomic,strong)NSMutableDictionary *Datadic;//保存当前本地视频

@property (nonatomic,assign) NSInteger currentIndex;//当前进来第几个




@end
