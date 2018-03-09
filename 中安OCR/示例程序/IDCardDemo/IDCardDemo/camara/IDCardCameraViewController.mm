//
//  CameraViewController.m
//

#import "IDCardCameraViewController.h"
#import "IDCardOverView.h"
#import "IDCardSlideLine.h"
#import "ResultViewController.h"

#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
#import "IDCardOCR.h"
#endif


//屏幕的宽、高
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface IDCardCameraViewController ()<UIAlertViewDelegate>{
    
    UIButton *_photoBtn; //手动拍照按钮
    IDCardOverView *_overView;//预览界面覆盖层,显示是否找到边
    BOOL _on;//闪光灯是否打开
    
    NSTimer *_timer;//定时器，实现实时对焦
    CAShapeLayer *_maskWithHole;//预览界面覆盖的半透明层
    AVCaptureDevice *_device;//当前摄像设备
    BOOL _isFoucePixel;//是否开启对焦
    int _mrzType;//机读码类型
    int _confimCount;//找到边的次数
    int _maxCount;//找边最大次数
    int _pixelLensCount;//镜头位置稳定的次数
    float _isIOS8AndFoucePixelLensPosition;//相位聚焦下镜头位置
    float _aLensPosition;//默认镜头位置
    AVCaptureConnection *_videoConnection;
    
    UIButton *_lightspotSwitch;//光斑检测开关
    BOOL _lightspotOn;//是否打开光斑检测，默认不打开
    UILabel *_lightspotLabel;//检测光斑提示
    BOOL _lightspotLabelShow;//光斑检测labe是否显示
    
    NSString *_originalImagepath;   //识别原图路径
    NSString *_cropImagepath;       //识别完成后裁切证件图片路径
    NSString *_headImagePath;       //识别完成后裁切头像图片路径
}

#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
@property (strong, nonatomic) IDCardOCR *cardRecog;//核心
#endif

@property (assign, nonatomic) BOOL adjustingFocus;//是否正在对焦
@property (strong, nonatomic) UILabel *middleLabel;
@end
@implementation IDCardCameraViewController

-(void)dealloc{
    
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    //释放识别核心
    [_cardRecog recogFree];
    NSLog(@"释放识别核心!!!!!!!!");

#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    //设置图片存储路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    _originalImagepath = [documentsDirectory stringByAppendingPathComponent:@"originalImage.jpg"];
    _cropImagepath = [documentsDirectory stringByAppendingPathComponent:@"cropImage.jpg"];
    _headImagePath = [documentsDirectory stringByAppendingPathComponent:@"headImage.jpg"];
    
    //最大连续检边次数
    _maxCount = 1;
    
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    //初始化识别核心
    [self initRecog];
    
    //初始化相机
    [self initialize];
    
    //创建相机界面控件
    [self createCameraView];
#endif
    
}

#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏navigationBar
    self.navigationController.navigationBarHidden = YES;
    
    _pixelLensCount = 0;
    _confimCount = 0;
    //将处理图片状态值置为NO
    self.isProcessingImage = NO;
    
    if(!_isFoucePixel){//如果不支持相位对焦，开启自定义对焦
        //定时器 开启连续对焦
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.3 target:self selector:@selector(fouceMode) userInfo:nil repeats:YES];
    }
    
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    int flags = NSKeyValueObservingOptionNew;
    //注册反差对焦通知（5s以下机型）
    [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    if (_isFoucePixel) {
        [camDevice addObserver:self forKeyPath:@"lensPosition" options:flags context:nil];
    }
    [self.session startRunning];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    //关闭定时器
    if(!_isFoucePixel){
        [_timer invalidate];
        _timer = nil;
    }
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

#pragma mark -------------------- 初始化识别核心----------------------------
- (void) initRecog
{
    NSDate *before = [NSDate date];
    self.cardRecog = [[IDCardOCR alloc] init];
    
    /*提示：该开发码和项目中的授权仅为演示用，客户开发时请替换该开发码及项目中Copy Bundle Resources 中的.lsc授权文件*/
    int intRecog = [self.cardRecog InitIDCardWithDevcode:@"5YYX5LQS5LIT5A6" recogLanguage:0];
    NSLog(@"核心初始化返回值 = %d\n返回值为0成功 其他失败\n\n常见错误：\n-10601 开发码错误(核心初始化方法传入开发码)\n-10602 Bundle identifier错误\n-10605 Bundle display name错误\n-10606 CompanyName错误\n请检查授权文件（wtproject.lsc）绑定的信息与Info.plist中设置是否一致!!!\n",intRecog);
    
    //设置扫描模式下核心的配置
    [self setRecongConfiguration];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:before];
    NSLog(@"初始化核心时间：%f", time);
    
}
//设置扫描模式下核心的配置
- (void)setRecongConfiguration{
    if (self.recogType == 3000) {
        //机读码
        [_cardRecog setParameterWithMode:1 CardType:1033];
    }else{
        //非机读码
        [_cardRecog setParameterWithMode:1 CardType:self.recogType];
    }
    //设置二代证识别类型（0-正反面 1-正面 2-背面），在调用setParameterWithMode之后调用
    [self.cardRecog SetDetectIDCardType:0];
    
}

#pragma mark -------------------- 初始化相机----------------------------
//初始化相机
- (void) initialize
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        //判断摄像头授权
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            
            UIAlertView * alt = [[UIAlertView alloc] initWithTitle:@"请在手机'设置'-'隐私'-'相机'里打开权限" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alt show];
            return;
        }
    }
    //1.创建会话层
    self.session = [[AVCaptureSession alloc] init];
    //设置图片品质，此分辨率为最佳识别分辨率，建议不要改动
    [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
    
    //2.创建、配置输入设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            _device = device;
            self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        }
    }
    if ([self.session canAddInput:self.captureInput]) {
        [self.session addInput:self.captureInput];
    }
    
    ///创建、配置预览输出设备
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
    
    for (AVCaptureConnection *connection in captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                _videoConnection = connection;
                break;
            }
        }
        if (_videoConnection) { break; }
    }
    //设置视频流方向
    if (self.recogOrientation == RecogInHorizontalScreen) {
        //横屏
        _videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        //NSLog(@"横屏");
    }else{
        //竖屏
        _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
        //NSLog(@"竖屏");
    }
    
    //判断对焦方式
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        AVCaptureDeviceFormat *deviceFormat = _device.activeFormat;
        if (deviceFormat.autoFocusSystem == AVCaptureAutoFocusSystemPhaseDetection){
            _isFoucePixel = YES;
            _maxCount = 3;//最大连续检边次数
        }
    }
    
    //设置预览
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession: self.session];
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.preview];
    
    [self.session startRunning];
}
#pragma mark -------------------- 创建相机界面----------------------------
//创建相机界面
- (void)createCameraView{
    //设置检边视图层
    _overView = [[IDCardOverView alloc] initWithFrame:self.view.bounds];
    
    if (self.recogOrientation == RecogInHorizontalScreen) {
        //横屏识别
        _overView.isHorizontal = YES;
    }else{
        //竖屏识别
        _overView.isHorizontal = NO;
    }
    _overView.backgroundColor = [UIColor clearColor];
    //居中显示
    _overView.center = self.view.center;
    [_overView setRecogArea];
    
    //检边区域frame
    [self.view addSubview:_overView];
    
    //设置机读码检边区域
    CGRect rect;
    if (self.recogType == 3000) {
        _overView.mrz = YES;
        rect = _overView.mrzSmallRect;
        [_overView setNeedsDisplay];
    }else{
        _overView.mrz = NO;
        //隐藏四条边框
        [_overView setLeftHidden:NO];
        [_overView setRightHidden:NO];
        [_overView setBottomHidden:NO];
        [_overView setTopHidden:NO];
        rect = _overView.smallrect;
    }
    
    CGFloat scale = 720.0/kScreenWidth; //720 is the width of current resolution
    //预览界面与真实图片坐标差值
    CGFloat dValue = (kScreenWidth/720*1280-kScreenHeight)*scale*0.5;
    //图像在屏幕中相对的位置
    CGFloat sTop, sBottom, sLeft, sRight;
    if (self.recogOrientation == RecogInHorizontalScreen) {
        //横屏识别
        sTop = (kScreenWidth - CGRectGetMaxX(rect))*scale;
        sBottom = (kScreenWidth - CGRectGetMinX(rect))*scale;
        sLeft = CGRectGetMinY(rect)*scale+dValue;
        sRight = (CGRectGetMinY(rect) + CGRectGetHeight(rect))*scale+dValue;
        
    }else{
        //竖屏识别
        sTop = CGRectGetMinY(rect)*scale+dValue;
        sBottom = CGRectGetMaxY(rect)*scale+dValue;
        sLeft = CGRectGetMinX(rect)*scale;
        sRight = CGRectGetMaxX(rect)*scale;
    }
    //NSLog(@"sTop=%f,sBottom=%f,sLeft=%f,sRight=%f",sTop,sBottom,sLeft,sRight);
    //设置检边参数,识别的图像上检边框区域在整张图上的位置
    int a = [_cardRecog setROIWithLeft:(int)sLeft Top:(int)sTop Right:(int)sRight Bottom:(int)sBottom];
    NSLog(@"roi%d", a);
    
    //设置覆盖层
    [self drawShapeLayer];
    
    //显示当前识别卡种
    self.middleLabel = [[UILabel alloc] init];
    self.middleLabel.frame = CGRectMake(0, 0, 300, 30);
    if (self.recogOrientation == RecogInHorizontalScreen) {
        //横屏
        self.middleLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    self.middleLabel.center = CGPointMake(CGRectGetMidX(_overView.smallrect), CGRectGetMidY(_overView.smallrect));
    if (self.recogType == 3000) {
        self.middleLabel.center = CGPointMake(CGRectGetMidX(_overView.mrzSmallRect), CGRectGetMidY(_overView.mrzSmallRect));
    }
    self.middleLabel.backgroundColor = [UIColor clearColor];
    self.middleLabel.textColor = [UIColor orangeColor];
    self.middleLabel.textAlignment = NSTextAlignmentCenter;
    self.middleLabel.text = NSLocalizedString(self.typeName, nil) ;
    [self.view addSubview:self.middleLabel];
    
    //返回、闪光灯按钮
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(15,15, 35, 35)];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"back_camera_btn"] forState:UIControlStateNormal];
    backBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:backBtn];
    
    UIButton *flashBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-50,15, 35, 35)];
    [flashBtn setImage:[UIImage imageNamed:@"flash_camera_btn"] forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(flashBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    
    //相机拍照按钮
    _photoBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,60, 60)];
    _photoBtn.center = CGPointMake(kScreenWidth*0.5, kScreenHeight-30);
    [_photoBtn setImage:[UIImage imageNamed:@"take_pic_btn"] forState:UIControlStateNormal];
    [_photoBtn addTarget:self action:@selector(photoBtn) forControlEvents:UIControlEventTouchUpInside];
    [_photoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:_photoBtn];
    
    //光斑检测开关
    _lightspotSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
    _lightspotSwitch.frame = CGRectMake(0, kScreenHeight-30, 100, 30);
    [_lightspotSwitch setTitle:@"光斑检测:开" forState:UIControlStateSelected];
    [_lightspotSwitch setTitle:@"光斑检测:关" forState:UIControlStateNormal];
    _lightspotSwitch.selected = NO;
    [_lightspotSwitch addTarget:self action:@selector(OpenLightspotSwich) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_lightspotSwitch];
    
    //光斑检测提示
    _lightspotLabel = [[UILabel alloc] init];
    _lightspotLabel.frame = CGRectMake(0, 0, 300, 30);
    _lightspotLabel.backgroundColor = [UIColor blackColor];
    _lightspotLabel.textColor = [UIColor whiteColor];
    _lightspotLabel.text = @"检测到光斑，请换个角度扫描";
    _lightspotLabel.textAlignment = NSTextAlignmentCenter;
    _lightspotLabel.center = CGPointMake(CGRectGetMidX(_overView.smallrect), CGRectGetMaxY(_overView.smallrect)+40);
    //横竖屏设置光斑frame
    if (self.recogOrientation == RecogInHorizontalScreen) { //横屏识别
        _lightspotSwitch.transform = CGAffineTransformMakeRotation(M_PI/2);
        _lightspotLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
        _lightspotSwitch.center = CGPointMake(15, kScreenHeight-50);
        _lightspotLabel.center = CGPointMake(CGRectGetMinX(_overView.smallrect)-30, CGRectGetMidY(_overView.smallrect));
    }
}
//重绘透明部分
- (void) drawShapeLayer
{
    //设置覆盖层
    _maskWithHole = [CAShapeLayer layer];
    
    // Both frames are defined in the same coordinate system
    CGRect biggerRect = self.view.bounds;
    CGFloat offset = 1.0f;
    if ([[UIScreen mainScreen] scale] >= 2) {
        offset = 0.5;
    }
    
    //设置检边视图层
    CGRect smallFrame;
    if (self.recogType == 3000) {
        _overView.mrz = YES;
        smallFrame = _overView.mrzSmallRect;
    }else{
        _overView.mrz = NO;
        smallFrame  = _overView.smallrect;
    }
    
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
    [_maskWithHole setFillColor:[[UIColor colorWithWhite:0 alpha:0.35] CGColor]];
    [self.view.layer addSublayer:_maskWithHole];
    [self.view.layer setMasksToBounds:YES];

    
}

#pragma mark --------------------AVCaptureSession delegate----------------------------
//从摄像头缓冲区获取图像
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    //点击拍照按钮，走拍照导入识别流程
    if (self.isProcessingImage) {
        //快门声音
        AudioServicesPlaySystemSound(1108);
        
        //获取当前图片
        UIImage *tempImage = [self imageFromSampleBuffer:sampleBuffer];
        //停止取景
        [_session stopRunning];
        
        //调用核心识别方法
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self readyToGetImageEx:tempImage];
        });
        return;
    }

    //获取当前帧数据
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    int width = (int)CVPixelBufferGetWidth(imageBuffer);
    int height = (int)CVPixelBufferGetHeight(imageBuffer);
    
    //检测证件边
    if (_aLensPosition == _isIOS8AndFoucePixelLensPosition) {
        _pixelLensCount++;
        //连续两次镜头位置不变，对焦成功
        if (_pixelLensCount == 3) {
            _pixelLensCount--;
            //调用核心导入内存接口
            if ([self.cardRecog newLoadImageWithBuffer:baseAddress Width:width Height:height] == 0) {
                
                //调用核心光斑检测接口
                if (_lightspotOn){
                    //检测到光斑，禁止识别
                    int spot = [self.cardRecog detectLightspot];
                    if (spot == 0){
                        //NSLog(@"检测到光斑");
                        if (!_lightspotLabelShow) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.view addSubview:_lightspotLabel];
                                _lightspotLabelShow = YES;
                                [self performSelector:@selector(hideLightspotLabel) withObject:nil afterDelay:1.0];
                            });
                        }
                        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
                        return;
                    }
                }
                
                //调用核心检边方法
                IDCardSlideLine *sliderLine = [self.cardRecog newConfirmSlideLine];
                //NSLog(@"sliderLine.allLine == %d",sliderLine.allLine);
                //sliderLine.allLine大于0时为检测到边线
                BOOL lineState = sliderLine.allLine>=0;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_overView setLeftHidden:lineState];
                    [_overView setRightHidden:lineState];
                    [_overView setBottomHidden:lineState];
                    [_overView setTopHidden:lineState];
                });
                //核心找边成功
                if (lineState){
                    //机读码检测到边线之后，检边方法返回值为识别核心判断的机读码类型，1033，1034，1036代表机读码三种类型
                    _mrzType = sliderLine.allLine;
                    
                    //检边成功后，调用核心检测图像清晰度方法
                    if ([self.cardRecog newCheckPicIsClear] == 0){
                        //连续检边成功并且图像清晰_maxCount次。（调整_maxCount大小，可以调整识别速度快慢）
                        if (_confimCount == _maxCount) {
                            //停止取景
                            [_session stopRunning];
                            
                            //重置连续检边成功次数
                            _confimCount = 0;
                            
                            //开启震动
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                            
                            //调用核心识别方法
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self readyToRecog];
                            });
                        }else{
                            //检边成功次数+1
                            _confimCount++;
                        }
                    }else{
                        //核心判断图像不清晰，重置连续检边成功次数；反差对焦识别速度慢不在重置
                        if (_isFoucePixel) {
                            _confimCount = 0;
                        }
                    }
                }else{
                    //相位对焦情况下检边失败，重置连续检边成功次数；反差对焦识别速度慢不在重置
                    if (_isFoucePixel) {
                        _confimCount = 0;
                    }
                }
            }
        }
    }else{
        //镜头不稳定时，_confimCount、_pixelLensCount
        _confimCount = 0;
        _pixelLensCount = 0;
        _aLensPosition = _isIOS8AndFoucePixelLensPosition;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}

//数据帧转图片
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(quartzImage);
    return (image);
}


#pragma mark --------------------识别证件获取结果----------------------------
//拍照识别（导入识别）模式
-(void)readyToGetImageEx:(UIImage *)image{
    
    NSLog(@"——————————————————————拍照导入识别————————————————————");
    //保存到沙盒
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:_originalImagepath atomically:YES];
    //设置导入识别模式和证件类型
    [self.cardRecog setParameterWithMode:0 CardType:self.recogType];
    //图片预处理 7－裁切+倾斜校正+旋转
    [self.cardRecog processImageWithProcessType:7 setType:1];
    
    //导入图片数据
    int loadImage = [self.cardRecog LoadImageToMemoryWithFileName:_originalImagepath Type:0];
    
    if (self.recogType != 3000) {//***注意：机读码需要自己重新设置类型来识别，拍照识别无法识别机读码
        if (self.recogType == 2) {
            
            //自动分辨二代证正反面
            [self.cardRecog autoRecogChineseID];
        }else{
            //其他证件
            [self.cardRecog recogIDCardWithMainID:self.recogType];
        }
    }
    
    //获取识别结果
    [self getRecogResult];
    
    //导入识别完成后要重新设置扫描模式下核心的配置
    [self setRecongConfiguration];
    
    //将处理图片状态值置为NO
    self.isProcessingImage = NO;
    
}

//扫描识别模式
-(void)readyToRecog
{
    //禁用拍照按钮
    _photoBtn.enabled = NO;
    
    NSLog(@"————————————————————扫描识别————————————————————");
    if (self.recogType == 3000) {
        //识别机读码
        int recog = [self.cardRecog recogIDCardWithMainID:_mrzType];
        NSLog(@"recog:%d",recog);
    }else if(self.recogType == 2){
        
        //自动判断二代证正反面
        int sum = [self.cardRecog autoRecogChineseID];
        NSLog(@"sum = %d", sum);
    }else{
        //识别非机读码证件
        int recog = [self.cardRecog recogIDCardWithMainID:self.recogType];
        NSLog(@"recog:%d",recog);
    }
    //获取识别结果
    [self getRecogResult];
    
    //开启拍照按钮
    _photoBtn.enabled = YES;
    
}
//获取识别结果
- (void)getRecogResult{
    
    //获取识别结果 本demo为了方便展示结果使用了字符串方式
    NSString *allResult = @"";
    //获取识别结果字典
    //NSMutableDictionary *resultMuDic = [NSMutableDictionary dictionary];
    if (self.recogType != 3000) {
        //将裁切好的头像保存到headImagePath
        int save =[self. cardRecog saveHeaderImage:_headImagePath];
        
        NSLog(@"save头像 = %d", save);
        for (int i = 1; i < 20; i++) {
            //获取字段值 
            NSString *field = [self.cardRecog GetFieldNameWithIndex:i];
            //获取字段结果
            NSString *result = [self.cardRecog GetRecogResultWithIndex:i];
            //NSLog(@"%@:%@\n",field, result);
            if (field!=nil && result!=nil) {
                allResult = [allResult stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n", field, result]];
                //字段为key，结果值为Value
                //[resultMuDic setObject:result forKey:field];
            }
        }
    }else{
        int mrzCount = _mrzType == 1033 ?4:3;
        for (int i=1; i<mrzCount; i++) {
            NSString *result = [self.cardRecog GetRecogResultWithIndex:i];
            if (result!= nil) {
                allResult = [allResult stringByAppendingString:[NSString stringWithFormat:@"%@\n", result]];
                
            }else{
                break;
            }
        }
        _mrzType = 0;
    }
    
    //将裁切好的全幅面保存到imagepath里
    int save = [self.cardRecog saveImage:_cropImagepath];
    NSLog(@"save裁切图 = %d", save);

    //跳转到结果展示页面
    ResultViewController *rvc = [[ResultViewController alloc] init];
    NSLog(@"allresult = %@", allResult);
    rvc.cropImagepath = _cropImagepath;
    rvc.headImagepath = _headImagePath;
    rvc.resultString = allResult;
    [self.navigationController pushViewController:rvc animated:YES];
}

#pragma mark --------------------ButtonAction----------------------------
//返回按钮按钮点击事件
- (void)backAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//闪光灯按钮点击事件
- (void)flashBtn{
    
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if (![device hasTorch]) {
        //        NSLog(@"no torch");
    }else{
        [device lockForConfiguration:nil];
        if (!_on) {
            [device setTorchMode: AVCaptureTorchModeOn];
            _on = YES;
        }
        else
        {
            [device setTorchMode: AVCaptureTorchModeOff];
            _on = NO;
        }
        [device unlockForConfiguration];
    }
}

//拍照按钮点击事件
- (void)photoBtn{

    //NSLog(@"拍照按钮点击事件");
    //将处理图片状态值置为YES
    self.isProcessingImage = YES;

}

//光斑检测开关
- (void) OpenLightspotSwich{
    _lightspotSwitch.selected = !_lightspotSwitch.selected;
    _lightspotOn = _lightspotSwitch.selected;
}

//隐藏光斑提示框
- (void) hideLightspotLabel
{
    [_lightspotLabel removeFromSuperview];
    _lightspotLabelShow = NO;
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
- (void)fouceMode{
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

//隐藏状态栏
- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden{
    
    return YES;
}
#endif


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
