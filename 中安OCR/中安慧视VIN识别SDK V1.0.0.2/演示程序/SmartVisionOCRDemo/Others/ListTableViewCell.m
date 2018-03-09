//
//  ListTableViewCell.m
//  SmartvisionOCR
//
#import "ListTableViewCell.h"

@implementation ListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.textLabel.textColor = [UIColor orangeColor];
    }else{
        self.textLabel.textColor = [UIColor whiteColor];
    }
}

@end
