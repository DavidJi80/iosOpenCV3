//
//  MatVC.m
//  iosOpenCV3
//
//  Created by mac on 2019/7/29.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "MatVC.h"
#import "OpenCVUtility.h"

using namespace cv;

@interface MatVC ()

@property (nonatomic,strong) UIImageView * srcImgView;
@property (nonatomic,strong) UIImageView * dstImgView;
@property (nonatomic,strong) UIImage * image;

@end

@implementation MatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigation];
    [self initView];
}

-(void)initNavigation{
    UIBarButtonItem * creatCloneBBI=[[UIBarButtonItem alloc]initWithTitle:@"结构" style:(UIBarButtonItemStylePlain) target:self action:@selector(creatCloneMat)];
    UIBarButtonItem * creatMatBBI=[[UIBarButtonItem alloc]initWithTitle:@"创建" style:(UIBarButtonItemStylePlain) target:self action:@selector(creatMat)];
    UIBarButtonItem * drawMatBBI=[[UIBarButtonItem alloc]initWithTitle:@"绘图" style:(UIBarButtonItemStylePlain) target:self action:@selector(drawMat)];
    self.navigationItem.rightBarButtonItems=@[drawMatBBI,creatMatBBI,creatCloneBBI];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)initView{
    _image = [UIImage imageNamed:@"Demo.jpg"];
    
    self.view.backgroundColor=UIColor.grayColor;
    
    _srcImgView=[UIImageView new];
    _srcImgView.frame=CGRectMake(20, 70, 200, 280);
    _srcImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_srcImgView];
    
    _dstImgView=[UIImageView new];
    _dstImgView.frame=CGRectMake(150, 360, 200, 280);
    _dstImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_dstImgView];
}

/**
 创建和复制Mat
 */
-(void)creatCloneMat{
    /**
     matA,matB,matC对象指向同一个也是唯一一个数据矩阵
     */
    Mat matA,matC;                                          //仅仅创建Mat信息头部分
    matA=[OpenCVUtility cvMatFromUIImage:_image];           //为矩阵matA开辟内存
    Mat matB(matA);                                         //使用拷贝构造函数
    matC = matA;                                            //赋值运算
    
    Mat matD(matA,cv::Rect(0,0,20,20));                     //使用矩阵界定
    Mat matE=matA(cv::Range::all(),cv::Range(1,3)).clone(); //使用行和列界定
    
    /**
     复制信息头和矩阵
     */
    Mat matF=matA.clone();                                  //clone Mat
    Mat matG;
    matA.copyTo(matG);
    
    
    self.srcImgView.image=[OpenCVUtility UIImageFromCVMat:matC];
    self.dstImgView.image=[OpenCVUtility UIImageFromCVMat:matE];
}

/**
 创建Mat的几种方式
 */
-(void)creatMat{
    /**
     1. 使用Mat()构造函数
        参数1：行数
        参数2：列数
        参数3：存储元素的数据类型以及每一个矩阵点的通道数
            CV_[位数][是否带符号][类型前缀]C[通道数]
            CV_8UC3：表示使用8位unsigned char型，每个像素由三个通道组成三通道
        参数4：short型向量，表示颜色
     */
    Mat mat1(2,2,CV_8UC3,Scalar(0,0,255));
    print(mat1);
    
    /**
     2. 利用Mat类的creat()成员函数进行
         参数1：行数
         参数2：列数
         参数3：存储元素的数据类型以及每一个矩阵点的通道数
     注意：此方法不能为矩阵设置初值，只是在改变尺寸时重新为矩阵数据开辟内存
     */
    Mat mat2;
    mat2.create(2, 2, CV_8UC3);
    //print(mat2);
    
    /**
     3. 采用Matlab式的初始化
     */
    Mat mat3=Mat::eye(2, 2, CV_8UC3);
    mat3=Mat::ones(2, 2, CV_8UC3);
    mat3=Mat::zeros(2, 2, CV_8UC3);
    //print(mat3);
    
    /**
     4. 小矩阵使用逗号分隔式初始化
     */
    Mat mat4=(Mat_<double>(2,6)<<0,0,255,0,0,255,0,0,255,0,0,255);
    print(mat4);
    
    /**
     5. 为已经存在的对象创建信息头
     */
    Mat mat5=mat1.row(1).clone();
    
    self.srcImgView.image=[OpenCVUtility UIImageFromCVMat:mat1];
    self.dstImgView.image=[OpenCVUtility UIImageFromCVMat:mat5];
}

/**
 绘图
 */
-(void)drawMat{
    Mat mat(1120,800,CV_8UC3,Scalar(255,255,255));
    
    //绘制椭圆
    ellipse(mat,                    //绘图的Mat
            cv::Point(400,400),     //中心
            cv::Size(200,100),      //大小
            50,                     //椭圆旋转角度
            0,                      //弧度开始度数
            360,                    //弧度结束角度
            Scalar(255,129,0),      //颜色
            2,                      //线宽
            8);                     //线型
    
    //绘制圆
    circle(mat,
           cv::Point(400,700),      //圆心
           100,                     //半径
           Scalar(255,0,255),
           2,
           8);
    
    //绘制线
    line(mat,
         cv::Point(50,50),          //开始点
         cv::Point(50,300),         //结束点
         Scalar(0,0,255),
         2,
         8);
    
    //绘制矩形
    rectangle(mat,
              cv::Point(100,20),          //左上角
              cv::Point(500,150),         //右下角
              Scalar(0,0,255),
              2,
              8);
    
    //绘制填充的多边形
    cv::Point rookPoints[1][3];
    rookPoints[0][0]=cv::Point(200,900);
    rookPoints[0][1]=cv::Point(200,1100);
    rookPoints[0][2]=cv::Point(600,900);
    const cv::Point * pts[1]={rookPoints[0]};
    int npts=3;
    fillPoly(mat,
             pts,                           //顶点集合
             &npts,                         //顶点数量
             1,                             //要绘制的多边形数量
             Scalar(0,0,255),
             8);
    
    self.srcImgView.image=[OpenCVUtility UIImageFromCVMat:mat];
}

-(void)aa{
    
}


@end
