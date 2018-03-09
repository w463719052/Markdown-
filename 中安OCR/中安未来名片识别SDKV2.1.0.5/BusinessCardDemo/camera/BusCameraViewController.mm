//
//  Created by chinasafe on 15-9-24.
//  Copyright (c) 2013年 chinasafe. All rights reserved.
//

#import "BusCameraViewController.h"
#import "BusOverView.h"
#import "BusinessCardPro.h"
#import "ResultViewController.h"

//屏幕的宽、高
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface BusCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_captureInput;
    AVCaptureStillImageOutput *_captureOutput;
    AVCaptureVideoPreviewLayer *_preview;
    AVCaptureDevice *_device;
    
    BusOverView *_overView;
    int _count;
    BOOL _on;
    BOOL _isSancRecog;
    
    int _MaxFR;
    CGFloat _isLensChanged;//镜头位置
    BOOL _isFoucePixel;//是否相位对焦
    /*相位聚焦下镜头位置 镜头晃动 值不停的改变 */
    CGFloat _isIOS8AndFoucePixelLensPosition;
    
    NSString *_documentsDirectory; //路径
}

@property (strong, nonatomic) BusinessCardPro *cardRecog;
@property (assign, nonatomic) BOOL adjustingFocus;
@property (nonatomic, retain) CALayer *customLayer;
@property (nonatomic,assign) BOOL isProcessingImage;

@end
@implementation BusCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _documentsDirectory = [paths objectAtIndex:0];
    
    //初始化核心
    [self initRecog];
    
    //初始化相机
    [self initialize];
    
    //创建相机界面控件
    [self createCameraView];
    
}

#pragma mark -----------view的出现和消失---------
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //注册通知
    if (_isFoucePixel) {
        [camDevice addObserver:self forKeyPath:@"lensPosition" options:NSKeyValueObservingOptionNew context:nil];}
    [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    [_session startRunning];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (_isFoucePixel) {
        [camDevice removeObserver:self forKeyPath:@"lensPosition"];
    }
    [camDevice removeObserver:self forKeyPath:@"adjustingFocus"];
    [_session stopRunning];
}

#pragma mark -----------监听方法---------
//监听对焦
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if([keyPath isEqualToString:@"adjustingFocus"]){
        self.adjustingFocus =[[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        //NSLog(@"Is adjusting focus? %@", self.adjustingFocus ?@"YES":@"NO");
    }
    /*监听相位对焦此*/
    if([keyPath isEqualToString:@"lensPosition"]){
        _isIOS8AndFoucePixelLensPosition =[[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        //NSLog(@"监听_isIOS8AndFoucePixelLensPosition == %f",_isIOS8AndFoucePixelLensPosition);
    }
}

#pragma mark -----------初始化---------
- (void) initRecog
{
    /*
     1.识别核心初始化需要传入初始化类型：视频流模式11  导入模式为10； 如果在相机中需要切换识别类型需要将核心释放并重新初始化；
     2.Demo相机 初始化核心默认为：视频流模式11；点击切换按钮时，先释放核心，然后重新初始化；
     */
    
    //初始化核心 默认设置视频流模式11 (导入模式为10)
    if (!self.cardRecog) {
        self.cardRecog = [[BusinessCardPro alloc] init];
    }
    int initRecog = [self.cardRecog initWithDevcode:@"5YYX5LQS5LIT5A6" RecogType:11];
    NSString *coreVersion = [self.cardRecog getBusnessCoreVersion];
    NSLog(@"\n识别核心版本号：%@\n核心初始化返回值 = %d\n返回值为0成功 其他失败\n\n常见错误：\n-10601 开发码错误\n核心初始化方法设置开发码\n\n-10602 Bundle identifier错误\n-10605 Bundle display name错误\n-10606 CompanyName错误\n请检查授权文件（wtproject.lsc）绑定的信息与Info.plist中设置是否一致!!!",coreVersion,initRecog);
    
    
    //根据检边框frame设置检边参数
    if (!_overView) {
        _overView = [[BusOverView alloc] initWithFrame:self.view.bounds];
    }
    CGRect rect = _overView.smallrect;
    CGFloat scale = 1080/kScreenWidth; //1080为当前分辨率(1920*1080)中的宽
    //预览界面与实际图片坐标差值
    CGFloat dValue = (kScreenWidth/1080*1920-kScreenHeight)*scale*0.5;
    int sTop = (kScreenWidth - CGRectGetMaxX(rect))*scale;
    int sBottom = (kScreenWidth - CGRectGetMinX(rect))*scale;
    int sLeft = CGRectGetMinY(rect)*scale+dValue;
    int sRight = (CGRectGetMinY(rect) + CGRectGetHeight(rect))*scale+dValue;
    
    int roi = [self.cardRecog setROIWithLeft:sLeft Right:sRight Top:sTop Bottom:sBottom];
    NSLog(@"设置检边结果:%d", roi);
    //NSLog(@"sTop = %d \nsBottom=%d\nsLeft=%d\nsRight=%d",sTop,sBottom,sLeft,sRight);
    
}
//初始化相机
- (void) initialize
{
    //判断摄像头授权
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        self.view.backgroundColor = [UIColor blackColor];
        UIAlertView * alt = [[UIAlertView alloc] initWithTitle:@"未获得授权使用摄像头" message:@"请在'设置-隐私-相机'打开" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alt show];
        return;
    }
    
    //1.创建会话层
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPreset1920x1080];
    
    //2.创建、配置输入设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices){
        if (device.position == AVCaptureDevicePositionBack){
            NSError *error;
            _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            _device = device;
        }
    }
    [_session addInput:_captureInput];
    
    //3.视频流输出
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc]
                                               init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    //    dispatch_release(queue);
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber
                       numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary
                                   dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    [_session addOutput:captureOutput];
    
    //3.静态拍照输出
    _captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [_captureOutput setOutputSettings:outputSettings];
    [_session addOutput:_captureOutput];
    
    //4.预览图层
    _preview = [AVCaptureVideoPreviewLayer layerWithSession: _session];
    _preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_preview];
    [_session startRunning];
    
    //判断是否相位对焦
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        AVCaptureDeviceFormat *deviceFormat = _device.activeFormat;
        if (deviceFormat.autoFocusSystem == AVCaptureAutoFocusSystemPhaseDetection){
            _isFoucePixel = YES;
        }
    }
}

- (void)createCameraView{
    
    //设置覆盖层
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    // Both frames are defined in the same coordinate system
    CGRect biggerRect = self.view.bounds;
    CGFloat offset = 1.0f;
    if ([[UIScreen mainScreen] scale] >= 2) {
        offset = 0.5;
    }
    CGRect smallFrame = _overView.smallrect;
    CGRect smallerRect = CGRectInset(smallFrame, -offset, -offset) ;
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskWithHole setPath:[maskPath CGPath]];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [maskWithHole setFillColor:[[UIColor colorWithWhite:0 alpha:0.35] CGColor]];
    [self.view.layer addSublayer:maskWithHole];
    [self.view.layer setMasksToBounds:YES];
    _overView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_overView];
    
    //返回、闪光灯按钮
    CGFloat backWidth = 35;
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/16,kScreenWidth/16, backWidth, backWidth)];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"BusinessCard.bundle/back_camera_btn"] forState:UIControlStateNormal];
    backBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:backBtn];
    
    UIButton *flashBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-kScreenWidth/16-backWidth,kScreenWidth/16, backWidth, backWidth)];
    [flashBtn setImage:[UIImage imageNamed:@"BusinessCard.bundle/flash_camera_btn"] forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(modeBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    
    // 拍照按钮
    CGFloat s = 80;
    if (kScreenHeight==480) {
        s = 60;}
    UIButton *photoBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/2-30,kScreenHeight-s,60, 60)];
    photoBtn.tag = 1000;
    photoBtn.hidden = YES;
    [photoBtn setImage:[UIImage imageNamed:@"BusinessCard.bundle/take_pic_btn"] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(photoBtn) forControlEvents:UIControlEventTouchUpInside];
    [photoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:photoBtn];
    
    //切换识别模式按钮
    UIButton *flagBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70, 40)];
    flagBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [flagBtn setTitle:@"扫描识别" forState:UIControlStateNormal];
    [flagBtn setTitle:@"拍照识别" forState:UIControlStateSelected];
    [flagBtn addTarget:self action:@selector(flagBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flagBtn];
    flagBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    flagBtn.center = CGPointMake(CGRectGetMinX(_overView.smallrect)-10, (kScreenHeight-CGRectGetMaxY(_overView.smallrect))/2+CGRectGetMaxY(_overView.smallrect));
    
}
//从摄像头缓冲区获取图像 （视频流扫描识别）
#pragma mark ------------AVCaptureSession delegate------------
#pragma mark -----------视频流扫描识别-------------
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    int width = (int)CVPixelBufferGetWidth(imageBuffer);
    int height = (int)CVPixelBufferGetHeight(imageBuffer);
    
    if (!_isSancRecog) { //切换拍照模式
        if (!self.adjustingFocus) {  //反差对焦 非对焦状态
            if (_isLensChanged == _isIOS8AndFoucePixelLensPosition) { //相位对焦
                _MaxFR++;
                if (_MaxFR == 2) { //镜头稳定连续俩帧后调用检边方法（相位对焦）
                    _MaxFR--;
                    //检测名片边
                    BOOL sliderLine = [self.cardRecog confirmSlideLineWithBuffer:baseAddress Width:width Height:height];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_overView setLeftHidden:sliderLine];
                        [_overView setRightHidden:sliderLine];
                        [_overView setBottomHidden:sliderLine];
                        [_overView setTopHidden:sliderLine];
                    });
                    
                    if (sliderLine) {
                        if (_count == 2) { //连续检边2次后 调用判断清晰度方法
                            //判断图像是否清晰
                            BOOL isPicClear = [self.cardRecog checkPicClearWithImageBuffer:baseAddress Width:width Height:height];
                            if (isPicClear) {
                                _count = 0;
                                [_session stopRunning];
                                
                                /*保存裁切后的图片到imageFilePath 在调用识别方法之前调用*/
                                NSString *saveImageFilePath = [_documentsDirectory stringByAppendingPathComponent:@"BusSave.jpg"];
                                [self.cardRecog SetSaveImagePath:saveImageFilePath];
                                
                                //图像清晰，找边成功，开始识别
                                int recog = [self.cardRecog RecogBusinessCardWithImageBuffer:baseAddress Width:width Height:height CardType:1];
                                NSLog(@"识别结果：%d", recog);
                                
                                //开始取结果
                                [self performSelectorOnMainThread:@selector(readyToGetResult) withObject:nil waitUntilDone:NO];
                            }
                        }else{
                            _count++;
                        }
                    }else{
                        _count = 0;
                    }
                }
            }else{
                _isLensChanged = _isIOS8AndFoucePixelLensPosition;
                _MaxFR = 0;
                _count = 0;
            }
        }
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}

#pragma mark -----------拍照识别 导入识别-------------
//拍照 拍照识别
-(void)captureimage
{
    //将处理图片状态值置为YES
    self.isProcessingImage = YES;
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    [_captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (imageSampleBuffer != NULL) {
             //将处理图片状态值置为NO
             [_session stopRunning];
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             NSLog(@"开始生成图片");
             UIImage *tempImage = [[UIImage alloc] initWithData:imageData];
             UIImage *finalImage = [[UIImage alloc] initWithCGImage:tempImage.CGImage scale:1.0 orientation:UIImageOrientationUp];
             [self performSelectorOnMainThread:@selector(readyToGetImage:) withObject:finalImage waitUntilDone:YES];
             self.isProcessingImage = NO;
         }
     }];
}
//获取到图片，进行导入识别
-(void)readyToGetImage:(UIImage *)image
{
    
    NSString *recogImageFilePath = [_documentsDirectory stringByAppendingPathComponent:@"BusTemp.jpg"];
    NSString *saveImageFilePath = [_documentsDirectory stringByAppendingPathComponent:@"BusSave.jpg"];
    
    //将拍好的图片保存到imageFilePath
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:recogImageFilePath atomically:YES];
    
    /*保存裁切后的图片到saveImageFilePath 在调用识别方法之前调用*/
    [self.cardRecog SetSaveImagePath:saveImageFilePath];
    
    //识别本地图片
    int recog = [self.cardRecog RecogImageWithImagePath:recogImageFilePath CardType:1];
    NSLog(@"导入识别%d",recog);
    //识别完成后，调用展示页面
    [self readyToGetResult];
}

#pragma mark -----------识别完成，取结果并跳转-------------
//识别完成，取结果并跳转
- (void)readyToGetResult
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    for (int i = 0; i < 10; i++) {
        /*获取对应的字段名*/
        NSString *fieldName = [self.cardRecog getFieldnameWithFieldNumber:i];
        if (fieldName) {
            NSMutableArray *array = [NSMutableArray array];
            /*获取对应字段的值的个数*/
            int rCount = [self.cardRecog getResultCountWithFieldNumber:i];
            if (rCount > 0) {
                for (int j = 0; j < rCount; j++) {
                    //拆分电话号码，只适用于“电话”、“传真”、“手机”三个字段
                    if ([fieldName isEqualToString:@"电话"] ||[fieldName isEqualToString:@"手机"] ||[fieldName isEqualToString:@"传真"] ) {
                        /*拆分“电话”、“传真”、“手机”三个字段，获取每个字段的值的个数*/
                        int pCount = [self.cardRecog getPhoneNumeberCount:i ResultCount:j];
                        for (int k=0; k<pCount; k++) {
                            /*拆分“电话”、“传真”、“手机”三个字段，获取每个字段的值*/
                            NSString *result = [self.cardRecog getRecogResultWithNumnerIndex:k];
                            if (result) {
                                [array addObject:result];
                            }
                        }
                    }else{
                        //获取对应字段的值，此方法不会对“电话”、“传真”、“手机”三个字段拆分
                        NSString *result = [self.cardRecog getRecogResultWithFieldNumner:i ResultCount:j];
                        if (result) {
                            [array addObject:result];
                        }
                    }
                }
            }else{
                [array addObject:@""];
            }
            info[fieldName] = array;
        }
    }
    
    NSLog(@"%@", info);
    if ([info allKeys].count > 0) {
        //识别成功，展示识别结果
        ResultViewController *resultVC = [[ResultViewController alloc] init];
        resultVC.resultDic = info;
        //获取裁切图片
        NSString *saveImageFilePath = [_documentsDirectory stringByAppendingPathComponent:@"BusSave.jpg"];
        UIImage *image = [UIImage imageWithContentsOfFile:saveImageFilePath];
        resultVC.savedImage = image;
        [self.navigationController pushViewController:resultVC animated:YES];
    }else{
        //识别失败，重新识别
        [_session startRunning];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    /*相机禁止访问时，弹出UIAlertView 点击UIAlertView*/
}

#pragma mark ---------- ButtonAction---------
//返回按钮按钮点击事件
- (void)backAction{
    
}

//闪光灯按钮点击事件
- (void)modeBtn{
    
    if (![_device hasTorch]) {
        //NSLog(@"no torch");
    }else{
        [_device lockForConfiguration:nil];
        if (!_on) {
            [_device setTorchMode: AVCaptureTorchModeOn];
            _on = YES;
        }
        else{
            [_device setTorchMode: AVCaptureTorchModeOff];
            _on = NO;
        }
        [_device unlockForConfiguration];
    }
}

//拍照按钮点击事件
- (void)photoBtn{
    [self captureimage];
}

#pragma mark -----------拍照识别和扫描识别模式切换时，识别核心重新初始化-------------
//切换模式按钮
- (void)flagBtn:(UIButton *)btn{
    
    //拍照识别与自动扫描识别初始化传的参数不一样，需要先释放掉核心，重新初始化
    [self.cardRecog freeBusinessCard];
    if (btn.selected) {
        [self initRecog];
    }else{
        int initRecog = [self.cardRecog initWithDevcode:@"5YYX5LQS5LIT5A6" RecogType:10];
        NSLog(@"核心切换为拍照导入识别模式--初始化结果：%d", initRecog);
    }
    
    btn.selected = !btn.selected;
    UIButton *photoBtn = (UIButton *)[self.view viewWithTag:1000];
    photoBtn.hidden = !btn.selected;
    
    //切换为拍照识别模式后，扫描识别不在自动识别，在相机代理AVCaptureVideoDataOutputSampleBufferDelegate中设置
    _isSancRecog = btn.selected;
    
}
#pragma mark ---------------------------------------------------
//隐藏状态栏
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
