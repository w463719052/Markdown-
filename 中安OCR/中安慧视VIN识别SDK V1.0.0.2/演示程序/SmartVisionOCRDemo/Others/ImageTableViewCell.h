//
//  ImageTableViewCell.h
//  SmartVisionOCRDemo
//
#import <UIKit/UIKit.h>

@interface ImageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *recogImageView;
@property (weak, nonatomic) IBOutlet UILabel *fieldLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end
