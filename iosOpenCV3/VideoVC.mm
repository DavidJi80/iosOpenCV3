//
//  VideoVC.m
//  iosOpenCV
//
//  Created by mac on 2019/7/22.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "VideoVC.h"
#import <opencv2/videoio/cap_ios.h>
#include <opencv2/core/types_c.h>


@interface VideoVC () <CvVideoCameraDelegate>{
    UIImageView* imageView;
    UIButton* button;
}
//UI
//@property (nonatomic,strong) UIImageView * imageView;
//@property (nonatomic,strong) UIButton * button;
//
@property (nonatomic, retain) CvVideoCamera* videoCamera;

@end

@implementation VideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    imageView=[UIImageView new];
    imageView.frame=CGRectMake(40, 100, 300, 400);
//    imageView.backgroundColor=UIColor.purpleColor;
    [self.view addSubview:imageView];
    
    button=[UIButton new];
    button.backgroundColor=[UIColor brownColor];
    button.frame=CGRectMake(150, 550, 100, 45);
    [button setTitle:@"Start" forState:UIControlStateNormal];
    [button.layer setCornerRadius:10.0];
    [button addTarget:self action:@selector(actionStart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    //self.videoCamera.rotateVideo =YES; //设置是旋转
    self.videoCamera.defaultFPS = 30;
    [self performSelector:@selector(actionStart:) withObject:nil afterDelay:0.1];
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(cv::Mat&)image{

    cv::Mat gray;
    cv::cvtColor(image, gray, CV_BGR2GRAY);// 转换成灰色
    //6.使用灰度后的IplImage形式图像，用OSTU算法算阈值：threshold
    IplImage grey = gray;
    unsigned char* dataImage = (unsigned char*)grey.imageData;
    //int threshold = Otsu(dataImage, grey.width, grey.height);
    //printf("阈值：%d\n",threshold);
    //7.利用阈值算得新的cvMat形式的图像
    cv::threshold(gray, image, 100, 255, cv::THRESH_BINARY);

}
#endif

- (void)actionStart:(id)sender{
    [self.videoCamera start];
}

@end
