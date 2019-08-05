//
//  HoughVC.m
//  iosOpenCV3
//
//  Created by mac on 2019/8/5.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "HoughVC.h"
#import <opencv2/videoio/cap_ios.h>

using namespace cv;
using namespace std;

typedef enum _HoughType {
    SOURCE  = 0,
    STANDARD,
    CIRCLE,
    PROGRESSIVE_PROBABILISTIC
} HoughType;

@interface HoughVC ()<CvVideoCameraDelegate>
//UI
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UIButton * button;
//OpenCV
@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic,assign) HoughType houghType;
@end

@implementation HoughVC

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
    self.houghType=SOURCE;
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

- (void)actionStart{
    [self.videoCamera start];
}

-(void)openActionSheet:(UIButton*)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *sourceAction = [UIAlertAction actionWithTitle:@"原画" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.houghType=SOURCE;
    }];
    UIAlertAction *standardAction = [UIAlertAction actionWithTitle:@"标准霍夫变换" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.houghType=STANDARD;
    }];
    UIAlertAction *circleAction = [UIAlertAction actionWithTitle:@"霍夫圆变换" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.houghType=CIRCLE;
    }];
    UIAlertAction *ppAction = [UIAlertAction actionWithTitle:@"累计概率霍夫变换" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.houghType=PROGRESSIVE_PROBABILISTIC;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [cancelAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    
    [alert addAction:sourceAction];
    [alert addAction:standardAction];
    [alert addAction:ppAction];
    [alert addAction:circleAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Protocol CvVideoCameraDelegate
- (void)processImage:(Mat&)image{
    switch (self.houghType) {
        case SOURCE:
            break;
        case STANDARD:
            [self standardHough:image];
            break;
        case CIRCLE:
            [self circleHough:image];
            break;
        case PROGRESSIVE_PROBABILISTIC:
            [self ppHough:image];
            break;
    }
}

/**
 标准霍夫变换
 */
-(void)standardHough:(Mat&)image{
    Mat midImage,dstImage;                      //临时变量
    
    Canny(image, midImage, 50, 200, 3);         //进行边缘检测
    cvtColor(midImage, dstImage, CV_GRAY2BGR);  //把边缘检测后的图转化为灰度图
    
    vector<Vec2f> lines;                        //定义一个矢量结构lines用于存放得到的线段矢量集合
    /**
     采用标准霍夫变换的二值图像线条
        参数1：InputArray类型的image，输入图像，即源图像。需要8位的单通道二进制图像。
        参数2：OutputArray类型的lines，经过调用HoughLines函数后存储了霍夫变换检测到线条的输出矢量
            每一条线由2个元素的矢量y构成，一个是离开坐标原点的距离，一个是旋转角度
        参数3：double类型的rho，以像素为单位的距离精度
        参数4：double类型的theta，以弧度为单位的角度精度
        参数5：int类型的threshold，累加平面的阀值参数
        参数6：double类型的srn，默认值0
        参数7：doubel类型的stn，默认值0
     */
    HoughLines(midImage, lines, 1, CV_PI/180, 150, 0, 0);
    //依次在图中绘制出每一条线段
    for(size_t i=0;i<lines.size();i++){
        float rho=lines[i][0], theta = lines[i][1];
        cv::Point pt1,pt2;
        double a=cos(theta), b=sin(theta);
        double x0=a*rho, y0=b*rho;
        pt1.x=cvRound(x0+1000*(-b));
        pt1.y=cvRound(y0+1000*(a));
        pt2.x=cvRound(x0-1000*(-b));
        pt2.y=cvRound(y0-1000*(a));
        
        line(dstImage,pt1, pt2, Scalar(255,255,0), 1, LINE_AA);
    }
    
    image=dstImage;
}

/**
 霍夫圆变换
 */
-(void)circleHough:(Mat&)image{
    Mat midImage,dstImage;                                  //临时变量
    cvtColor(image, midImage, COLOR_BGR2GRAY);              //转换为灰度图
    GaussianBlur(midImage, midImage, cv::Size(9,9), 2, 2);  //图像平滑处理
    
    vector<Vec3f> circles;
    /**
     利用霍夫圆变换检测出灰度图中的圆
        参数1：InputArray类型的image，输入图像，即源图像。需要8位的单通道二进制图像。
        参数2：OutputArray类型的circles，经过调用HoughCircles函数后存储了检测到圆的输出矢量
            每个矢量由3个浮点矢量(x,y,radius)
        参数3：double类型的method，使用的检测方法
        参数4：double类型的dp，用于检测圆心的累加器图像的分辨率于输入图像之比的倒数
        参数5：double类型的minDist，为霍夫变换检测到的圆的圆心之间的最小距离
        参数6：double类型的param1，默认值100，参数3的对应参数，对唯一方法HOUGH_GRADIENT来说是传递给canny边缘检测的阀值
        参数7：double类型的param2，默认值100，参数3的对应参数，对唯一方法HOUGH_GRADIENT来说是圆心的累加器阀值
        参数8：int类型的minRadius，默认值0，表示圆半径的最小值
        参数9：int类型的maxRadius，默认值0，表示圆半径的最大值
     */
    HoughCircles(midImage, circles, HOUGH_GRADIENT, 1.5, 10, 200, 100, 0, 0);
    for(size_t i=0; i<circles.size(); i++){
        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
        int radius=cvRound(circles[i][2]);
        circle(image, center, 3, Scalar(0, 255, 0), -1, 8, 0);
        circle(image, center, radius, Scalar(155,50,255), 3, 8, 0);
    }
}

/**
 累计概率霍夫变换
 */
-(void)ppHough:(Mat&)image{
    Mat midImage,dstImage;                      //临时变量
    
    Canny(image, midImage, 50, 200, 3);         //进行边缘检测
    cvtColor(midImage, dstImage, CV_GRAY2BGR);  //把边缘检测后的图转化为灰度图
    
    vector<Vec4i> lines;                        //定义一个矢量结构lines用于存放得到的线段矢量集合
    /**
     采用累计概率霍夫变换（PPHT）来找出二值图像中的直线
        参数1：InputArray类型的image，输入图像，即源图像。需要8位的单通道二进制图像。
        参数2：OutputArray类型的lines，经过调用HoughLinesP函数后存储了检测到线条的输出矢量
            每一条线由4个元素的矢量(x_1,x_2,y_1,y_2)，分别表示线段的开始和结束的点
        参数3：double类型的rho，以像素为单位的距离精度
        参数4：double类型的theta，以弧度为单位的角度精度
        参数5：int类型的threshold，累加平面的阀值参数
        参数6：double类型的minLineLength，默认值0L，表示最低线段的长度，比这个设定参数短的线段就不能被显示出来
        参数7：doubel类型的maxLineGap，默认值0，允许将同一行点与点之间连接起来的最大的距离
     */
    HoughLinesP(midImage, lines, 1, CV_PI/180, 80, 50, 10);
    //依次在图中绘制出每一条线段
    for (size_t i=0;i<lines.size();i++){
        Vec4i l=lines[i];
        line(dstImage, cv::Point(l[0],l[1]), cv::Point(l[2],l[3]), Scalar(0,255,0), 1, LINE_AA);
    }
    image=dstImage;
}


@end
