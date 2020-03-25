//
//  TZPhotoPickerController.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TZAlbumModel;
@interface TZPhotoPickerController : UIViewController

@property (nonatomic, strong) TZAlbumModel *model;
/** 当前选择传照片或者传视频 */
@property (nonatomic, copy) NSString *fileType;

@end
