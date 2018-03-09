//
//  WTResultViewController.m
//  PlateIDDemo
//


#import "PlateIDResultViewController.h"
#import "ViewController.h"
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width


@interface PlateIDResultViewController ()

@end

@implementation PlateIDResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imgView = [[UIImageView alloc] init];
    UIImage *image = [self cropImageWithRect:_plateResult.nCarRect];
    imgView.frame = CGRectMake(50, 100, kScreenWidth - 100 , 68);
    imgView.image = image;
    [self.view addSubview:imgView];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imgView.frame) + 50, self.view.bounds.size.width, self.view.bounds.size.height - 300)];
    textView.text = [NSString stringWithFormat:@"车牌号:%@\n 车牌颜色:%@\n 可信度:%d\n 识别时间%d\n", _plateResult.license, _plateResult.color,_plateResult.nConfidence, _plateResult.nTime];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.font = [UIFont systemFontOfSize:17.0];
    textView.editable = NO;
    [self.view addSubview:textView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((kScreenWidth - 300)/2, CGRectGetMaxY(textView.frame), 300, 30);
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)ok {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (UIImage *)cropImageWithRect: (CGRect) rect
{
    NSLog(@"%@", NSStringFromCGRect(rect));
    CGImageRef imageRef = _img.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, subImageRef);
    UIImage *newImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    
    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
