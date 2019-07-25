//
//  VideoVC.m
//  iosOpenCV
//
//  Created by mac on 2019/7/22.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "VideoVC.h"
#import <opencv2/videoio/cap_ios.h>


@interface VideoVC () <CvVideoCameraDelegate>
//UI
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UIButton * button;
//OpenCV
@property (nonatomic, retain) CvVideoCamera* videoCamera;

@end

@implementation VideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self initVideoCamera];
    [self performSelector:@selector(actionStart:) withObject:nil afterDelay:0.1];
}

/**
 UI
 */
-(void)initView{
    _imageView=[UIImageView new];
    _imageView.frame=CGRectMake(40, 100, 300, 400);
    [self.view addSubview:_imageView];
    
    _button=[UIButton new];
    _button.backgroundColor=[UIColor brownColor];
    _button.frame=CGRectMake(150, 550, 100, 45);
    [_button setTitle:@"Start" forState:UIControlStateNormal];
    [_button.layer setCornerRadius:10.0];
    [_button addTarget:self action:@selector(actionStart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

/**
 init OpenCV CvVideoCamera
 */
-(void)initVideoCamera{
    //初始化相机并提供imageView作为渲染每个帧的目标
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    /**
     CvVideoCamera基本上是围绕AVFoundation的包装，
     所以我们将AVGoundation摄像机的一些选项作为属性。
     */
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;          //使用后置摄像头
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;         //设置视频大小
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;  //视频方向
    self.videoCamera.rotateVideo =YES;                                                      //设置是旋转
    self.videoCamera.defaultFPS = 30;                                                       //设置相机的FPS
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(cv::Mat&)image{
    cv::Mat gray;
    cv::cvtColor(image, gray, CV_BGR2GRAY);                     // 转换成灰色
    cv::threshold(gray, image, 100, 255, cv::THRESH_BINARY);    // 利用阈值算得新的cvMat形式的图像
}
#endif

- (void)actionStart:(id)sender{
    [self.videoCamera start];
}

@end
