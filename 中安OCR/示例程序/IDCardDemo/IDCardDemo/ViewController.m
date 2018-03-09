//
//  ViewController.m
//  IDCardDemo
//

#import "ViewController.h"
#import "ResultViewController.h"

#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
#import "IDCardCameraViewController.h"
#import "IDCardOCR.h"
#endif

@interface ViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSString *_originalImagepath;   //识别原图路径
    NSString *_cropImagepath;       //识别完成后裁切证件图片路径
    NSString *_headImagePath;       //识别完成后裁切头像图片路径
    NSDictionary *_IDTypeDic;
}

@property (strong, nonatomic) NSMutableArray *types;

@property (assign, nonatomic) int cardType;

@property (assign, nonatomic) int resultCount;

@property (strong, nonatomic) NSString *typeName;

#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
@property (strong, nonatomic) IDCardOCR *cardRecog;
#endif


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
    self.view.backgroundColor = [UIColor whiteColor];
    
    //设置图片存储路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    _originalImagepath = [documentsDirectory stringByAppendingPathComponent:@"originalImage.jpg"];
    _cropImagepath = [documentsDirectory stringByAppendingPathComponent:@"cropImage.jpg"];
    _headImagePath = [documentsDirectory stringByAppendingPathComponent:@"headImage.jpg"];
    
    //默认证件类型为二代证正面
    self.cardType = 2;
    self.typeName = NSLocalizedString(@"二代身份证正面", nil) ;
    //初始化证件类型
    [self setCardTypes];
    
}

- (void)setCardTypes{
    
    /*证件类型对应代号字典*/
    _IDTypeDic =@{
                  /*证件类型ID:证件名字*/
                  @1:@"一代身份证",
                  @2:@"二代身份证正面",
                  @3:@"二代身份证背面",
                  @4:@"临时身份证",
                  @5:@"中国驾照",
                  @28:@"中国驾照副业",
                  @6:@"中国行驶证",
                  @7:@"军官证",
                  @8:@"士兵证(暂不支持)",
                  @9:@"中华人民共和国往来港澳通行证",
                  @22:@"新版港澳通行证",
                  @10:@"台湾居民往来大陆通行证(台胞证)",
                  @11:@"大陆居民往来台湾通行证",
                  @12:@"中国签证",
                  @13:@"护照",
                  @14:@"港澳居民来往内地通行证正面（回乡证）",
                  @15:@"港澳居民来往内地通行证背面（回乡证）",
                  @16:@"户口本",
                  @1000:@"居住证",
                  @1001:@"香港永久性居民身份证",
                  @1002:@"登机牌（拍照设备目前不支持登机牌的识别）",
                  @1003:@"边民证(A)(照片页)",
                  @1004:@"边民证(B)(个人信息页)",
                  @1005:@"澳门身份证",
                  @1012:@"新版澳门身份证",
                  @1007:@"律师证(A)(信息页)",
                  @1008:@"律师证(B)(照片页)",
                  @1009:@"中华人民共和国道路运输证IC卡",
                  @3000:@"机读码",
                  @1030:@"全民健康保险卡",
                  @1031:@"台湾身份证正面",
                  @1032:@"台湾身份证背面",
                  @2001:@"马来西亚身份证",
                  @2002:@"加利福尼亚驾照",
                  @2003:@"新西兰驾照",
                  @2004:@"新加坡身份证"
                  };
}

//选择证件类型
- (IBAction)selectCardType:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.title = NSLocalizedString(@"选择证件类型", nil);
    
    for (NSString *str in [_IDTypeDic allValues]) {
        [actionSheet addButtonWithTitle:str];
        
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"取消", nil)];
    actionSheet.cancelButtonIndex = [[_IDTypeDic allKeys] count];
    [actionSheet showInView:self.view];
    
}
#pragma mark - UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    self.cardType = [[[_IDTypeDic allKeys] objectAtIndex:buttonIndex] intValue];
    self.typeName = [[_IDTypeDic allValues] objectAtIndex:buttonIndex];
}

#if TARGET_IPHONE_SIMULATOR//模拟器

#elif TARGET_OS_IPHONE//真机
- (IBAction)scanningInHorizontalScreen:(id)sender
{
    //横屏识别
    [self initCameraWithRecogOrientation:RecogInHorizontalScreen];
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

- (IBAction)scanningInVerticalScreen:(id)sender
{
    //竖屏扫描识别
    [self initCameraWithRecogOrientation:RecogInVerticalScreen];
}

- (void) initCameraWithRecogOrientation: (RecogOrientation)recogOrientation
{
    IDCardCameraViewController *cameraVC = [[IDCardCameraViewController alloc] init];
    cameraVC.recogType = self.cardType;
    cameraVC.typeName = self.typeName;
    cameraVC.recogOrientation = recogOrientation;
    [self.navigationController pushViewController:cameraVC animated:YES];
}

//初始化核心
- (void) initRecog
{
    NSDate *before = [NSDate date];
    self.cardRecog = [[IDCardOCR alloc] init];
    /*提示：该开发码和项目中的授权仅为演示用，客户开发时请替换该开发码及项目中Copy Bundle Resources 中的.lsc授权文件*/
    int intRecog = [self.cardRecog InitIDCardWithDevcode:@"5YYX5LQS5LIT5A6" recogLanguage:0];
    NSLog(@"intRecog = %d",intRecog);
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:before];
    NSLog(@"%f", time);
}

#pragma mark--选取相册图片
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self performSelectorInBackground:@selector(didFinishedSelect:) withObject:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//存储照片
-(void)didFinishedSelect:(UIImage *)image
{
    //存储图片
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:_originalImagepath atomically:YES];
    [self performSelectorInBackground:@selector(recog) withObject:nil];
}

//取消选择
-(void)imagePickerControllerDIdCancel:(UIImagePickerController*)picker

{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)recog
{
    //设置导入识别模式和证件类型
    [self.cardRecog setParameterWithMode:0 CardType:self.cardType];
    //图片预处理 7－裁切+倾斜校正+旋转
    [self.cardRecog processImageWithProcessType:7 setType:1];
    
    //导入图片数据
    int loadImage = [self.cardRecog LoadImageToMemoryWithFileName:_originalImagepath Type:0];
    NSLog(@"loadImage = %d", loadImage);
    if (self.cardType != 3000) {//***注意：机读码需要自己重新设置类型来识别
        if (self.cardType == 2) {
            
            //自动分辨二代证正反面
            [self.cardRecog autoRecogChineseID];
        }else{
            //其他证件
            [self.cardRecog recogIDCardWithMainID:self.cardType];
        }
        //非机读码，保存头像
        [self.cardRecog saveHeaderImage:_headImagePath];
        
        //获取识别结果
        NSString *allResult = @"";
        [self.cardRecog saveImage:_cropImagepath];
        
        for (int i = 1; i < 20; i++) {

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
            [self performSelectorOnMainThread:@selector(createResultView:) withObject:allResult waitUntilDone:YES];
        }
    }
}

- (void)createResultView:(NSString *)allResult{
    ResultViewController *rvc = [[ResultViewController alloc] init];
    NSLog(@"allresult = %@", allResult);
    rvc.resultString = allResult;
    rvc.cropImagepath = _cropImagepath;
    rvc.headImagepath = _headImagePath;
    [self.navigationController pushViewController:rvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#endif


@end
