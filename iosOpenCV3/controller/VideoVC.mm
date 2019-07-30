//
//  VideoVC.m
//  iosOpenCV
//
//  Created by mac on 2019/7/22.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "VideoVC.h"
#import <opencv2/videoio/cap_ios.h>
#import "OpenCVUtility.h"

using namespace cv;

typedef enum _CvEffect {
    SOURCE  = 0,
    ERODE,
    BLUR,
    CANNY,
    THRESHOLD
} CvEffect;


@interface VideoVC () <CvVideoCameraDelegate>
//UI
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UIButton * button;
//OpenCV
@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic,assign) CvEffect cvEffect;

@end

@implementation VideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self initVideoCamera];
    [self performSelector:@selector(actionStart) withObject:nil afterDelay:0.1];
}

/**
 UI
 */
-(void)initView{
    _imageView=[UIImageView new];
    _imageView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:_imageView];
    
    _button=[UIButton new];
    _button.backgroundColor=[UIColor brownColor];
    _button.frame=CGRectMake(SCREEN_WIDTH/2-50, SCREEN_HEIGHT-80, 100, 45);
    [_button setTitle:@"特效" forState:UIControlStateNormal];
    [_button.layer setCornerRadius:10.0];
    [_button addTarget:self action:@selector(openActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

/**
 init OpenCV CvVideoCamera
 */
-(void)initVideoCamera{
    self.cvEffect=SOURCE;
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
- (void)processImage:(Mat&)image{
    switch (self.cvEffect) {
        case SOURCE:
            break;
        case ERODE:
            [self erodeImg:image];
            break;
        case BLUR:
            [self blurImg:image];
            break;
        case CANNY:
            [self cannyImg:image];
            break;
        case THRESHOLD:
            [self thresholdImg:image];
            break;
    }
}

/**
 腐蚀
 */
-(void)erodeImg:(Mat&)image{
    Mat element=getStructuringElement(MORPH_RECT, cv::Size(15,15)); //返回指定形状和尺寸的结构元素（Mat 内核矩阵）
    erode(image, image, element);                                 //对图像进行腐蚀操作
}

/**
 模糊
 */
-(void)blurImg:(Mat&)image{
    blur(image, image, cv::Size(7,7));    //进行均值滤波操作
}

/**
 边缘检测
 */
-(void)cannyImg:(Mat&)image{
    Mat dstMat,edge,grayMat;                              //定义变量
    dstMat.create(image.size(),image.type());             //创建与srcMat一样大小和类型的Mat
    cvtColor(image, grayMat, CV_BGR2GRAY);                //OpenCV3版本，将原图转换为灰度图
    blur(grayMat, edge, cv::Size(3,3));                   //使用3*3内核降噪
    Canny(edge, image, 3, 9, 3);                          //使用Canny进行边缘检测
}

/**
 阈值
 */
-(void)thresholdImg:(Mat&)image{
    //cvtColor(image, image, CV_BGR2GRAY);                     // 转换成灰色
    threshold(image, image, 100, 255, THRESH_BINARY);    // 利用阈值算得新的cvMat形式的图像
}
#endif

- (void)actionStart{
    [self.videoCamera start];
}

-(void)openActionSheet:(UIButton*)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *sourceAction = [UIAlertAction actionWithTitle:@"原画" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.cvEffect=SOURCE;
    }];
    UIAlertAction *erodeAction = [UIAlertAction actionWithTitle:@"腐蚀" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.cvEffect=ERODE;
    }];
    UIAlertAction *blurAction = [UIAlertAction actionWithTitle:@"模糊" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.cvEffect=BLUR;
    }];
    UIAlertAction *cannyAction = [UIAlertAction actionWithTitle:@"边缘检测" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.cvEffect=CANNY;
    }];
    UIAlertAction *thresholdAction = [UIAlertAction actionWithTitle:@"阈值" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.cvEffect=THRESHOLD;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [cancelAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    
    [alert addAction:sourceAction];
    [alert addAction:erodeAction];
    [alert addAction:blurAction];
    [alert addAction:cannyAction];
    [alert addAction:thresholdAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
