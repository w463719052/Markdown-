//
//  OverView.h
//  TestCamera
//
//  Created by chinasafe on 14/11/25.
//  Copyright (c) 2014年 chinasafe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusOverView : UIView

@property (assign, nonatomic) BOOL leftHidden;
@property (assign, nonatomic) BOOL rightHidden;
@property (assign, nonatomic) BOOL topHidden;
@property (assign, nonatomic) BOOL bottomHidden;

@property (assign ,nonatomic) CGRect smallrect;

@end
