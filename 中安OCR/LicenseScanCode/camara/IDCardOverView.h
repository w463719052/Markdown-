//
//  OverView.h
//  TestCamera
//

#import <UIKit/UIKit.h>

@interface IDCardOverView : UIView

@property (assign, nonatomic) BOOL leftHidden;
@property (assign, nonatomic) BOOL rightHidden;
@property (assign, nonatomic) BOOL topHidden;
@property (assign, nonatomic) BOOL bottomHidden;

@property (assign, nonatomic) BOOL mrz;
@property (assign, nonatomic) BOOL isHorizontal;//是否横屏

@property (assign ,nonatomic) NSInteger smallX;
@property (assign ,nonatomic) CGRect smallrect;
@property (assign, nonatomic) CGRect mrzSmallRect;

- (void) setRecogArea;

@end
