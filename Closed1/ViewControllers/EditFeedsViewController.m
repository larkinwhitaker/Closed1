//
//  EditFeedsViewController.m
//  Closed1
//
//  Created by Nazim on 11/12/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "EditFeedsViewController.h"
#import "UIImageView+WebCache.h"
#import "NavigationController.h"
#import "ClosedResverResponce.h"
#import "MBProgressHUD.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "HomeScreenViewController.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "EditedFeedsShareViewController.h"

@implementation EditFeedsCell

@end

@interface EditFeedsViewController ()

@property(nonatomic) NSMutableArray *userFeedsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EditFeedsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getUserFeedsDetails];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController configureNavigationBar:self];
    self.title = @"Feeds";
}

-(void)getUserFeedsDetails
{
    self.userFeedsArray = [[NSMutableArray alloc]init];
    
    UserDetails *userDetails = [UserDetails MR_findFirst];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting Feed";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=get_profile_feeds&user_id=%zd", userDetails.userID] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (NSDictionary *singleFeed in serverResponce) {
                
                NSMutableDictionary *feedDictionary = [[NSMutableDictionary alloc]init];
                BOOL isfeedLiked = NO;
                if (![[singleFeed valueForKey:@"isFeedLiked"] isEqual:[NSNull null]]) isfeedLiked = [[singleFeed valueForKey:@"isFeedLiked"] boolValue];
                [feedDictionary setValue:[NSNumber numberWithBool:isfeedLiked] forKey:@"isLike"];
                NSInteger likeCount = 0;
                if (![[singleFeed valueForKey:@"like"] isEqual:[NSNull null]]) likeCount = [[singleFeed valueForKey:@"like"] integerValue];
                [feedDictionary setValue:[NSNumber numberWithInteger:likeCount] forKey:@"LikeCount"];
                
                NSString *serverdateString = [singleFeed valueForKey:@"date_recorded"];
                // create dateFormatter with UTC time format
                NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
                [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [dateFormatter2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                NSDate *date2 = [dateFormatter2 dateFromString:serverdateString]; // create date from string
                
                // change to a readable time format and change to local time zone
                [dateFormatter2 setDateFormat:@"EEE, MMM d, yyyy - h:mm a"];
                [dateFormatter2 setTimeZone:[NSTimeZone localTimeZone]];
                NSString *timestamp2 = [dateFormatter2 stringFromDate:date2];
                NSLog(@"date = %@", timestamp2);
                NSDate *outputDate = [dateFormatter2 dateFromString:timestamp2];
                
                
                [feedDictionary setValue:timestamp2 forKey:@"FeedTime"];
                [feedDictionary setValue:outputDate forKey:@"FeedTimeNsDate"];
                
                [feedDictionary setValue:[singleFeed valueForKey:@"user_fullname"] forKey:@"user_fullname"];
                [feedDictionary setValue:[singleFeed valueForKey:@"profile_image_url"] forKey:@"profile_image_url"];
                [feedDictionary setValue:[singleFeed valueForKey:@"Title"] forKey:@"Title"];
                [feedDictionary setValue:[singleFeed valueForKey:@"company"] forKey:@"company"];
                [feedDictionary setValue:[singleFeed valueForKey:@"closed"] forKey:@"closed"];
                [feedDictionary setValue:[singleFeed valueForKey:@"content"] forKey:@"content"];

                [self.userFeedsArray addObject:feedDictionary];
                
            }
            
            if (self.userFeedsArray.count == 0) {
                
                [[[UIAlertView alloc] initWithTitle:@"Welcome to Closed1!" message:@"You don't have any posted deals in your network yet, please proceed to the post a deal page and then invite the rest of your extended sales network. If you believe you received this message in error, please reach out to info@closed1app.com" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
                
            }else{
                
                NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"FeedTimeNsDate" ascending:NO];
                
                NSArray *feedsSortedArrayy =  [self.userFeedsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                self.userFeedsArray = [NSMutableArray arrayWithArray:feedsSortedArrayy];
            }
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];

        });
    });

}

#pragma mark - Tableview Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userFeedsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightOfText = [HomeScreenViewController findHeightForText:[[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"content"] havingWidth:self.view.frame.size.width-16 andFont:[UIFont systemFontOfSize:18.0]];
    return heightOfText+280;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditFeedsCell *editFeedsCell = [tableView dequeueReusableCellWithIdentifier:@"EditFeedsCell"];
    editFeedsCell.userNameLabel.text = [[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"user_fullname"];
    [editFeedsCell.userProfileImage sd_setImageWithURL:[[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"profile_image_url"] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    if (![[[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"Title"] isEqual:@""]) {
        
        editFeedsCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"Title"], [[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"company"]];
    }else{
        editFeedsCell.userTitleLabel.text = @"No Company name present";
    }

    editFeedsCell.closed1Title.text = [NSString stringWithFormat:@"%@",[[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"closed"]];
    editFeedsCell.editFeedsButton.tag  = indexPath.row;
    editFeedsCell.deleteFeedsButton.tag = indexPath.row;
    editFeedsCell.timingLabel.text = [[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"FeedTime"];
    editFeedsCell.userProfileCOmmnet.text = [[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"content"];
    NSInteger messageCount = [[[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"message_count"] integerValue];
    NSInteger likeCount = [[[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"LikeCount"] integerValue];
    editFeedsCell.messageCountLabel.text = [NSString stringWithFormat:@"%zd", messageCount];
    editFeedsCell.likeCOuntLabel.text = [NSString stringWithFormat:@"%zd", likeCount];

    NSString *imageName = @"1220-128.png";
    BOOL isLikeView = [[[self.userFeedsArray objectAtIndex:indexPath.row] valueForKey:@"isLike"] boolValue];
     if(isLikeView == YES) imageName = @"LikeSelectedImage.png";
    [editFeedsCell.likeButtonView setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

    
    return editFeedsCell;

}


-(void)editFeedsButtonTapped: (UIButton *)sender
{
    NSLog(@"Feeds Details are:------>%@", [self.userFeedsArray objectAtIndex: sender.tag]);
    
    EditedFeedsShareViewController *editFeedsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditedFeedsShareViewController"];
    editFeedsViewController.singlefeedsDetails = [self.userFeedsArray objectAtIndex: sender.tag];
    [self.navigationController pushViewController:editFeedsViewController animated:YES];
}


-(void)deleteFeedsButtonTapped: (UIButton *)sender
{
    NSLog(@"Feeds Details are:------>%@", [self.userFeedsArray objectAtIndex: sender.tag]);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete this feed?" message:@"This action cannot be Reversible" preferredStyle: UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDestructive handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *ACTION){
        
        [self deleteuserFeedsFromServerWithIndex:sender.tag];
        
    }]];

    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        
    });
    
}

-(void)deleteuserFeedsFromServerWithIndex: (NSInteger)index
{
    
}



@end
