//
//  ImageProcessVC.m
//  iosOpenCV3
//
//  Created by mac on 2019/7/26.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import "ImageProcessVC.h"

using namespace cv;     //openCV的cv命名空间

@interface ImageProcessVC ()
//UI
@property (nonatomic,strong) UIImageView * srcImgView;
@property (nonatomic,strong) UIImageView * dstImgView;
@property (nonatomic,strong) UIImage * image;
@end

@implementation ImageProcessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    [self initView];
}

-(void)initNavigation{
    UIBarButtonItem * sourceBBI=[[UIBarButtonItem alloc]initWithTitle:@"原画" style:(UIBarButtonItemStylePlain) target:self action:@selector(sourceImg)];
    UIBarButtonItem * erodeBBI=[[UIBarButtonItem alloc]initWithTitle:@"腐蚀" style:(UIBarButtonItemStylePlain) target:self action:@selector(erodeImg)];
    UIBarButtonItem * blurBBI=[[UIBarButtonItem alloc]initWithTitle:@"模糊" style:(UIBarButtonItemStylePlain) target:self action:@selector(blurImg)];
    UIBarButtonItem * cannyBBI=[[UIBarButtonItem alloc]initWithTitle:@"边缘检测" style:(UIBarButtonItemStylePlain) target:self action:@selector(cannyImg)];
    self.navigationItem.rightBarButtonItems=@[cannyBBI,blurBBI,erodeBBI,sourceBBI];
    [self.navigationController setToolbarHidden:YES animated:YES];
}


/**
 UI
 */
-(void)initView{
    _srcImgView=[UIImageView new];
    _srcImgView.frame=CGRectMake(20, 70, 200, 280);
    _image = [UIImage imageNamed:@"Demo.jpg"];
    _srcImgView.image=_image;
    _srcImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_srcImgView];
    
    _dstImgView=[UIImageView new];
    _dstImgView.frame=CGRectMake(150, 360, 200, 280);
    _dstImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_dstImgView];
}

/**
 UIImage转换为cv::Mat
 */
- (Mat)cvMatFromUIImage:(UIImage *)image{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cols=cols/2;
    rows=rows/2;
    Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

/**
 cv::Mat转换为UIImage
 */
-(UIImage *)UIImageFromCVMat:(Mat)cvMat{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}

/**
 原画
 */
-(void)sourceImg{
    Mat srcMat=[self cvMatFromUIImage:_image];
    UIImage * dstImage=[self UIImageFromCVMat:srcMat];
    self.dstImgView.image=dstImage;
}

/**
 腐蚀
 */
-(void)erodeImg{
    Mat srcMat=[self cvMatFromUIImage:_image];
    Mat dstMat;
    //进行腐蚀操作
    Mat element=getStructuringElement(MORPH_RECT, cv::Size(15,15)); //返回指定形状和尺寸的结构元素（Mat 内核矩阵）
    erode(srcMat, dstMat, element);                                 //对图像进行腐蚀操作
    UIImage * dstImage=[self UIImageFromCVMat:dstMat];
    self.dstImgView.image=dstImage;
    
}

/**
 模糊
 */
-(void)blurImg{
    Mat srcMat=[self cvMatFromUIImage:_image];
    Mat dstMat;
    blur(srcMat, dstMat, cv::Size(7,7));    //进行均值滤波操作
    UIImage * dstImage=[self UIImageFromCVMat:dstMat];
    self.dstImgView.image=dstImage;
}

/**
 边缘检测
 */
-(void)cannyImg{
    Mat srcMat=[self cvMatFromUIImage:_image];              //源图片的Mat
    Mat dstMat,edge,grayMat;                                //定义变量
    dstMat.create(srcMat.size(),srcMat.type());             //创建与srcMat一样大小和类型的Mat
    cvtColor(srcMat, grayMat, CV_BGR2GRAY);                 //OpenCV3版本，将原图转换为灰度图
    blur(grayMat, edge, cv::Size(3,3));                     //使用3*3内核降噪
    Canny(edge, edge, 3, 9, 3);                             //使用Canny进行边缘检测
    UIImage * dstImage=[self UIImageFromCVMat:edge];
    self.dstImgView.image=dstImage;
}

@end
