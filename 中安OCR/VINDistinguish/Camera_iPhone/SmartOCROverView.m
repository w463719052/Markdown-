//
//  OverView.m
//  TestCamera
//

#import "SmartOCROverView.h"
#import <CoreText/CoreText.h>

@implementation SmartOCROverView{
    
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
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
    
    CGContextMoveToPoint(currentContext, CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds));
    CGContextAddLineToPoint(currentContext, CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds));
    CGContextAddLineToPoint(currentContext, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
    CGContextAddLineToPoint(currentContext, CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
    CGContextAddLineToPoint(currentContext, CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds));

    
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
