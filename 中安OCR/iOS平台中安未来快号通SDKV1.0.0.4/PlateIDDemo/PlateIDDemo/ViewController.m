//
//  ViewController.m
//  PlateIDDemo
//


#import "ViewController.h"
#import "PlateIDCameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"扫描识别" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 300, 30);
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(scanRecog) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    
}

- (void) scanRecog
{
    PlateIDCameraViewController *camera = [[PlateIDCameraViewController alloc] init];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:camera animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
