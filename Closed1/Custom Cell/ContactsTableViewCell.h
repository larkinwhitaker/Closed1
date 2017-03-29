//
//  ContactsTableViewCell.h
//  Closed1
//
//  Created by Nazim on 30/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *companyLabel;

@end
