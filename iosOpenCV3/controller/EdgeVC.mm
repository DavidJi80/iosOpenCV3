//
//  EdgeVC.m
//  iosOpenCV3
//
//  Created by mac on 2019/7/30.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "EdgeVC.h"
#import <opencv2/videoio/cap_ios.h>

using namespace cv;


typedef enum _EdgeAlgorithmA {
    SOURCE  = 0,
    CANNY,
    SOBEL,
    LAPLACIAN,
    SCHARR
} EdgeAlgorithm;

@interface EdgeVC ()<CvVideoCameraDelegate>

//UI
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UIButton * button;
//OpenCV
@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic,assign) EdgeAlgorithm edgeAlgorithm;

@end

@implementation EdgeVC

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
    [_button setTitle:@"算法" forState:UIControlStateNormal];
    [_button.layer setCornerRadius:10.0];
    [_button addTarget:self action:@selector(openActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

-(void)openActionSheet:(UIButton*)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *sourceAction = [UIAlertAction actionWithTitle:@"原画" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.edgeAlgorithm=SOURCE;
    }];
    UIAlertAction *cannyAction = [UIAlertAction actionWithTitle:@"Canny边缘检测" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.edgeAlgorithm=CANNY;
    }];
    UIAlertAction *sobelAction = [UIAlertAction actionWithTitle:@"Sobel边缘检测" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.edgeAlgorithm=SOBEL;
    }];
    UIAlertAction *laplacianAction = [UIAlertAction actionWithTitle:@"Laplacian边缘检测" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.edgeAlgorithm=LAPLACIAN;
    }];
    UIAlertAction *scharrAction = [UIAlertAction actionWithTitle:@"Scharr滤波器+Sobel边缘检测" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.edgeAlgorithm=SCHARR;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [cancelAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    
    [alert addAction:sourceAction];
    [alert addAction:cannyAction];
    [alert addAction:sobelAction];
    [alert addAction:laplacianAction];
    [alert addAction:scharrAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


/**
 init OpenCV CvVideoCamera
 */
-(void)initVideoCamera{
    //self.cvEffect=SOURCE;
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
- (void)processImage:(Mat&)image{
    switch (self.edgeAlgorithm) {
        case SOURCE:
            break;
        case CANNY:
            [self cannyImg:image];
            break;
        case SOBEL:
            [self sobelImg:image];
            break;
        case LAPLACIAN:
            [self laplacianImg:image];
            break;
        case SCHARR:
            [self scharrImg:image];
            break;
    }
}

/**
 Canny边缘检测
 1.转换成灰度图、2.降噪、3.边缘检测
 */
-(void)cannyImg:(Mat&)image{
    Mat edge,grayMat;                                     //定义变量
    cvtColor(image, grayMat, CV_BGR2GRAY);                //OpenCV3版本，将原图转换为灰度图
    blur(grayMat, edge, cv::Size(3,3));                   //使用3*3内核降噪
    /**
     Canny图像的边缘检测
        参数1：InputArray类型的image，输入图像，即源图像，填Mat类的对象即可，需要单通道8位图像
        参数2：OutputArray类型的edges，输出的边缘图像，需要和源图片有一样的尺寸和类型
        参数3：double类型的threshold1，第一个滞后性阀值
        参数4：double类型的threshold2，第二个滞后性阀值
        参数5：int类型的apertureSize，表示应用Sobel算子的孔径大小，默认值为3
        参数6：bool类型的L2gradient，一个计算图像梯度幅度值得标识，默认false
     注意：threshold1和threshold2中较小的值用于边缘连接，而较大的值用来控制强边缘的初始段，推荐的高低比在2:1到3:1之间
     */
    Canny(edge, image, 3, 9, 3, false);                     //使用Canny进行边缘检测
}

/**
 Sobel边缘检测
 结合高斯平滑和微分求导，用来计算图像灰度函数的近似梯度
 1.x方向求导、2.y方向求导、3.合并
 */
-(void)sobelImg:(Mat&)image{
    Mat grad_x,grad_y;
    Mat abs_grad_x,abs_grad_y,dst;
    /**
     Sobel函数计算一阶、二阶、三阶或者混合图像差分
        参数1：InputArray类型的src，输入图像，即源图像，填Mat类的对象即可
        参数2：OutputArray类型的dst，输出的边缘图像，需要和源图片有一样的尺寸和类型
        参数3：int类型的ddepth，输出图像的深度
        参数4：int类型的dx，x方向上的差分阶数
        参数5：int类型的dy，y方向上的差分阶数
        参数6：int类型ksize，默认3，表示Sobel核的大小，必须取1、3、5或7
        参数7：double类型的scale，计算导数值时可选的缩放因子，默认值1，表示默认情况下是没有应用缩放的
        参数8：double类型的delta，表示在结果存入目标图（dst）之前可选的delta值，默认值为0
        参数9：int类型的borderType，边界模型，默认为BORDER_DEFAULT
     */
    Sobel(image, grad_x, CV_16S, 1, 0, 3, 1, 1, BORDER_DEFAULT);
    convertScaleAbs(grad_x, abs_grad_x);
    
    Sobel(image, grad_y, CV_16S, 0, 1, 3, 1, 1, BORDER_DEFAULT);
    convertScaleAbs(grad_y, abs_grad_y);
    
    addWeighted(abs_grad_x, 0.5, abs_grad_y, 0.5, 0, dst);
    
    image=dst;
}

/**
 Laplacian边缘检测
 计算出图像经过拉普拉斯变换后的结果
 1.高斯滤波消除噪声、2.转换为灰度图、3.Laplacian边缘检测
 */
-(void)laplacianImg:(Mat&)image{
    Mat src_gray,dst,abs_dst;
    GaussianBlur(image, image, cv::Size(3,3), 0, 0, BORDER_DEFAULT);    //使用高斯滤波消除噪声
    cvtColor(image, src_gray, COLOR_RGB2GRAY);                          //转换为灰度图
    /**
     Laplacian函数可以计算出图像经过拉普拉斯变换后的结果
        参数1：InputArray类型的src，输入图像，即源图像，填Mat类的对象即可
        参数2：OutputArray类型的dst，输出的边缘图像，需要和源图片有一样的尺寸和类型
        参数3：int类型的ddepth，输出图像的深度
        参数4：int类型ksize，用于计算二阶导数的滤波器的孔径尺寸，默认1，大小必须取奇数
        参数5：double类型的scale，计算拉普拉斯值的时候可选的比例因子，默认1
        参数6：double类型的delta，表示在结果存入目标图（dst）之前可选的delta值，默认值为0
        参数7：int类型的borderType，边界模型，默认为BORDER_DEFAULT
     */
    Laplacian(src_gray, dst, CV_16S, 3, 1, 0, BORDER_DEFAULT);
    convertScaleAbs(dst, abs_dst);                                      //计算绝对值，并将结果转换为8位
    image=abs_dst;
}

/**
 Scharr滤波器
 主要配合Sobel运算
 1.求X方向梯度、2.求Y方向梯度、3.合并梯度
 */
-(void)scharrImg:(Mat&)image{
    Mat grad_x,grad_y;
    Mat abs_grad_x,abs_grad_y,dst;
    //求X方向梯度
    /**
     Scharr滤波器
        参数1：InputArray类型的src，输入图像，即源图像，填Mat类的对象即可
        参数2：OutputArray类型的dst，输出的边缘图像，需要和源图片有一样的尺寸和类型
        参数3：int类型的ddepth，输出图像的深度
        参数4：int类型dx，x方向上的差分阶数
        参数5：int类型dy，y方向上的差分阶数
        参数6：double类型的scale，计算导数值时可选的缩放因子，默认1，表示没有应用缩放
        参数7：double类型的delta，表示在结果存入目标图（dst）之前可选的delta值，默认值为0
        参数8：int类型的borderType，边界模型，默认为BORDER_DEFAULT
     */
    Scharr(image, grad_x, CV_16S, 1, 0, 1, 0, BORDER_DEFAULT);
    convertScaleAbs(grad_x, abs_grad_x);
    //求Y方向梯度
    Scharr(image, grad_y, CV_16S, 0, 1, 1, 0, BORDER_DEFAULT);
    convertScaleAbs(grad_y, abs_grad_y);
    //合并梯度
    addWeighted(abs_grad_x, 0.5, abs_grad_y, 0.5, 0, dst);
    image=dst;
}


- (void)actionStart{
    [self.videoCamera start];
}

@end
