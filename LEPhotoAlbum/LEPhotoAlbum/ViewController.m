//
//  ViewController.m
//  LEPhotoAlbum
//
//  Created by jianxin.li on 16/2/20.
//  Copyright © 2016年 m6go.com. All rights reserved.
//

#import "ViewController.h"
#import "LEPhotoAlbum.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) LEPhotoAlbum *photoAlbum;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _photoAlbum = [[LEPhotoAlbum alloc]init];
}

- (IBAction)click:(id)sender {
    [_photoAlbum getPhotoAlbumOrTakeAPhotoWithController:self andWithBlock:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

@end
