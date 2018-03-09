//
//  ResultViewController.h
//  SmartVisionOCRDemo
//

#import <UIKit/UIKit.h>
#import "SmartOCR.h"

@interface ResultViewController : UIViewController

@property (strong, nonatomic) NSArray *imagePaths;//识别图像路径
@property (strong, nonatomic) NSArray *resultData;//识别结果
@property (strong, nonatomic) NSArray *fieldData;//识别字段名
@property (strong, nonatomic) SmartOCR *ocr;

@end
