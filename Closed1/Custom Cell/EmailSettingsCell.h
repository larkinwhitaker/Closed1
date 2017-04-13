//
//  EmailSettingsCell.h
//  Closed1
//
//  Created by Nazim on 01/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailSettingsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UISwitch *activityEmailSwitch;

@property (strong, nonatomic) IBOutlet UISwitch *activityPostSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *messageSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *freindsSendsSwict;
@property (strong, nonatomic) IBOutlet UISwitch *freinfsAcceptSwich;

@property (strong, nonatomic) IBOutlet UILabel *emailLabel;



@end
