//
//  ResultViewController.m
//  IDCardDemo
//

#import "ResultViewController.h"
#import "ViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //识别完成后裁切的图片
    UIImageView *imageView = [[UIImageView alloc]init];
    UIImage *image = [UIImage imageWithContentsOfFile:self.cropImagepath];
    CGSize size = image.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat imageViewHeight = self.view.bounds.size.width*height/width;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 64, self.view.bounds.size.width, imageViewHeight);
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.image = image;
    [self.view addSubview:imageView];
    
    //识别的结果
    UITextView *textview = [[UITextView alloc] initWithFrame:CGRectMake(0, 64+imageViewHeight, self.view.bounds.size.width, self.view.bounds.size.height-64-imageViewHeight)];
    [self.view addSubview:textview];
    textview.text = self.resultString;
    textview.font = [UIFont systemFontOfSize:17.0];
    textview.textAlignment = NSTextAlignmentLeft;
    textview.editable = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
