//
//  OverView.m
//  TestCamera
//
//  Created by chinasafe on 14/11/25.
//  Copyright (c) 2014年 zzzili. All rights reserved.
//

#import "OverView.h"
#import <CoreText/CoreText.h>

#define kRecogScreenSize 0.8

@implementation OverView{
    
    CGPoint ldown;
    CGPoint rdown;
    CGPoint lup;
    CGPoint rup;
    CGRect pointRect;
    CGRect textRect;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect sRect;
        CGFloat width = self.frame.size.width;
        CGFloat sWidth = width*kRecogScreenSize;
        CGFloat sHeight = sWidth*1.55;
        sRect = CGRectMake(self.center.x-sWidth/2, self.center.y-sHeight/2, sWidth, sHeight);
        ldown = CGPointMake(CGRectGetMinX(sRect), CGRectGetMinY(sRect));
        lup  = CGPointMake(CGRectGetMaxX(sRect), CGRectGetMinY(sRect));
        rdown = CGPointMake(CGRectGetMinX(sRect), CGRectGetMaxY(sRect));
        rup = CGPointMake(CGRectGetMaxX(sRect), CGRectGetMaxY(sRect));
        self.smallrect = sRect;
    }
    return self;
}


- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [[UIColor orangeColor] set];
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

//设置mrz边框
- (void) setMRZBolder
{
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
