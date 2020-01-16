//
//  KHJOnlineVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJOnlineVC.h"

@interface KHJOnlineVC ()
{
    __weak IBOutlet UITextField *name;
    __weak IBOutlet UIView *nameView;
    __weak IBOutlet UITextField *uid;
    __weak IBOutlet UIView *uidView;
    __weak IBOutlet UITextField *password;
    __weak IBOutlet UIView *passwordView;

}
@end

@implementation KHJOnlineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addlayer];
    [self registerLJWKeyboardHandler];
}


- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)searchNet:(id)sender {
}
- (IBAction)qr:(id)sender {
}
- (IBAction)sure:(id)sender {
}
- (IBAction)cancel:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addlayer
{
    uidView.layer.borderWidth = 1;
    uidView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    nameView.layer.borderWidth = 1;
    nameView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    passwordView.layer.borderWidth = 1;
    passwordView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    self.titleLab.text = KHJLocalizedString(@"添加已联网设备", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

@end
