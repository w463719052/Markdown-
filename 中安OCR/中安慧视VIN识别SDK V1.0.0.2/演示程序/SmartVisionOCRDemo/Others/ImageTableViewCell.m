//
//  ImageTableViewCell.m
//  SmartVisionOCRDemo
//
#import "ImageTableViewCell.h"

@implementation ImageTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.recogImageView.clipsToBounds = YES;
        self.recogImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
