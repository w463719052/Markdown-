//
//  ResultTableViewCell.m
//  SmartvisionOCR
//

#import "ResultTableViewCell.h"

@implementation ResultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor darkGrayColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        self.textLabel.textColor = [UIColor cyanColor];
    }else{
        self.textLabel.textColor = [UIColor whiteColor];
    }
}

@end
