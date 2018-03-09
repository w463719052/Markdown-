//
//  ViewController.m
//  SmartVisionOCRDemo
//

#import "ViewController.h"
#import "SmartOCRCameraViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)scaning:(id)sender
{
    SmartOCRCameraViewController *camera = [[SmartOCRCameraViewController alloc] init];
    [self.navigationController pushViewController:camera animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
