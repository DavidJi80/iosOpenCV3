//
//  ViewController.m
//  iosOpenCV
//
//  Created by mac on 2019/7/19.
//  Copyright © 2019 David Ji. All rights reserved.
//
#import "ViewController.h"
#import "ImageVC.h"
#import "VideoVC.h"

@interface ViewController ()

@property(nonatomic,strong) UIButton * imageBtn;
@property(nonatomic,strong) UIButton * videoBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageBtn=[UIButton new];
    _imageBtn.backgroundColor=[UIColor greenColor];
    _imageBtn.frame=CGRectMake(30, 90, 145, 45);
    _imageBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _imageBtn.titleLabel.textColor=[UIColor whiteColor];
    [_imageBtn setTitle:@"Image" forState:UIControlStateNormal];
    [_imageBtn.layer setCornerRadius:10.0];
    [_imageBtn addTarget:self action:@selector(imageDemo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.imageBtn];
    
    _videoBtn=[UIButton new];
    _videoBtn.backgroundColor=[UIColor greenColor];
    _videoBtn.frame=CGRectMake(200, 90, 145, 45);
    _videoBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _videoBtn.titleLabel.textColor=[UIColor whiteColor];
    [_videoBtn setTitle:@"Video" forState:UIControlStateNormal];
    [_videoBtn.layer setCornerRadius:10.0];
    [_videoBtn addTarget:self action:@selector(videoDemo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.videoBtn];
}

-(void)imageDemo:(UIButton*)sender{
    ImageVC * tableViewController=[[ImageVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

-(void)videoDemo:(UIButton*)sender{
    VideoVC * tableViewController=[[VideoVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:YES];
}



@end
