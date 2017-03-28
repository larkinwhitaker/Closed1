//
//  SignupTableViewCell.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "SignupTableViewCell.h"

@implementation SignupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.signupView.layer.cornerRadius = 5;
    UIBezierPath *shadowPath = [UIBezierPath
                                bezierPathWithRoundedRect: self.signupView.bounds
                                cornerRadius: 5];
    
    
    self.signupView.layer.masksToBounds = false;
    self.signupView.layer.shadowColor = [[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0] CGColor];
    self.signupView.layer.shadowOffset = CGSizeMake(-3, 3);
    self.signupView.layer.shadowOpacity = 0.5;
    self.signupView.layer.shadowPath = shadowPath.CGPath;



}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
