//
//  ResultViewController.m
//  BusinessCardDemo
//
//  Created by chinasafe on 16/1/26.
//  Copyright © 2016年 chinasafe. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //裁切图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 200)];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.image = self.savedImage;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];

    //识别结果
    NSString *allResult = @"";
    for (NSString *field in [self.resultDic allKeys]) {
        NSArray *results = [self.resultDic objectForKey:field];
        for (NSString *result in results) {
            allResult = [allResult stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n", field, result]];
        }
    }
    
    self.TextView = [[UITextView alloc ]initWithFrame:CGRectMake(0, 264, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.TextView];
    self.TextView.editable = NO;
    
    self.TextView.text = allResult;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;

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
