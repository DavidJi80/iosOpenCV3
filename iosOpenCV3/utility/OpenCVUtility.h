//
//  OpenCVUtility.h
//  iosOpenCV3
//
//  Created by mac on 2019/7/27.
//  Copyright © 2019 David Ji. All rights reserved.
//

#import <Foundation/Foundation.h>

using namespace cv; 

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVUtility : NSObject

+ (Mat)cvMatFromUIImage:(UIImage *)image;
+(UIImage *)UIImageFromCVMat:(Mat)cvMat;

@end

NS_ASSUME_NONNULL_END
