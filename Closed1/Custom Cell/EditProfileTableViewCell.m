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
    UIBezierPath *shadowPath = [UIBezierPath
                                bezierPathWithRoundedRect: self.editProfileView.bounds
                                cornerRadius: 5];
    
    
    self.editProfileView.layer.masksToBounds = false;
    self.editProfileView.layer.shadowColor = [[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0] CGColor];
    self.editProfileView.layer.shadowOffset = CGSizeMake(-3, 3);
    self.editProfileView.layer.shadowOpacity = 0.5;
    self.editProfileView.layer.shadowPath = shadowPath.CGPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
