//
//  ResultViewController.m
//  SmartVisionOCRDemo
//

#import "ResultViewController.h"
#import "ImageTableViewCell.h"
#import "SmartOCR.h"

@interface ResultViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

static NSString *cellName = @"resultCell";

#define kiOSVersion [UIDevice currentDevice].systemVersion.floatValue

@implementation ResultViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor grayColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (kiOSVersion >= 8.0) {
        //8.0以后系统，cell自动适应高度
        self.tableView.estimatedRowHeight = 118.f;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageTableViewCell" bundle:nil] forCellReuseIdentifier:cellName];
    
    NSString *allResult = @"";
    for (int i = 0; i<self.fieldData.count; i++) {
        NSString *field = self.fieldData[i];
        NSString *result = self.resultData[i];
        if ([field isEqualToString:@"VIN码"]) {
            [self addVINInfoViewWithVIN: result];
        }
        allResult = [allResult stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n", field, result]];
    }

}

- (void) addVINInfoViewWithVIN: (NSString *)vin
{
    //vin包含的所有字段
//    NSString *vinKeys = @"产地,生产年份,厂家名称,品牌,车系,车型,车辆级别,车辆类型,年款,销售名称,指导价格,上市年份,上市月份,停产年份,车型代码,排放标准,座位数,变速箱类型,发动机型号,排量,变速箱描述,发动机最大功率,燃油类型,座位数,车门数,车身形式,燃油标号,发动机缸数,驱动方式";
    [self.ocr initVINEngine];
    NSArray *vinInfo = [self.ocr searchVINInfoWithVINCode:vin];
    NSString *allinfo = @"";
    for (NSDictionary *dict in vinInfo) {
        allinfo = [allinfo stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n", [dict allKeys][0], [dict objectForKey:[dict allKeys][0]]]];
    }
    
    NSLog(@"%@", allinfo);
    UITextView *textView = [[UITextView alloc] init];
    textView.frame = CGRectMake(10, 200, self.view.bounds.size.width-20, 200);
    textView.text = allinfo;
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:17];
    [self.tableView addSubview:textView];
}

#pragma mark -- UITableViewDelegate && UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fieldData.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    if (!cell) {
        cell = [[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.recogImageView.image = [UIImage imageWithContentsOfFile:self.imagePaths[indexPath.row]];
    cell.fieldLabel.text = self.fieldData[indexPath.row];
    cell.resultLabel.text = self.resultData[indexPath.row];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    int row = [indexPath row];
    // 列宽
    CGFloat contentWidth = tableView.frame.size.width;
    // 字体大小
    UIFont *font = [UIFont systemFontOfSize:17];
    // 內容
    NSString *content = [self.resultData objectAtIndex:indexPath.row];
    // 计算最小尺寸
    CGFloat contentH = [content boundingRectWithSize:CGSizeMake(contentWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size.height;
    // 返回需要的高度
    return contentH+120;
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
