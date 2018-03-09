//
//  PlateFormat.h
//  PlateIDPro
//


#import <Foundation/Foundation.h>

@interface PlateFormat : NSObject

@property (assign, nonatomic) int armpolice;// 单层武警车牌是否开启:1是；0不是

@property (assign, nonatomic) int armpolice2;// 双层武警车牌是否开启:1是；0不是

@property (assign, nonatomic) int embassy;// 使馆车牌是否开启:1是；0不是

@property (assign, nonatomic) int individual;// 是否开启个性化车牌:1是；0不是

@property (assign, nonatomic) int nOCR_Th;// 识别阈值(取值范围0-9,5:默认阈值0:最宽松的阈值9:最严格的阈值)

@property (assign, nonatomic) int nPlateLocate_Th;//定位阈值(取值范围0-9,5:默认阈值0:最宽松的阈值9:最严格的阈值)

@property (assign, nonatomic) int tworowyellow;//双层黄色车牌是否开启:1是；0不是

@property (assign, nonatomic) int tworowarmy;// 双层军队车牌是否开启:1是；0不是

@property (strong, nonatomic) NSString *szProvince;// 省份顺序

@property (assign, nonatomic) int mtractor;// 农用车车牌是否开启:1是；0不是

@property (assign, nonatomic) int tworowyellow_only;//只识别双层黄牌是否开启:1是；0不是

@property (assign, nonatomic) int civilAviation;// 民航车牌是否开启：1是；0不是

@property (assign, nonatomic) int consulate;// 领事馆车牌是否开启：1是；0不是

@property (assign, nonatomic) int newEnergy;// 新能源车牌是否开启：1是；0不是

@end
