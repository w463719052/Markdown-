//
//  ResultViewController.h
//  IDCardDemo
//
//  Created by chinasafe on 15/6/18.
//  Copyright (c) 2015年 chinasafe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultViewController : UIViewController

@property (strong, nonatomic) NSString *resultString;
@property (strong, nonatomic) NSString *imagePath;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageVIew;

@end
