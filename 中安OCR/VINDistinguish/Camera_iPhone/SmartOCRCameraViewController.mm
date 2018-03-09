//
//  CameraViewController.m
//

#import "SmartOCRCameraViewController.h"
#import "SmartOCROverView.h"

#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
#import "SmartOCR.h"
#endif

//屏幕的宽、高
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface SmartOCRCameraViewController ()<UIAlertViewDelegate>
{
    SmartOCROverView *_overView;//预览界面覆盖层,显示是否找到边
    BOOL _on;//闪光灯是否打开
    AVCaptureDevice *_device;//当前摄像设备
    NSTimer *_timer;//定时器，实现实时对焦
    CAShapeLayer *_maskWithHole;//预览界面覆盖的半透明层
    int _recogType;//识别总类型
    int _currentRecogType;//当前识别的子类型
    NSString *_currentOCRID;//当前识别的子类型代码
    NSString *_resultViewTitle;//结果展示页面title
    BOOL _isTakePicBtnClick;//是否点击拍照按钮
    BOOL _isRecoging;//是否正在识别
    UIButton *_takePicBtn;//拍照按钮
    AVCaptureConnection *_videoConnection;
    int _maxCount;//找边最大次数
    int _pixelLensCount;//镜头位置稳定的次数
    float _isIOS8AndFoucePixelLensPosition;//相位聚焦下镜头位置
    float _aLensPosition;//默认镜头位置
    BOOL _isFoucePixel;//是否开启对焦
}
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
@property (nonatomic,strong) SmartOCR *ocr;//核心
#endif
@property (assign, nonatomic) BOOL adjustingFocus;//是否正在对焦
@property (strong, nonatomic) UILabel *middleLabel;
///扫描区域的横线是否是应该向上跑动
@property (nonatomic, assign) BOOL shouldUp;
///扫描区域图片
@property (nonatomic, strong) UIImageView *imageV;
///记录向右滑动最小边界
@property (nonatomic, assign) CGFloat maxX;
///记录向左滑动最大边界
@property (nonatomic, assign) CGFloat minX;
//当前类型的子类型
@property (strong, nonatomic) NSMutableArray *subTypes;
@end


@implementation SmartOCRCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    self.view.backgroundColor = [UIColor clearColor];
    //最大连续检边次数
    _maxCount = 1;
    //初始化识别核心
    [self initOCRSource];
    //初始化相机
    [self initialize];
    //创建相机界面控件
    [self createCameraView];
#endif
}
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
- (void)dealloc {
    [_ocr uinitOCREngine];
    //关闭定时器
    [_timer invalidate];
    _timer = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //隐藏navigationBar
    self.navigationController.navigationBarHidden = YES;
    //重置参数
    _pixelLensCount = 0;
    self.adjustingFocus = YES;
    _isRecoging = NO;
    _isTakePicBtnClick = NO;
    if(!_adjustingFocus){//如果不支持相位对焦，开启自定义对焦
        //定时器 开启连续对焦
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.3 target:self selector:@selector(fouceMode) userInfo:nil repeats:YES];
    }
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    int flags = NSKeyValueObservingOptionNew;
    //注册通知
    [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    if (_isFoucePixel) {
        [camDevice addObserver:self forKeyPath:@"lensPosition" options:flags context:nil];
    }
    
    [self.session startRunning];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    //移除聚焦监听
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [camDevice removeObserver:self forKeyPath:@"adjustingFocus"];
    if (_isFoucePixel) {
        [camDevice removeObserver:self forKeyPath:@"lensPosition"];
    }
    [self.session stopRunning];
}
- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
//监听对焦
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if([keyPath isEqualToString:@"adjustingFocus"]){
        self.adjustingFocus =[[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
    }
    if([keyPath isEqualToString:@"lensPosition"]){
        _isIOS8AndFoucePixelLensPosition =[[change objectForKey:NSKeyValueChangeNewKey] floatValue];
    }
}
#pragma mark - 初始化识别核心
//初始化相机
- (void)initialize {
    //判断摄像头授权
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"未获得授权使用摄像头" message:@"请在iOS '设置-隐私-相机' 中打开" delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
        [alert show];
        return;
    }
    //1.创建会话层
    self.session = [[AVCaptureSession alloc] init];
    //设置图片品质，此分辨率为最佳识别分辨率，建议不要改动
    [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    //2.创建、配置输入设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        }
    }
    [self.session addInput:self.captureInput];
    //创建、配置预览输出设备
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    [self.session addOutput:captureOutput];
    //3.创建、配置输出
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [self.captureOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.captureOutput];
    //设置预览
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession: self.session];
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.preview];
    //5.设置视频流和预览图层方向
    for (AVCaptureConnection *connection in captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                _videoConnection = connection;
                break;
            }
        }
        if (_videoConnection) { break; }
    }
    _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    //判断对焦方式
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        AVCaptureDeviceFormat *deviceFormat = _device.activeFormat;
        if (deviceFormat.autoFocusSystem == AVCaptureAutoFocusSystemPhaseDetection){
            _isFoucePixel = YES;
            _maxCount = 3;//最大连续检边次数
        }
    }
}
//重绘透明部分
- (void)drawShapeLayer {
    //设置覆盖层
    _maskWithHole = [CAShapeLayer layer];
    // Both frames are defined in the same coordinate system
    CGRect biggerRect = self.view.bounds;
    CGFloat offset = 1.0f;
    if ([[UIScreen mainScreen] scale] >= 2) {
        offset = 0.5;
    }
    //设置检边视图层
    CGRect smallFrame = _overView.frame;
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
    [_maskWithHole setPath:[maskPath CGPath]];
    [_maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [_maskWithHole setFillColor:[[UIColor colorWithWhite:0 alpha:0.5] CGColor]];
    [self.view.layer addSublayer:_maskWithHole];
    [self.view.layer setMasksToBounds:YES];
}
//创建相机界面
- (void)createCameraView {
    //设置检边视图层
    _overView = [[SmartOCROverView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/1.1, 60)];
    _overView.backgroundColor = [UIColor clearColor];
    CGPoint overCenter = self.view.center;
    _overView.center = CGPointMake(overCenter.x, overCenter.y);
    self.minX = CGRectGetMinX(_overView.frame);
    self.maxX = CGRectGetMaxX(_overView.frame);
    [self.view addSubview:_overView];
    //设置覆盖层
    [self drawShapeLayer];
    //显示当前识别类型
    self.middleLabel = [[UILabel alloc] init];
    self.middleLabel.frame = CGRectMake(_overView.x, CGRectGetMinY(_overView.frame)-40, _overView.width, 30);
    self.middleLabel.backgroundColor = [UIColor clearColor];
    self.middleLabel.textColor = [UIColor whiteColor];
    self.middleLabel.textAlignment = NSTextAlignmentCenter;
    self.middleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    self.middleLabel.text = self.typeName;
    [self.view addSubview:self.middleLabel];
    //返回、闪光灯按钮
    CGRect backBtnFrame = CGRectMake(10, 30, 35, 35);
    UIButton *backBtn = [[UIButton alloc]initWithFrame:backBtnFrame];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"1s65d16"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    
    CGRect flashBtnFrame = CGRectMake(CGRectGetMaxX(self.view.bounds)-45, 30, 35, 35);
    UIButton *flashBtn = [[UIButton alloc]initWithFrame:flashBtnFrame];
    [flashBtn setImage:[UIImage imageNamed:@"flash_camera_btn"] forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(flashBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    
    _currentRecogType = 0;
    _currentOCRID = @"SV_ID_VIN_CARWINDOW";
    [_ocr setCurrentTemplate:_currentOCRID];
    self.middleLabel.text = @"请扫描VIN码";
    [self setROI];
}
- (void)initOCRSource {
    //初始化核心
    _ocr = [[SmartOCR alloc] init];
    int init = [_ocr initOcrEngineWithDevcode:Devcode];
    NSLog(@"初始化返回值 = %d 核心版本号 = %@", init, [_ocr getVersionNumber]);
    //添加模板
    NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:@"SZHY" ofType:@"xml"];
    int addTemplate = [_ocr addTemplateFile:templateFilePath];
    NSLog(@"添加主模板返回值 = %d", addTemplate);
}
- (void)setROI {
    //设置识别区域
//    CGRect rect = _overView.frame;
//    CGFloat scale = 1080.0/kScreenWidth; //1080为当前分辨率(1920*1080)中的宽
//    CGFloat dValue = (kScreenWidth/1080*1920-kScreenHeight)*scale*0.5;
//    int sTop = (kScreenWidth - CGRectGetMaxX(rect))*scale;
//    int sBottom = (kScreenWidth - CGRectGetMinX(rect))*scale;
//    int sLeft = CGRectGetMinY(rect)*scale+dValue;
//    int sRight = (CGRectGetMinY(rect) + CGRectGetHeight(rect))*scale+dValue;
//    [_ocr setROIWithLeft:sLeft Top:sTop Right:sRight Bottom:sBottom];
    
    CGRect rect = _overView.frame;
    CGFloat scale = 1080.0/kScreenWidth; //1080为当前分辨率(1920*1080)中的宽
    CGFloat dValue = (kScreenWidth/1080*1920-kScreenHeight)*scale*0.5;
    int sTop = CGRectGetMinY(rect)*scale+dValue;
    int sBottom = CGRectGetMaxY(rect)*scale+dValue;
    int sLeft = CGRectGetMinX(rect)*scale;
    int sRight = CGRectGetMaxX(rect)*scale;
    [_ocr setROIWithLeft:sLeft Top:sTop Right:sRight Bottom:sBottom];
}
//从摄像头缓冲区获取图像
#pragma mark - AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    //获取当前帧数据
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    int width = (int)CVPixelBufferGetWidth(imageBuffer);
    int height = (int)CVPixelBufferGetHeight(imageBuffer);
    if (_isTakePicBtnClick) {
        [_session stopRunning];
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        //根据当前帧数据生成UIImage图像，保存图像使用
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,bytesPerRow, colorSpace, kCGBitmapByteOrder32Little |kCGImageAlphaPremultipliedFirst);
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
        CGImageRelease(quartzImage);
        /*
         该图片用于快速模式，即初始化设置为0时使用。
         */
        UIImageView *imView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, 300, 300)];
        imView.contentMode = UIViewContentModeScaleAspectFit;
        imView.backgroundColor = [UIColor redColor];
        imView.image = image;
        [self.view addSubview:imView];
        _isTakePicBtnClick = NO;
    }
    
    if (_aLensPosition == _isIOS8AndFoucePixelLensPosition) {
        _pixelLensCount++;
        //连续两次镜头位置不变，对焦成功
        if (_pixelLensCount == _maxCount) {
            _pixelLensCount--;
            //OCR识别
            [self recogWithData:baseAddress width:width height:height];
        }
    }else{
        //镜头不稳定时、_pixelLensCount
        _pixelLensCount = 0;
        _aLensPosition = _isIOS8AndFoucePixelLensPosition;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}

- (void)recogWithData:(uint8_t *)baseAddress width:(int)width height:(int)height{
    if (!_isRecoging) { //非正在识别
        //加载图像
        [_ocr loadStreamBGRA:baseAddress Width:width Height:height RotateType:0];
        //识别
        int recog = [_ocr recognize];
        if (recog == 0) {
            _isRecoging = YES;
            //识别成功，取结果
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            NSString *result = [_ocr getResults];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_session stopRunning];
                [self backAction];
                if (_distinguishSuccess) {
                    _distinguishSuccess(result);
                }
            });
        }
    }
}


//获取摄像头位置
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
//对焦
- (void)fouceMode {
    NSError *error;
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        if ([device lockForConfiguration:&error]) {
            CGPoint cameraPoint = [self.preview captureDevicePointOfInterestForPoint:self.view.center];
            [device setFocusPointOfInterest:cameraPoint];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            NSLog(@"Error: %@", error);
        }
    }
}
#pragma mark - ButtonAction
//返回按钮按钮点击事件
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
//闪光灯按钮点击事件
- (void)flashBtn {
    _isTakePicBtnClick = YES;
//    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
//    if (![device hasTorch]) {
//        
//    }else{
//        [device lockForConfiguration:nil];
//        if (!_on) {
//            [device setTorchMode: AVCaptureTorchModeOn];
//            _on = YES;
//        }
//        else
//        {
//            [device setTorchMode: AVCaptureTorchModeOff];
//            _on = NO;
//        }
//        [device unlockForConfiguration];
//    }
}
//隐藏状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#endif

@end
