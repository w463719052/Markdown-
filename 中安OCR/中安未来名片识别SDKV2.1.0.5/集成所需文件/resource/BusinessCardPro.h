//
//  BusinessCardPro.h
//  BusinessCardPro
//
//  Created by chinasafe on 16/3/29.
//  Copyright © 2016年 chinasafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessCardPro : NSObject

/*
 初始化核心,调用其他方法之前，必须调用此初始化，否则，其他函数调用无效
 参数：devcode:开发码； recogType：11为视频流扫描识别模式，10为导入识别模式
 返回值：0-核心初始化成功；其他失败，具体失败原因参照开发手册
 */
-(int)initWithDevcode:(NSString *)devcode RecogType:(int)recogType;

/*
 设置感兴区域
 参数：检边区域在实际图像中到整张图片上、下、左、右的距离，与图像分辨率和检边区域frame有关，详见demo设置
 */
- (int) setROIWithLeft:(int)nLeft Right:(int)nRight Top:(int)nTop Bottom:(int)nBottom;

/*
 检边接口
 参数：图像帧数据以及其宽高
 返回值：1-检测到边线，0-表示未检测到边线
 */
- (BOOL) confirmSlideLineWithBuffer:(UInt8 *)buffer Width:(int)width Height:(int)height;

/*
 检测清晰度接口
 参数：图像帧数据以及其宽高
 返回值：1-图片清晰
 */
- (BOOL) checkPicClearWithImageBuffer:(UInt8 *)buffer Width:(int)width Height:(int)height;

/*
 视频流识别接口
 参数：图像帧数据以及其宽高；nCardType-1简体中文名片
 返回值：0-识别成功，其他值失败
 */
- (int) RecogBusinessCardWithImageBuffer:(UInt8 *)buffer Width:(int)width Height:(int)height CardType:(int)nCardType;
/*
 导入识别接口（根据路径识别图片）
 参数：imagePath-图片路径；nCardType-1简体中文名片
 返回值：0-识别成功，其他值失败
 */
-(int)RecogImageWithImagePath:(NSString *)imagePath CardType:(int)nCardType;

/*获取对应的字段名*/
-(NSString *)getFieldnameWithFieldNumber:(int)fieldNumber;

/*获取对应字段的值的个数*/
-(int)getResultCountWithFieldNumber:(int)fieldNumber;

/*获取对应字段的值，此方法不会对“电话”、“传真”、“手机”三个字段拆分，例如：电话一行有两个电话号码时，只会有一个字符串输出，字符串包含两个电话号码*/
- (NSString *)getRecogResultWithFieldNumner:(int)fieldNumber ResultCount:(int)resultCount;

/*拆分电话号码，只适用于“电话”、“传真”、“手机”三个字段。例如：电话一行有两个电话号码时，拆分成两个电话号码字符串输出；电话一行有一个电话号码时，一个电话号码字符串输出*/
/*拆分“电话”、“传真”、“手机”三个字段，获取每个字段的值的个数*/
-(int)getPhoneNumeberCount:(int)fieldNumber ResultCount:(int)resultCount;
/*拆分“电话”、“传真”、“手机”三个字段，获取每个字段的值*/
-(NSString *)getRecogResultWithNumnerIndex:(int)numberIndex;
/*保存裁切后的图片到lpSaveImagePath 在调用识别方法之前调用*/
-(int)SetSaveImagePath:(NSString *)lpSaveImagePath;

/*释放核心*/
-(void)freeBusinessCard;

/*获取核心版本号*/
- (NSString *)getBusnessCoreVersion;


@end
