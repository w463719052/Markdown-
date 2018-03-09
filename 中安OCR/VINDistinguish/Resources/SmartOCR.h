//
//  SmartOCR.h
//  SmartOCR
//

#import <Foundation/Foundation.h>

@interface SmartOCR : NSObject

/**
 *  初始化识别核心
 *
 *  @param aDevcode 开发码
 *
 *  @return 0，初始化正常
 *
 */
- (int) initOcrEngineWithDevcode:(NSString *) aDevcode;

/**
 *  添加识别模板
 *
 *  @param filePath 识别模板路径
 *
 *  @return 0,加载成功
 */
- (int) addTemplateFile:(NSString *)filePath;

/**
 *  设置当前识别类型
 *
 *  @param pTemplateID 识别类型ID
 *
 *  @return 0，成功
 */
- (int) setCurrentTemplate:(NSString *)pTemplateID;

/**
 *  从内存中移除指定的模板
 *
 *  @param filePath 模板路径
 *
 *  @return 0，移除成功
 */
- (int) removeTemplate:(NSString *)filePath;

/**
 *  移除所有模板
 *
 *  @return 0,移除成功
 */
- (int) removeAllTemplates;

/**
 *  转载识别图像
 *
 *  @param imagePath 图像路径
 *  @param nRotateType      识别区域图像的旋转方向
 *
 *  @return 0，成功
 */
- (int) loadImageFile:(NSString *)imagePath RotateType:(int)nRotateType;

/**
 *  设置识别区域
 *
 *  @param left   识别区域图像左侧距离整图左边的位置
 *  @param top    识别区域图像上侧距离整图上方的位置
 *  @param right  识别区域图像右侧距离整图左边的位置
 *  @param bottom 识别区域图像底测距离整图上方的位置
 *
 *  @return 0，设置成功
 */
- (int) setROIWithLeft:(int) left Top:(int)top Right:(int)right Bottom:(int)bottom;

/**
 *  导入bgra格式视频流
 *
 *  @param baseAddress 视频流的地址
 *  @param width       识别区域图像的宽度
 *  @param height      识别区域图像的高度
 *  @param nRotateType      识别区域图像的旋转方向
 *
 *  @return 0，导入成功
 */
- (int) loadStreamBGRA:(uint8_t *)baseAddress Width:(int)width Height:(int)height RotateType:(int)nRotateType;

/**
 *  识别图像
 *
 *  @return 0，识别成功
 */
- (int) recognize;

/**
 *  获取识别结果
 *
 *  @return 识别结果，字符串类型
 */
- (NSString *)getResults;

/**
 *  保存识别图像
 *
 *  @param imagePath 将要保存的路径
 *
 *  @return 返回0保存成功，其他保存失败
 */
- (int) saveImage:(NSString *) imagePath;

/**
 *  获取核心版本号
 *
 *  @return 核心版本号
 */
- (NSString *)getVersionNumber;

/**
 *
 *初始化VIN搜索引擎
 */
- (int) initVINEngine;

/**
 *  获取VIN车辆信息
 *
 *  @return VIN车辆信息
 */

- (NSArray *) searchVINInfoWithVINCode: (NSString *)aVINCode;

/**
 *
 *释放VIN搜索引擎
 */
- (void) unInitVINEngine;

/**
 *  释放核心
 *
 */

- (int) uinitOCREngine;

@end
