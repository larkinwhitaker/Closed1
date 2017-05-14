//
//  JobProfileCell.h
//  Closed1
//
//  Created by Nazim on 11/05/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@interface JobProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *titleTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *companyTextField;

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *territoryTextFiled;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *targetBuyersTextFiled;
@property (weak, nonatomic) IBOutlet UISwitch *isCurrentPosition;
@property (weak, nonatomic) IBOutlet UIButton *addNewJob;
@property (weak, nonatomic) IBOutlet UIButton *removeJob;

@end
