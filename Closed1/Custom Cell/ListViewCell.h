//
//  ListViewCell.h
//  Airhob
//
//  Created by mYwindow on 08/08/16.
//  Copyright © 2016 mYwindow Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *headingLabel;
@property (strong, nonatomic) IBOutlet UILabel *subHeading;
@property (strong, nonatomic) IBOutlet UIImageView *listImageView;

@end
