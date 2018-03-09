//
//  PlateResult.h
//  PlateIDPro
//


#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

//车牌颜色
#define LC_UNKNOWN  0	// 未知
#define LC_BLUE   1		// 蓝色
#define LC_YELLOW 2		// 黄色
#define LC_WHITE  3		// 白色
#define LC_BLACK  4		// 黑色
#define LC_GREEN  5		// 绿色
#define LC_YELLOWGREEN  6	//黄绿色-大型新能源车牌颜色


//车牌类型
#define LT_UNKNOWN  0   //未知车牌
#define LT_BLUE     1   //蓝牌
#define LT_BLACK    2   //黑牌
#define LT_YELLOW   3   //单排黄牌
#define LT_YELLOW2  4   //双排黄牌（大车尾牌，农用车）
#define LT_POLICE   5   //警车车牌
#define LT_ARMPOL   6   //武警车牌
#define LT_INDIVI   7   //个性化车牌
#define LT_ARMY     8   //单排军车
#define LT_ARMY2    9   //双排军车
#define LT_EMBASSY  10  //使馆牌
#define LT_HONGKONG 11  //香港牌
#define LT_TRACTOR  12  //拖拉机
#define LT_MACAU    13  //澳门牌
#define LT_CHANGNEI 14  //厂内牌
#define LT_MINHANG  15  //民航牌
#define LT_CONSULATE 16 //领事馆车牌
#define LT_NEWENERGY 17 //新能源车牌-小型车
#define LT_NEWENERGY2 18 //新能源车牌-大型车

//车辆颜色
#define LGRAY_DARK	0	//深
#define LGRAY_LIGHT	1	//浅

#define LCOLOUR_WHITE	0	//白
#define LCOLOUR_SILVER	1	//灰(银)
#define LCOLOUR_YELLOW	2	//黄
#define LCOLOUR_PINK	3	//粉
#define LCOLOUR_RED		4	//红
#define LCOLOUR_GREEN	5	//绿
#define LCOLOUR_BLUE	6	//蓝
#define LCOLOUR_BROWN	7	//棕
#define LCOLOUR_BLACK	8	//黑


//运动方向
#define DIRECTION_UNKNOWN	0
#define DIRECTION_LEFT	1
#define DIRECTION_RIGHT	2
#define DIRECTION_UP	3
#define DIRECTION_DOWN	4

//车标类型
#define CarLogo_UNKNOWN       0    //未知
#define CarLogo_AUDI          1    //奥迪
#define CarLogo_BMW           2    //宝马
#define CarLogo_BENZ          3    //奔驰
#define CarLogo_HONDA         4    //本田
#define CarLogo_PEUGEOT       5    //标志
#define CarLogo_BUICK         6    //别克
#define CarLogo_DASAUTO       7    //大众
#define CarLogo_TOYOTA        8    //丰田
#define CarLogo_FORD          9    //福特
#define CarLogo_SUZUKI        10   //铃木
#define CarLogo_MAZDA         11   //马自达
#define CarLogo_KIA           12   //起亚
#define CarLogo_NISSAN        13   //日产尼桑
#define CarLogo_HYUNDAI       14   //现代
#define CarLogo_CHEVROLET     15   //雪佛兰
#define CarLogo_CITROEN       16   //雪铁龙

#define CarLogo_QIRUI         17   //奇瑞
#define CarLogo_WULING        18   //五菱
#define CarLogo_DONGFENG      19   //东风
#define CarLogo_JIANGHUAI     20   //江淮
#define CarLogo_BEIQI         21   //北汽
#define CarLogo_CHANGAN       22   //长安
#define CarLogo_AOCHI         23   //奥驰
#define CarLogo_SHAOLING      24   //少林
#define CarLogo_SHANQI        25   //陕汽
#define CarLogo_SANLING       26   //三菱
#define CarLogo_JILI          27   //吉利
#define CarLogo_HAOWO         28   //豪沃
#define CarLogo_HAIMA         29   //海马
#define CarLogo_HAFEI         30   //哈飞
#define CarLogo_CHANGCHENG    31   //长城
#define CarLogo_FUTIAN        32   //福田
#define CarLogo_NANJUN        33   //南骏
#define CarLogo_LIUQI         34   //柳汽

// 车辆类型
#define CARTYPE_UNKNOWN		0	// 未知
#define CARTYPE_SALOON		1	// 轿车
#define CARTYPE_VAN			2	// 面包车

@interface PlateResult : NSObject

//车牌字符串
@property (strong, nonatomic) NSString *license;
//车牌颜色
@property (strong, nonatomic) NSString *color;
//车牌颜色数值
@property (assign, nonatomic) int nColor;
//车牌类型
@property (assign, nonatomic) int nType;
// 亮度评价
@property (assign, nonatomic) int nBright;
// 车牌运动方向，0 unknown, 1 left, 2 right, 3 up, 4 down
@property (assign, nonatomic) int nDirection;
//整牌可信度
@property (assign, nonatomic) int nConfidence;
//识别时间
@property (assign, nonatomic) int nTime;
//车的颜色
@property (assign, nonatomic) int nCarColor;
//车标类型
@property (assign, nonatomic) int nCarLogo;
//车辆类型
@property (assign, nonatomic) int nCarType;
//车的亮度
@property (assign, nonatomic) int nCarBright;
//车牌位置
@property (assign, nonatomic) CGRect nCarRect;
//识别后的车牌整图
@property (strong, nonatomic) UIImage *nCarImage;


@end
