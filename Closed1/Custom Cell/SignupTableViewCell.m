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



}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
