//
//  EditProfileTableViewCell.m
//  Closed1
//
//  Created by Nazim on 28/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "EditProfileTableViewCell.h"

@implementation EditProfileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.editProfileView.layer.cornerRadius = 5;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
