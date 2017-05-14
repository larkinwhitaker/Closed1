//
//  EditProfileTableViewCell.h
//  Closed1
//
//  Created by Nazim on 28/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@interface EditProfileTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *emailTextField;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *secondaryEmail;

@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *fullNameTextField;

@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *citytextField;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *stateTextField;
@property (strong, nonatomic) IBOutlet UIButton *countryButton;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *companyNameTextField;

@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *designationTextField;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *terrotoryTextField;


@property (strong, nonatomic) IBOutlet UIButton *updateButton;
@property (strong, nonatomic) IBOutlet UIView *editProfileView;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *targetBuyersTextField;

@end
