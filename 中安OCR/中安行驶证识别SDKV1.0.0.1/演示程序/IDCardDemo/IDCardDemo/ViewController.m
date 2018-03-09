//
//  ViewController.m
//  IDCardDemo
//
//  Created by chinasafe on 15/6/2.
//  Copyright (c) 2015年 chinasafe. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"
#import "Type.h"
#import "IDCardOCR.h"
#import "ResultViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSString *_imagePath;
}

@property (strong, nonatomic) NSMutableArray *types;

@property (assign, nonatomic) int cardType;

@property (assign, nonatomic) int resultCount;

@property (strong, nonatomic) NSString *typeName;

@property (strong, nonatomic) IDCardOCR *cardRecog;

@end

@implementation ViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //默认证件类型为二代证正面
    self.cardType = 6;
    self.resultCount = 11;
    self.typeName = @"中国行驶证";
}

//拍照识别
- (IBAction)recogImage:(id)sender
{
    CameraViewController *cameraVC = [[CameraViewController alloc] init];
    cameraVC.recogType = self.cardType;
    cameraVC.resultCount = self.resultCount;
    cameraVC.typeName = self.typeName;
    [self.navigationController pushViewController:cameraVC animated:YES];
}
//选择识别
- (IBAction)selectToRecog:(id)sender
{
    [self performSelectorInBackground:@selector(initRecog) withObject:nil];
    //初始化相册
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing=YES;
    picker.sourceType=sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

//初始化核心
- (void) initRecog
{
    self.cardRecog = [[IDCardOCR alloc] init];
    /*提示：该开发码和项目中的授权仅为演示用，客户开发时请替换该开发码及项目中Copy Bundle Resources 中的.lsc授权文件*/
    int intRecog = [self.cardRecog InitIDCardWithDevcode:@"5YYX5LQS5LIT5A6" recogLanguage:0];
    NSLog(@"intRecog = %d",intRecog);
}

#pragma mark--选取相册图片

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self performSelectorInBackground:@selector(didFinishedSelect:) withObject:image];
}

//存储照片
-(void)didFinishedSelect:(UIImage *)image
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:@"chinasafeIDCardFree.jpg"];
    //存储图片
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:imageFilePath atomically:YES];
    _imagePath = imageFilePath;
    [self performSelectorInBackground:@selector(recog) withObject:nil];
}

//取消选择
-(void)imagePickerControllerDIdCancel:(UIImagePickerController*)picker

{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)recog
{
    int loadImage = [self.cardRecog LoadImageToMemoryWithFileName:_imagePath Type:0];
        
    NSLog(@"loadImage = %d", loadImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *caches = paths[0];
    NSString *imagepath = [caches stringByAppendingPathComponent:@"image.jpg"];
    NSString *headImagePath = [caches stringByAppendingPathComponent:@"head.jpg"];
    
    [self.cardRecog AutoRotateImage:2];
    [self.cardRecog AutoCropImage:self.cardType];
    
    [self.cardRecog saveImage:imagepath];
    
    //其他证件
    [self.cardRecog recogIDCardWithMainID:self.cardType];
    //非机读码，保存头像
    [self.cardRecog saveHeaderImage:headImagePath];
        
        //获取识别结果
        NSString *allResult = @"";
        for (int i = 1; i < self.resultCount; i++) {
            //获取字段值
            NSString *field = [self.cardRecog GetFieldNameWithIndex:i];
            //获取字段结果
            NSString *result = [self.cardRecog GetRecogResultWithIndex:i];
            NSLog(@"%@:%@\n",field, result);
            if(field != NULL){
                allResult = [allResult stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n", field, result]];
            }
        }
        if (![allResult isEqualToString:@""]) {
            //识别结果不为空，跳转到结果展示页面
            ResultViewController *rvc = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
            NSLog(@"allresult = %@", allResult);
            rvc.resultString = allResult;
            rvc.imagePath = imagepath;
            [self.navigationController pushViewController:rvc animated:YES];
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
