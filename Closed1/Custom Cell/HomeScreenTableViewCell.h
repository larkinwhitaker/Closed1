//
//  HomeScreenTableViewCell.h
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLLabel.h"

@interface HomeScreenTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *closed1Title;
@property (strong, nonatomic) IBOutlet UILabel *likeCOuntLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageCountLabel;
@property (strong, nonatomic) IBOutlet HTMLLabel *userProfileCOmmnet;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) IBOutlet UILabel *timingLabel;
@property (strong, nonatomic) IBOutlet UIView *likeView;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIView *messageView;
@property (strong, nonatomic) IBOutlet UIButton *likeButtonView;
@property (weak, nonatomic) IBOutlet UIButton *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *editOptionButton;
@property (weak, nonatomic) IBOutlet UIView *editOptionView;
@property (weak, nonatomic) IBOutlet UIImageView *editOptionImageView;
@property (weak, nonatomic) IBOutlet UIButton *editFeedsButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteFeedsButton;


@end
