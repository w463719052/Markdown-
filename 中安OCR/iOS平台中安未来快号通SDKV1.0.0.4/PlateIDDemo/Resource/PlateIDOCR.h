//
//  PlateIDOCR.h
//  PlateIDOCR
//


#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "PlateFormat.h"
#import "PlateResult.h"

@interface PlateIDOCR : NSObject

/*
 初始化核心,调用其他方法之前，必须调用此初始化，否则，其他函数调用无效
 参数：devcode：开发码
 type：识别的类型，设置为0时为快速识别；设置为2时为精准识别；设置为0时 支持拍照识别
 返回值：返回为0时，初始化成功，返回为其他值时 具体参照开发手册返回值的说明
 */
- (int) initPalteIDWithDevcode: (NSString *)devcode RecogType:(int) type;

/*
 识别的车牌设置
 参数：plateFormat：识别的车牌设置，具体见PlateFormat类
 */
- (void)setPlateFormat: (PlateFormat *)plateFormat;


/*
 扫描识别
 参数：buffer：传入的图片帧数据
 count：识别的最大车牌个数，手机应用设置为1
 width：图片帧数据的宽
 height：图片帧数据的高
 rect：为识别的预览框的位置
 confidence：置信度，范围为：0--100；设置置信度时，分两种情况：1 平常的车牌，可以设置高一些，错误排除率高，一般设置为80；2 特殊的      车牌，设置低一些，设置的高，会影响识别结果的输出，也会影响识别速度，一般设置为75
 */
- (NSArray *) recogImageWithBuffer:(UInt8 *)buffer recogCount: (int)count nWidth: (int)width nHeight: (int) height recogRange:(CGRect) rect confidence:(int)confidence;



/*
 拍照识别或选图识别
 参数：image：拍照识别时，传入的图片，为帧数据转成的图片；选图识别时，为相册里面的图片
 count：识别的最大车牌个数，手机应用设置为1
 */
- (NSArray *) recogWithImage: (UIImage *)image recogCount: (int)count;

/*
 释放核心，识别完成后调用
 */
- (int)uninitPlateIDSDK;

@end
