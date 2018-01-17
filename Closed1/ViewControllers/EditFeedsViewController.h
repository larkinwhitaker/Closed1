//
//  EditFeedsViewController.h
//  Closed1
//
//  Created by Nazim on 11/12/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLLabel.h"



@interface EditFeedsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *closed1Title;
@property (strong, nonatomic) IBOutlet UILabel *likeCOuntLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageCountLabel;
@property (strong, nonatomic) IBOutlet HTMLLabel *userProfileCOmmnet;
@property (strong, nonatomic) IBOutlet UILabel *timingLabel;
@property (strong, nonatomic) IBOutlet UIView *likeView;
@property (strong, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *editFeedsButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteFeedsButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButtonView;
@property (weak, nonatomic) IBOutlet UIButton *editOptionsButton;
@property (weak, nonatomic) IBOutlet UIView *editOptionView;
@property (weak, nonatomic) IBOutlet UIButton *reportPostButton;

@end

@interface EditFeedsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@end
