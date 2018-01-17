//
//  ProfileDetailsCell.m
//  Closed1
//
//  Created by Nazim on 12/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ProfileDetailsCell.h"

@implementation ProfileDetailsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.userBlockButton.layer.cornerRadius = 5.0;
    self.userBlockButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.userBlockButton.layer.borderWidth = 1.0;
    
    self.unfreindUserButton.layer.cornerRadius = 5.0;
    self.unfreindUserButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.unfreindUserButton.layer.borderWidth = 1.0;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
