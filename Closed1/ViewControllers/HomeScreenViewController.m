//
//  HomeScreenViewController.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "HomeScreenViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "HomeScreenTableViewCell.h"
#import "ClosedResverResponce.h"
#import "MKNumberBadgeView.h"
#import "NavigationController.h"
#import "ClosedResverResponce.h"
#import "UIImageView+WebCache.h"
#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "UserProfileViewController.h"
#import "CommentListViewController.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "ProfileDetailViewController.h"
#import "NavigationController.h"
#import "ChatsView.h"

@interface HomeScreenViewController ()<UITableViewDelegate , UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tablView;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) IBOutlet UIView *messageCountView;

@property (strong, nonatomic) IBOutlet UILabel *messageCountLabel;
@property(nonatomic) NSMutableArray *feedsArray;

@end

@implementation HomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tablView registerNib:[UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeScreenTableViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeedsArray) name:@"NewFeedsAvilable" object:nil];
    
    self.tablView.estimatedRowHeight = 175;
    self.tablView.rowHeight = UITableViewAutomaticDimension;
    
    self.tablView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    [self getFeedsArray];
    
#pragma mark - Uncommnet this Method
    [self getLoginWithChattingView];
    
    
}

-(void)getLoginWithChattingView
{
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    
    if ([FUser currentId] != nil) {
        
        [self configureSinchClient];
        
        if ([FUser isOnboardOk])
        {
            
        }
        else{
            
            [self saveUserDetails];

            
            [ProgressHUD dismiss];

        }
        
        
    }else{
        
        
#pragma mark - Demo Login Code
        
        
        NSString *email = userDetails.userEmail;
        NSString *password = userDetails.userEmail;
        
        if(userDetails.userEmail != nil) email = userDetails.userEmail;
        
        //---------------------------------------------------------------------------------------------------------------------------------------------
        if ([email length] == 0)	{ [ProgressHUD showError:@"Please enter your email."]; return; }
        if ([password length] == 0)	{ [ProgressHUD showError:@"Please enter your password."]; return; }
        //---------------------------------------------------------------------------------------------------------------------------------------------
        LogoutUser(DEL_ACCOUNT_NONE);
        //---------------------------------------------------------------------------------------------------------------------------------------------
        [ProgressHUD show:nil Interaction:NO];
        //---------------------------------------------------------------------------------------------------------------------------------------------
        [FUser signInWithEmail:email password:password completion:^(FUser *user, NSError *error)
         {
             if (error == nil)
             {
                 [Account add:email password:password];
                 UserLoggedIn(LOGIN_EMAIL);
                 [self saveUserDetails];

                 [ProgressHUD dismiss];
                 
                 [self configureSinchClient];

             }
             else{
                 
#pragma mark - Sign up Code
                 
                 //---------------------------------------------------------------------------------------------------------------------------------------------
                 if ([email length] == 0)	{ [ProgressHUD showError:@"Please enter your email."]; return; }
                 if ([password length] == 0)	{ [ProgressHUD showError:@"Please enter your password."]; return; }
                 //---------------------------------------------------------------------------------------------------------------------------------------------
                 LogoutUser(DEL_ACCOUNT_NONE);
                 //---------------------------------------------------------------------------------------------------------------------------------------------
                 [ProgressHUD show:nil Interaction:YES];
                 //---------------------------------------------------------------------------------------------------------------------------------------------
                 [FUser createUserWithEmail:email password:password completion:^(FUser *user, NSError *error)
                  {
                      if (error == nil)
                      {
                          [Account add:email password:password];
                          UserLoggedIn(LOGIN_EMAIL);
                          
                          [self saveUserDetails];
                          [ProgressHUD dismiss];
                          
                          [self configureSinchClient];

                          
                          
                      }
                      else [ProgressHUD showError:[error description]];
                  }];
                 
                 
                 
             }
         }];
        
        
        
    }
    
    
    
}

-(void)saveUserDetails{

    
        if ([FUser isOnboardOk])
        {
            
        }
        else{
    UserDetails *userDetails = [UserDetails MR_findFirst];

    FUser *user = [FUser currentUser];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSString *fullname = @"Demo User";
    NSString *phone = @"1234567890";
    NSString *country = @"India";
            
    if(userDetails.phoneNumber != nil) phone = userDetails.phoneNumber;
    if(userDetails.country != nil) country = userDetails.country;

    
    if(userDetails.firstName != nil) fullname = [NSString stringWithFormat:@"%@", userDetails.firstName];
    
    NSString *firstName = @"Demo";
    NSString *lastName = @"User";
    NSString *location = @"Not present";
    
    if(userDetails.firstName != nil) firstName = userDetails.firstName;
    if(userDetails.lastName != nil ) lastName = userDetails.lastName;
    
    
    user[FUSER_FULLNAME] = fullname;
    user[FUSER_FIRSTNAME] = firstName;
    user[FUSER_LASTNAME] = lastName;
    user[FUSER_COUNTRY] = country;
    user[FUSER_LOCATION] = location;
    user[FUSER_PHONE] = phone;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [user saveInBackground:^(NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error."];
     }];

    }

}

-(void)configureSinchClient
{
    // Instantiate a Sinch client object
    id<SINClient> sinchClient = [Sinch clientWithApplicationKey:SINCH_KEY
                                              applicationSecret:SINCH_SECRET
                                                environmentHost:SINCH_HOST
                                                         userId:[FUser currentId]];
    
    [sinchClient setSupportCalling:YES];
    [sinchClient setSupportMessaging:YES];
    [sinchClient enableManagedPushNotifications];
}

-(void)getFeedsArray
{
    _feedsArray = [[NSMutableArray alloc]init];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting Feed";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:@"http://socialmedia.alkurn.info/api-mobile/?function=get_feeds" DictionartyToServer:@{}];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            for (NSDictionary *singleFeed in serverResponce) {
                
                NSMutableDictionary *feedDictionary = [[NSMutableDictionary alloc]init];
                
                [feedDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isLike"];
                [feedDictionary setValue:[NSNumber numberWithInteger:[[singleFeed valueForKey:@"like"] integerValue]] forKey:@"LikeCount"];
                [feedDictionary setValue:singleFeed forKey:@"Feeds"];
                
                [self.feedsArray addObject:feedDictionary];
            }
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tablView reloadData];
        });
        
    });
    
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController setNavigationBarHidden:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isArchived == NO AND isDeleted == NO AND description CONTAINS[c] %@", @""];
    RLMResults *dbrecents = [[DBRecent objectsWithPredicate:predicate] sortedResultsUsingProperty:FRECENT_LASTMESSAGEDATE ascending:NO];
    
    NSInteger total = 0;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    for (DBRecent *dbrecent in dbrecents)
        total += dbrecent.counter;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    if (total != 0) {
        self.messageCountLabel.hidden = NO;
        self.messageCountView.hidden = NO;
        self.messageCountLabel.text = [NSString stringWithFormat:@"%zd", total];
        
    }else{
        self.messageCountLabel.hidden = YES;
        self.messageCountView.hidden = YES;
    }

    
}
- (IBAction)messsgaeButtonTapped:(id)sender {
    
    ChatsView *chatsView = [[ChatsView alloc] initWithNibName:@"ChatsView" bundle:nil];
    
    NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:chatsView];
    
    [self presentViewController:navController1 animated:YES completion:nil];

    
}
- (IBAction)profileButtonTapped:(id)sender {
    
    
    UserProfileViewController *userProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    
    [self.navigationController pushViewController:userProfile animated:YES];

}
#pragma mark - Tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _feedsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightOfText = [HomeScreenViewController findHeightForText:[[self.feedsArray objectAtIndex:indexPath.row] valueForKey:@"content"] havingWidth:self.view.frame.size.width-16 andFont:[UIFont systemFontOfSize:18.0]];
    
    NSLog(@"%f", heightOfText);
    return heightOfText+230;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeScreenTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCell"];
    
    if (![[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"display_name"] isEqual:[NSNull null]]) {
        
        homeCell.userNameLabel.text = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"display_name"];

    }else{
        
        homeCell.userNameLabel.text = @"";
    }
       [homeCell.userProfileImage sd_setImageWithURL:[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"profile_image_url"]
                                 placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
    homeCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"Title"], [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"closed"]];
    
    homeCell.closed1Title.text = [NSString stringWithFormat:@"%@",[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"closed"]];
    
    [homeCell.profileButton addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    homeCell.profileButton.tag  = indexPath.row;
    
    homeCell.timingLabel.text = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"date_recorded"];
    
    NSInteger likeCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"LikeCount"] integerValue];
    
    
    homeCell.userProfileCOmmnet.text = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"content"];
    
    homeCell.messageButton.tag = indexPath.row;
    [homeCell.messageButton addTarget:self action:@selector(messageButonTapped:) forControlEvents:UIControlEventTouchUpInside];
    homeCell.likeButton.tag = indexPath.row;
    [homeCell.likeButton addTarget:self action:@selector(likeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSInteger messageCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"message_count"] integerValue];
    
    if (messageCount == 0) {
        
        homeCell.messageView.hidden = YES;
        
    }else{
        
        homeCell.messageView.hidden = NO;
        homeCell.messageCountLabel.text = [NSString stringWithFormat:@"%zd", messageCount];
    }
    
    BOOL isLikeView = [[[self.feedsArray objectAtIndex:indexPath.row] valueForKey:@"isLike"] boolValue];
    if (isLikeView) {
        
        [homeCell.likeButtonView setBackgroundImage:[UIImage imageNamed:@"LikeSelectedImage.png"] forState:UIControlStateNormal];
        
    }else{
        
        [homeCell.likeButtonView setBackgroundImage:[UIImage imageNamed:@"1220-128.png"] forState:UIControlStateNormal];

    }
    
    if (likeCount <= 0) {
        
        homeCell.likeView.hidden = YES;
        
        
    }else{
        homeCell.likeView.hidden = NO;
        
        homeCell.likeCOuntLabel.text = [NSString stringWithFormat:@"%zd", likeCount];
    }
    
    
    
    return homeCell;
}


-(void)messageButonTapped: (UIButton *)sender
{
    CommentListViewController *commentListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentListViewController"];
    commentListVC.feedsDetails= [self.feedsArray objectAtIndex:sender.tag];
    [self.navigationController pushViewController:commentListVC animated:YES];
}

-(void)likeButtonTapped: (UIButton *)sender
{
    
    BOOL isSelected = [[[self.feedsArray objectAtIndex:sender.tag] valueForKey:@"isLike"] boolValue];
    if (!isSelected) {
        
        NSInteger likeCOunt = [[[self.feedsArray objectAtIndex:sender.tag] valueForKey:@"LikeCount"] integerValue];
        
        NSLog(@"Before Like count is: %zd", likeCOunt);
        
        [[self.feedsArray objectAtIndex:sender.tag] setValue:[NSNumber numberWithInteger:likeCOunt+1] forKey:@"LikeCount"];
        [[self.feedsArray objectAtIndex:sender.tag] setValue:[NSNumber numberWithBool:YES] forKey:@"isLike"];
        
    }else{
        
        NSInteger likeCOunt = [[[self.feedsArray objectAtIndex:sender.tag] valueForKey:@"LikeCount"] integerValue];
        
        NSLog(@"After Like count is: %zd", likeCOunt);
        
        [[self.feedsArray objectAtIndex:sender.tag] setValue:[NSNumber numberWithInteger:likeCOunt-1] forKey:@"LikeCount"];
        [[self.feedsArray objectAtIndex:sender.tag] setValue:[NSNumber numberWithBool:NO] forKey:@"isLike"];
        
    }
    
    [self.tablView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
       NSArray *responce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=like&activity_id=%zd&user_id=%zd",[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"item_id"] ,[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"user_id"]] DictionartyToServer:@{}];
        
        NSLog(@"%@",responce);
        
    });
}

-(void)userImageButtonTapped: (UIButton *)sender
{
    
   ProfileDetailViewController *profileDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileDetailViewController"];
    
    profileDetail.userid = [[[[self.feedsArray objectAtIndex:sender.tag] valueForKey:@"Feeds"] valueForKey:@"user_id"] integerValue];
    
    NSLog(@"Userd id : %zd",[[[[self.feedsArray objectAtIndex:sender.tag] valueForKey:@"Feeds"] valueForKey:@"user_id"] integerValue]);
    
    [self.navigationController pushViewController:profileDetail animated:YES];
    
}

+ (CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font
{
    CGFloat result = font.pointSize + 4;
    if (text)
    {
        CGSize textSize = { widthValue, CGFLOAT_MAX };       //Width and height of text area
        CGSize size;
        
        //iOS 7
        CGRect frame = [text boundingRectWithSize:textSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{ NSFontAttributeName:font }
                                          context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height+1);
        result = MAX(size.height, result); //At least one row
    }
    return result;
}

@end
