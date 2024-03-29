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
#import "ImageProcessVC.h"
#import "MatVC.h"
#import "EdgeVC.h"
#import "HoughVC.h"

@interface ViewController ()

@property(nonatomic,strong) UIButton * imageBtn;
@property(nonatomic,strong) UIButton * videoBtn;
@property(nonatomic,strong) UIButton * imageProcessBtn;
@property(nonatomic,strong) UIButton * matBtn;
@property(nonatomic,strong) UIButton * edgeBtn;
@property(nonatomic,strong) UIButton * houghBtn;

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
    
    _imageProcessBtn=[UIButton new];
    _imageProcessBtn.backgroundColor=[UIColor brownColor];
    _imageProcessBtn.frame=CGRectMake(30, 150, 145, 45);
    _imageProcessBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _imageProcessBtn.titleLabel.textColor=[UIColor whiteColor];
    [_imageProcessBtn setTitle:@"处理图片" forState:UIControlStateNormal];
    [_imageProcessBtn.layer setCornerRadius:10.0];
    [_imageProcessBtn addTarget:self action:@selector(imageProcess:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.imageProcessBtn];
    
    _matBtn=[UIButton new];
    _matBtn.backgroundColor=[UIColor brownColor];
    _matBtn.frame=CGRectMake(200, 150, 145, 45);
    _matBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _matBtn.titleLabel.textColor=[UIColor whiteColor];
    [_matBtn setTitle:@"Mat" forState:UIControlStateNormal];
    [_matBtn.layer setCornerRadius:10.0];
    [_matBtn addTarget:self action:@selector(mat:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_matBtn];
    
    _edgeBtn=[UIButton new];
    _edgeBtn.backgroundColor=[UIColor darkGrayColor];
    _edgeBtn.frame=CGRectMake(30, 210, 145, 45);
    _edgeBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _edgeBtn.titleLabel.textColor=[UIColor whiteColor];
    [_edgeBtn setTitle:@"边缘检测" forState:UIControlStateNormal];
    [_edgeBtn.layer setCornerRadius:10.0];
    [_edgeBtn addTarget:self action:@selector(edge:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_edgeBtn];
    
    _houghBtn=[UIButton new];
    _houghBtn.backgroundColor=[UIColor darkGrayColor];
    _houghBtn.frame=CGRectMake(200, 210, 145, 45);
    _houghBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _houghBtn.titleLabel.textColor=[UIColor whiteColor];
    [_houghBtn setTitle:@"霍夫变换" forState:UIControlStateNormal];
    [_houghBtn.layer setCornerRadius:10.0];
    [_houghBtn addTarget:self action:@selector(hough:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_houghBtn];
}

-(void)imageDemo:(UIButton*)sender{
    ImageVC * tableViewController=[[ImageVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

-(void)videoDemo:(UIButton*)sender{
    VideoVC * tableViewController=[[VideoVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

-(void)imageProcess:(UIButton*)sender{
    ImageProcessVC * tableViewController=[[ImageProcessVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

-(void)mat:(UIButton*)sender{
    MatVC * tableViewController=[[MatVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:NO];
}

-(void)edge:(UIButton*)sender{
    EdgeVC * tableViewController=[[EdgeVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:NO];
}

-(void)hough:(UIButton*)sender{
    HoughVC * tableViewController=[[HoughVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:NO];
}




@end
