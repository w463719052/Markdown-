//
//  OverView.m
//  TestCamera
//


#import "PlateIDOverView.h"
#import <CoreText/CoreText.h>

#define width 115
#define lineLength 20

@implementation PlateIDOverView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGPoint center = self.center;
        self.smallrect = CGRectMake(center.x-width, center.y-width, width*2, width*2);
        }
    return self;
}


- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [[UIColor redColor] set];
    //获得当前画布区域
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置线的宽度
    CGContextSetLineWidth(currentContext, 2.0f);
    CGPoint center = self.center;
    /*画线*/
    //起点--左上角
    CGContextMoveToPoint(currentContext,center.x-width, center.y-width+lineLength);
    CGContextAddLineToPoint(currentContext, center.x-width, center.y-width);
    CGContextAddLineToPoint(currentContext, center.x-width+lineLength, center.y-width);
    //右上
    CGContextMoveToPoint(currentContext, center.x+width-lineLength,center.y-width);
    CGContextAddLineToPoint(currentContext, center.x+width,center.y-width);
    CGContextAddLineToPoint(currentContext, center.x+width,center.y-width+lineLength);
    //左下
    CGContextMoveToPoint(currentContext, center.x-width,center.y+width-lineLength);
    CGContextAddLineToPoint(currentContext, center.x-width,center.y+width);
    CGContextAddLineToPoint(currentContext, center.x-width+lineLength,center.y+width);
    //右下
    CGContextMoveToPoint(currentContext, center.x+width-lineLength,center.y+width);
    CGContextAddLineToPoint(currentContext, center.x+width,center.y+width);
    CGContextAddLineToPoint(currentContext, center.x+width,center.y+width-lineLength);


    CGContextStrokePath(currentContext);
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
