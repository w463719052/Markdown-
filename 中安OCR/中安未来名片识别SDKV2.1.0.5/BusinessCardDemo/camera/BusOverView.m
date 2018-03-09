//
//  OverView.m
//  TestCamera
//
//  Created by chinasafe on 14/11/25.
//  Copyright (c) 2014年 chinasafe. All rights reserved.
//

#import "BusOverView.h"

//屏幕的宽、高
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation BusOverView{
    
    /*以下坐标点为横屏时，检边框四个顶点位置命名*/
    CGPoint ldown; //检边框左下角点
    CGPoint rdown; //检边框右下角点
    CGPoint lup; //检边框左上角点
    CGPoint rup; //检边框右上角点
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*
         sRect 为检边框的frame，检边框的位置和大小都可以随意设置，不需其他设置均可识别
         注意：检边框的宽高比例要符合银行卡实际宽高比，名片的 高/宽 = 1.58
         以下是demo对检边框frame的设置，仅供参考~~
         */
        CGRect sRect = CGRectMake(45, 100, 230, 230*1.55);//以苹果5屏幕大小为模板设置sRect
        
        if (kScreenHeight == 480)
        {//苹果4屏幕上sRect
            sRect = CGRectMake(CGRectGetMinX(sRect), CGRectGetMinY(sRect)-44, CGRectGetWidth(sRect), CGRectGetHeight(sRect));
           
        }else
        {//大屏幕在苹果5屏幕基础上等比例放大sRect
            CGFloat scale = kScreenWidth/320;
            sRect = CGRectMake(CGRectGetMinX(sRect)*scale, CGRectGetMinY(sRect)*scale, CGRectGetWidth(sRect)*scale, CGRectGetHeight(sRect)*scale);
        }
        
        ldown = CGPointMake(CGRectGetMinX(sRect), CGRectGetMinY(sRect));
        lup  = CGPointMake(CGRectGetMaxX(sRect), CGRectGetMinY(sRect));
        rdown = CGPointMake(CGRectGetMinX(sRect), CGRectGetMaxY(sRect));
        rup = CGPointMake(CGRectGetMaxX(sRect), CGRectGetMaxY(sRect));
        self.smallrect = sRect;
        
        UILabel *pointL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(sRect), CGRectGetHeight(sRect))];
        pointL.text = @"请将名片对准此取景框";
        pointL.textAlignment = NSTextAlignmentCenter;
        pointL.textColor = [UIColor whiteColor];
        pointL.transform = CGAffineTransformMakeRotation(M_PI_2);
        pointL.center = CGPointMake(CGRectGetMidX(sRect), CGRectGetMidY(sRect));
        [self addSubview:pointL];
        

    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [[UIColor greenColor] set];
    //获得当前画布区域
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置线的宽度
    CGContextSetLineWidth(currentContext, 2.0f);
    
    /*画线*/
    //起点--左下角
    int s = 25;
    CGContextMoveToPoint(currentContext,ldown.x, ldown.y+s);
    CGContextAddLineToPoint(currentContext, ldown.x, ldown.y);
    CGContextAddLineToPoint(currentContext, ldown.x+s, ldown.y);
    
    //右下角
    CGContextMoveToPoint(currentContext, rdown.x,rdown.y-s);
    CGContextAddLineToPoint(currentContext, rdown.x,rdown.y);
    CGContextAddLineToPoint(currentContext, rdown.x+s,rdown.y);
    
    //左上角
    CGContextMoveToPoint(currentContext, lup.x-s,lup.y);
    CGContextAddLineToPoint(currentContext, lup.x,lup.y);
    CGContextAddLineToPoint(currentContext, lup.x,lup.y+s);
    
    //右上角
    CGContextMoveToPoint(currentContext, rup.x, rup.y-s);
    CGContextAddLineToPoint(currentContext, rup.x, rup.y);
    CGContextAddLineToPoint(currentContext, rup.x-s, rup.y);
    
    //四条线
    if (_leftHidden) {
        CGContextMoveToPoint(currentContext, ldown.x+s, ldown.y);
        CGContextAddLineToPoint(currentContext, lup.x-s,lup.y);
    }
    if (_rightHidden) {
        CGContextMoveToPoint(currentContext, rdown.x+s,rdown.y);
        CGContextAddLineToPoint(currentContext, rup.x-s, rup.y);
    }
    
    if (_topHidden) {
        CGContextMoveToPoint(currentContext, lup.x,lup.y+s);
        CGContextAddLineToPoint(currentContext, rup.x, rup.y-s);
    }
    if (_bottomHidden) {
        CGContextMoveToPoint(currentContext, ldown.x, ldown.y+s);
        CGContextAddLineToPoint(currentContext, rdown.x,rdown.y-s);
    }
    
    CGContextStrokePath(currentContext);
}

/*
    设置四条线的显隐
 */
- (void) setTopHidden:(BOOL)topHidden
{
    if (_topHidden == topHidden) {
        return;
    }
    _topHidden = topHidden;
    [self setNeedsDisplay];
}

- (void) setLeftHidden:(BOOL)leftHidden
{
    if (_leftHidden == leftHidden) {
        return;
    }
    _leftHidden = leftHidden;
    [self setNeedsDisplay];
}

- (void) setBottomHidden:(BOOL)bottomHidden
{
    if (_bottomHidden == bottomHidden) {
        return;
    }
    _bottomHidden = bottomHidden;
    [self setNeedsDisplay];
}

- (void) setRightHidden:(BOOL)rightHidden
{
    if (_rightHidden == rightHidden) {
        return;
    }
    _rightHidden = rightHidden;
    [self setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
