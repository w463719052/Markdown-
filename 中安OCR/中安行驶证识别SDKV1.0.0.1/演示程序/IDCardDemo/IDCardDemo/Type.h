//
//  Type.h
//  IDCardDemo
//
//  Created by chinasafe on 15/6/17.
//  Copyright (c) 2015年 chinasafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Type : NSObject

//证件名称
@property (strong, nonatomic) NSString *typeName;
//证件代码
@property (assign, nonatomic) int typeCode;
//字段个数
@property (assign, nonatomic) int count;
@end
