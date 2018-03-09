//
//  ResultViewController.m
//  IDCardDemo
//
//  Created by chinasafe on 15/6/18.
//  Copyright (c) 2015年 chinasafe. All rights reserved.
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
    self.textView.text = self.resultString;
    self.imageVIew.image = [UIImage imageWithContentsOfFile:self.imagePath];
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
