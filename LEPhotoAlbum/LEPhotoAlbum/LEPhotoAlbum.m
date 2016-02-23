//
//  LEPhotoAlbum.m
//  LEPhotoAlbum
//  GitHub: https://github.com/ChordLeafe/LEImagePickerController.git
//  博客:   http://www.jianshu.com/p/be40c92dd10f
//  Created by jianxin.li on 16/2/20.
//  Copyright © 2016年 m6go.com. All rights reserved.
//  GitHub
//

#import "LEPhotoAlbum.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define SCREENCGRECT   ([UIScreen mainScreen].bounds)
@interface LEPhotoAlbum ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) PhotoBlock photoBlock;
@property (nonatomic, strong) UIImagePickerController *picker;
@end

@implementation LEPhotoAlbum

- (instancetype)init {
    if ([super init]) {
        _picker = [[UIImagePickerController alloc]init];
    }
    return self;
}

- (void)getPhotoAlbumOrTakeAPhotoWithController:(UIViewController *)Controller andWithBlock:(PhotoBlock)photoBlock {
    self.photoBlock = photoBlock;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"图片" message:@"选择" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoAlbumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self creatUIImagePickerControllerWithAlertActionType:1 controller:Controller];
    }];
    UIAlertAction *cemeraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self creatUIImagePickerControllerWithAlertActionType:2 controller:Controller];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self creatUIImagePickerControllerWithAlertActionType:0 controller:Controller];
    }];
    [alertController addAction:photoAlbumAction];
    [alertController addAction:cancleAction];
    if ([self imagePickerControlerIsAvailabelToCamera]) {
         [alertController addAction:cemeraAction];
    }
   [Controller presentViewController:alertController animated:YES completion:^{
       
   }];
    
}

// 判断硬件是否支持拍照
- (BOOL)imagePickerControlerIsAvailabelToCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return YES;
    } else {
        return NO;
    }
}
// 创建ImagePickerController
- (void)creatUIImagePickerControllerWithAlertActionType:(NSInteger)type controller:(UIViewController *)Controller {
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    switch (type) {
        case 1:
        {
            // 用户可以在一组相册列表中选择，并进入其中一个相册选择图片
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
            break;
        case 2:
        {
           sourceType = UIImagePickerControllerSourceTypeCamera;
            [self customCameraUI];
        }
            break;
        case 0:
        {
            return;
        }
            break;
            
        default:
            break;
    }
  
    _picker.delegate = self;
    _picker.allowsEditing = YES;
    _picker.sourceType = sourceType;
    [Controller presentViewController:_picker animated:YES completion:^{
    }];
    
}

// 授权
- (void)checkAuthorize {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (authStatus) {
        case 0: { //第一次使用，则会弹出是否打开权限
            [AVCaptureDevice requestAccessForMediaType : AVMediaTypeVideo completionHandler:^(BOOL granted) {
                // granted 是否授权成功
            }];
        }
            break;
        case 1:{ //还未授权
        }
            break;
        case 2:{ //主动拒绝授权
        }
            break;
        case 3: {  //已授权
        }
            break;
            
        default:
            break;
    }

}

// 自定义拍照界面
- (void)customCameraUI {
    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    // 设置图像选取控制器的类型为静态图像
    _picker.mediaTypes = @[(NSString *)kUTTypeImage];
    // 全屏效果
    _picker.cameraViewTransform = CGAffineTransformMakeScale(1.5, 1.5);
    // 隐藏标准的拍摄视图控件
    _picker.showsCameraControls = NO;
    
    CGRect f = SCREENCGRECT;
    UIView *view = [[UIView alloc]initWithFrame:f];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    tapG.numberOfTapsRequired = 2;
    [view addGestureRecognizer:tapG];
    _picker.cameraOverlayView = view;
    
    CGFloat h = 165;
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, f.size.height - h, f.size.width, h)];
    view2.backgroundColor = [UIColor orangeColor];
    view2.alpha = 0.3f;
    [view addSubview:view2];
    UILabel *lable = [UILabel new];
    lable.text = @"自定义区域";
    lable.backgroundColor = [UIColor clearColor];
    [lable sizeToFit];
    lable.center = CGPointMake(CGRectGetMidX(view2.bounds), CGRectGetMidY(view2.bounds));
    [view2 addSubview:lable];

}

- (void)tap:(id)recognizer {
    [self.picker takePicture];
}

- (void)doCancel:(id)b {
    NSLog(@"doCancel");
    [self.picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
   //获取编辑后的图片
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    NSLog(@"DELEGATE %@",image);
    if (self.photoBlock) {
        self.photoBlock(image);
    }
    [_picker dismissViewControllerAnimated:YES completion:nil];
}

// 取消选择照片:
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"取消图片选择");
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setToolbarHidden:NO];
    CGRect f = navigationController.toolbar.frame;
    CGFloat h = 56;
    CGFloat diff = h - f.size.height;
    f.size.height = h;
    f.origin.y -= diff;
    navigationController.toolbar.frame = f;
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(doCancel:)];
    UILabel *lable = [UILabel new];
    lable.text = @"双击拍照";
    lable.backgroundColor = [UIColor clearColor];
    [lable sizeToFit];
    UIBarButtonItem *barBtnItem2 = [[UIBarButtonItem alloc]initWithCustomView:lable];
    [navigationController.topViewController setToolbarItems:@[barBtnItem,barBtnItem2]];
}
@end
