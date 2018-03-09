//
//  IDCardOCR.h
//  IDCardOCR
////

#import <Foundation/Foundation.h>
#import "IDCardSlideLine.h"

@interface IDCardOCR : NSObject

/*
 初始化核心,调用其他方法之前，必须调用此初始化，否则，其他函数调用无效
 devcode:开发码
 recogLanguage:识别语言，0中文，3英文
 返回值：0-核心初始化成功；其他失败，具体失败原因参照开发手册
 */
-(int)InitIDCardWithDevcode:(NSString *)devcode recogLanguage:(int) recogLanguage;
/*
 核心6.7.2.3版本之后可用
 设置识别模式及证件类型
 nMode：0－拍照识别、导入识别，1－视频流方式
 nType: 证件类型
 */
- (void)setParameterWithMode:(int)nMode CardType:(int)nType;


/********************************************
 扫描识别专用接口
 ********************************************/

/*
 设置感兴区域
 参数：检边区域在实际图像中到整张图片上、下、左、右的距离，与分辨率和检边区域有关，详见demo设置
 返回值：0-设置成功；其他失败
 */
- (int) setROIWithLeft: (int)nLeft Top: (int)nTop Right: (int)nRight Bottom: (int)nBottom;
/*
 设置二代证识别类型
 nType:0-正反面 1-正面 2-背面
 返回值：0-设置成功；其他失败
 */
-(int) SetDetectIDCardType:(int) nType;

/*
 核心6.7.2.3版本之后可用
 导入内存新接口
 参数：图像帧数据以及其宽高
 返回值：0－成功，其它－失败
 */
- (int) newLoadImageWithBuffer:(UInt8 *)buffer Width:(int)width Height:(int)height;

/*
 核心6.7.2.3版本之后可用
 找边新接口; 调用“导入内存新接口”之后调用此接口
 返回值：IDCardSlideLine类的属性allLine值 1－成功，0－失败
 */
- (IDCardSlideLine *) newConfirmSlideLine;

/*
 光斑检测
 0：检测到敏感区域内有光斑；
 -1：未成功初始化核心；
 -2：敏感区域内未检测到光斑；
 -3：未成功加载图像数据。
 */
- (int)detectLightspot;

/*
 核心6.7.2.3版本之后可用
 检测图片清晰度新接口
 返回值：0－成功，其它－失败
 */
- (int) newCheckPicIsClear;

/*
 获取机读码类型
 参数：图像帧数据以及其宽高、感兴区域
 返回值：1代表1034，2代表1036，3代表1033，即两行和三行机读码
 */
- (int) GetAcquireMRZSignal:(UInt8 *)buffer Width:(int)width Height:(int)height Left:(int)left Right:(int)right Top:(int)top Bottom:(int)bottom RotateType:(int)rotatetype;

/*
 加载机读码
 参数：图像帧数据以及其宽高
 */
- (int) loadMRZImageWithBuffer:(UInt8 *)buffer Width:(int)width Height:(int)height;



/********************************************
 手动拍照&导入识别专用接口
 ********************************************/

/*
 导入图片路径
 lpImageFileName:图片路径；type传入0即可
 返回值：0－成功，其它－失败
 */
-(int)LoadImageToMemoryWithFileName:(NSString *)lpImageFileName Type:(int)type;
/*
 核心6.7.2.3版本之后可用
 图像预处理接口
 nProcessType：0－取消所有操作，1－裁切，2-旋转 3－裁切+旋转，4-倾斜校正  5－裁切+倾斜校正， 6-倾斜校正+旋转 7－裁切+倾斜校正+旋转
 nSetType: 0－取消操作，1－设置操作
 */
- (void)processImageWithProcessType:(int)nProcessType setType:(int)nSetType;



/********************************************
 公共接口
 ********************************************/

/*
 保存裁切后的整幅图片
 path:保存路径
 返回值：0-成功；其他失败
 */
- (int) saveImage:(NSString *)path;

/*
 保存裁切后的头像
 path:保存路径
 返回值：0-成功；其他失败
 */
- (int) saveHeaderImage: (NSString *)path;

/*
 自动识别二代证正反面，需要时调用
 返回值：证件类型代码
 */
- (int) autoRecogChineseID;

/*
 识别证件
 nMainID：证件类型代码
 返回值：证件类型代码
 */
- (int) recogIDCardWithMainID: (int) nMainID;

/*
 获取字段名
 每一种证件类型的字段数量和字段顺序是固定的，详细参考开发手册
 */
-(NSString *)GetFieldNameWithIndex:(int) nIndex;

/*取识别结果*/
-(NSString *)GetRecogResultWithIndex:(int) nIndex;

/*释放核心*/
-(void)recogFree;





/*以下6个接口在核心6.7.2.3版本之后不在使用 扫描识别调用上面的接口 详细见demo*/
//根据证件类型设置剪边
-(int) setConfirmSideMethodWithType:(int) aType;
//是否检测区域的有效性（二代证、护照检边防止误触发），传YES设置，NO不设置
- (int) IsDetectRegionValid:(BOOL) detect;
//180°旋转开关，目前只支持二代证正面
- (int) IsDetect180Rotate:(BOOL) isRotate;
// 找边
- (IDCardSlideLine *) confirmSlideLineWithBuffer:(UInt8 *)buffer Width:(int)width Height:(int)height;
//检测图片是否清晰
- (int) checkPicIsClearWithBuffer:(UInt8 *)buffer width:(int)width height:(int)height;
// 导入内存
- (int) loadImageWithBuffer:(UInt8 *)buffer Width:(int)width Height:(int)height;

/*以下2个接口在核心6.7.2.3版本之后不在使用 导入识别&手动拍照调用上面的接口 详细见demo*/
//旋转 导入识别时用
- (BOOL) AutoRotateImage:(int)recogType;
//裁切 导入识别时用
- (int)AutoCropImage:(int) nID;


@end
