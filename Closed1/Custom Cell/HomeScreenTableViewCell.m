//
//  HomeScreenTableViewCell.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "HomeScreenTableViewCell.h"

@implementation HomeScreenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.deleteFeedsButton.layer.cornerRadius = 5.0;
    self.deleteFeedsButton.layer.borderWidth = 1.0;
    self.editFeedsButton.layer.cornerRadius = 5.0;
    self.editFeedsButton.layer.borderWidth = 1.0;
    self.deleteFeedsButton.layer.shadowColor = [[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0] CGColor];
    self.deleteFeedsButton.layer.shadowOffset = CGSizeMake(3, 3);
    self.deleteFeedsButton.layer.shadowOpacity = 0.5;
    self.editFeedsButton.layer.shadowColor = [[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0] CGColor];
    self.editFeedsButton.layer.shadowOffset = CGSizeMake(3, 3);
    self.editFeedsButton.layer.shadowOpacity = 0.5;
    
    //self.editOptionImageView.image = [self.editOptionImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [self.editOptionImageView setTintColor:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0] ];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
