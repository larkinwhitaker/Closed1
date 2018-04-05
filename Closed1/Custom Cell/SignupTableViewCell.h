//
//  SignupTableViewCell.h
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@interface SignupTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *signupView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *usenameTextField;
@property (strong, nonatomic) IBOutlet UIView *userNameUnderLineView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *emailtextField;
@property (strong, nonatomic) IBOutlet UIView *emailUnderLineView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIView *passwordUnderLineView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UIView *confirmPsswordUnderLineView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *fullNameTextField;
@property (strong, nonatomic) IBOutlet UIView *fullNameUnderLineView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *cityTextField;

@property (strong, nonatomic) IBOutlet UIView *cityUnderLineView;

@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *stateTextField;
@property (strong, nonatomic) IBOutlet UIView *stateUnderLineView;

@property (strong, nonatomic) IBOutlet UIButton *countrySelectionButton;

@property (strong, nonatomic) IBOutlet UIView *countrySelectionUnderLineView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *phoneNumberTextField;

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *territoryTextFiled;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *targetBuyersTextFiled;

@property (strong, nonatomic) IBOutlet UIButton *signupButton;

@property (strong, nonatomic) IBOutlet UIButton *signupLinkedButton;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *companyTextField;

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *titletextField;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;

@end
