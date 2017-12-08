//
//  ProfileDetailsCell.h
//  Closed1
//
//  Created by Nazim on 12/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLLabel.h"

@interface ProfileDetailsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *callButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet HTMLLabel *terrotoryTextfield;
@property (weak, nonatomic) IBOutlet HTMLLabel *targetBuyersTextFiled;

@end
