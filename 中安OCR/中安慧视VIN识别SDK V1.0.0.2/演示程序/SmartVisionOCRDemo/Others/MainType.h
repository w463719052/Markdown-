//
//  MainType.h
//  SmartvisionOCR
//

#import <Foundation/Foundation.h>

@interface MainType : NSObject

//识别主类型代号
@property (strong, nonatomic) NSString *type;
//识别主类型名称
@property (strong, nonatomic) NSString *typeName;
//是否选中
@property (strong, nonatomic) NSString *selected;

@end
