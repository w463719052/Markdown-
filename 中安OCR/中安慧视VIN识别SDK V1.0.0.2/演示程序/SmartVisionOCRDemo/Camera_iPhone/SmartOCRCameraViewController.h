//
//  CameraViewController.h
//  BankCardRecog
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SmartOCRCameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) CALayer *customLayer;
@property (nonatomic,assign) BOOL isProcessingImage;

@property (strong, nonatomic) AVCaptureSession *session;

@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;

@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

//识别类型列表
@property (strong, nonatomic) UITableView *listTableView;
@property (strong, nonatomic) NSArray *listDataSource;
//识别结果
@property (strong, nonatomic) UITableView *resultTableView;
@property (strong, nonatomic) NSMutableArray *resultDataSource;//识别结果
@property (strong, nonatomic) NSMutableArray *fieldDataSource;//字段
@property (strong, nonatomic) NSMutableArray *imagePaths;
//识别证件类型及结果个数
@property (assign, nonatomic) int recogType;
@property (assign, nonatomic) int resultCount;
@property (strong, nonatomic) NSString *typeName;

@end
