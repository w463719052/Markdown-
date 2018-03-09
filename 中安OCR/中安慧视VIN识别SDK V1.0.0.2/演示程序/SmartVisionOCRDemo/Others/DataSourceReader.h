//
//  DataSourceReader.h
//  SmartvisionOCR
//

#import <Foundation/Foundation.h>

@interface DataSourceReader : NSObject
//获取所有主类型
+(NSMutableArray *) getAllMainTypeDataSource;
//获取选中的主类型
+(NSMutableArray *) getMainTypeDataSource;
//获取子类型
+(NSMutableArray *) getSubTypeDataSource: (NSString *) mainType;
@end
