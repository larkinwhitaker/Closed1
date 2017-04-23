//
//  FreindsCell.m
//  Closed1
//
//  Created by Nazim on 20/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "FreindsCell.h"

@implementation FreindsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.acceptButton.layer.borderWidth = 2.0;
    self.rejectButton.layer.borderWidth = 2.0;
    self.acceptButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.rejectButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
