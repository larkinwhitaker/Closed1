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
#import "ChatView.h"
#import "NZTourTip.h"
#import "Closed1-Swift.h"
#import "Closed1-Bridging-Header.h"
#import "Reachability.h"
#import "NetworkErrorViewController.h"
#import "TabBarHandler.h"
#import <Realm/Realm.h>
#import "utilities.h"
#import "EditFeedsViewController.h"

@interface HomeScreenViewController ()<UITableViewDelegate , UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tablView;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *myFeedsButton;

@property (strong, nonatomic) IBOutlet UIView *messageCountView;
@property(strong) Reachability *internetReachablity;

@property (strong, nonatomic) IBOutlet UILabel *messageCountLabel;
@property(nonatomic) NSMutableArray *feedsArray;
@property(nonatomic) UIRefreshControl *refreshControl;


@end

@implementation HomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setReachabilityNotifier];

    [self.tablView registerNib:[UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeScreenTableViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeedsArray) name:@"NewFeedsAvilable" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(setContactListBadgeCount) name:@"FreindRequestCountNotification" object:nil];
    
    self.tablView.estimatedRowHeight = 175;
    self.tablView.rowHeight = UITableViewAutomaticDimension;
    
    self.tablView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    [self getFeedsArray];
    
#pragma mark - Uncommnet this Method
   [self getLoginWithChattingView];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", @"afzaal.alkurn@gmail.com"];
//    DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
//    
//    NSLog(@"%@", dbuser);

    
//    NSMutableArray *oneSignalIds = [[NSMutableArray alloc] init];
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//        if ([dbuser.oneSignalId length] != 0)
//        [oneSignalIds addObject:dbuser.oneSignalId];
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//    //NSLog(@"%@ - %@", oneSignalIds, text);
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//    [OneSignal postNotification:@{@"contents":@{@"en":@"Demo Testing"}, @"include_player_ids":oneSignalIds}];
    
    
    
//    ContactsListViewController *userProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsListViewController"];
//    
//    [self.navigationController pushViewController:userProfile animated:YES];
    
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [_refreshControl addTarget:self action:@selector(refreshButtonTapped:) forControlEvents:UIControlEventValueChanged];
    _refreshControl.backgroundColor = [UIColor clearColor];
    _refreshControl.tintColor = [UIColor whiteColor];
    self.tablView.refreshControl = _refreshControl;
    
}

-(void)setReachabilityNotifier
{
    __weak __block typeof(self) weakself = self;
    
    _internetReachablity = [Reachability reachabilityForInternetConnection];
    
    self.internetReachablity.unreachableBlock = ^(Reachability *reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NetworkErrorViewController *networkerrorViewController = [weakself.storyboard instantiateViewControllerWithIdentifier:@"NetworkErrorViewController"];
            
            [weakself presentViewController:networkerrorViewController animated:YES completion:nil];
            
        });
        
    };
    
    [_internetReachablity startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeedsArray) name:NSSystemTimeZoneDidChangeNotification object:nil];
    
}




- (void)refreshButtonTapped:(id)sender

{
    [self getFeedsArray];
}

-(void)hideRefreshControl
{
    if (_refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        _refreshControl.attributedTitle = attributedTitle;
        [_refreshControl endRefreshing];
    }
}


-(void)getLoginWithChattingView
{
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    
    if ([FUser currentId] != nil) {
        
        [self configureSinchClient];
        
        if ([FUser isOnboardOk])
        {
            [self saveProfileImageOfUserForChatting];
        }
        else{
            
            [self saveUserDetails];
            [self configureSinchClient];
            [ProgressHUD dismiss];

        }
        
        
    }else{
        
        
#pragma mark - Demo Login Code
        
        
        NSString *email = userDetails.userEmail;
        NSString *password = userDetails.userEmail;
        
        if(userDetails.userEmail != nil) email = userDetails.userEmail;
        else{
            
            email = [NSString stringWithFormat:@"Demo User %zd", rand()];
            password = [NSString stringWithFormat:@"Demo User %zd", rand()];
        }
        
        
        
        LogoutUser(DEL_ACCOUNT_NONE);
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
                 
                 LogoutUser(DEL_ACCOUNT_NONE);
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
//                      else [ProgressHUD showError:[error description]];
                  }];
                 
                 
                 
             }
         }];
        
        
        
    }
    
    
    
}

-(void)saveProfileImageOfUserForChatting
{
    
    UserDetails *userDetails = [UserDetails MR_findFirst];

    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey: userDetails.profileImage];
    
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        [self saveUserProfileImageForChattingView:inMemoryImage];
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:userDetails.profileImage]])
    {
        UIImage *image = [cache imageFromDiskCacheForKey:userDetails.profileImage];
        if(image != nil){
            [self saveUserProfileImageForChattingView:image];
        }
    }
    else
    {
        UIImageView *demoImageView = [[UIImageView alloc]init];
        [demoImageView sd_setImageWithURL: [NSURL URLWithString:userDetails.profileImage] placeholderImage:nil options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (error == nil) {
                
                if(image){
                    [self saveUserProfileImageForChattingView:image];
                }

            }
            
            
        }];
    }
    
    
    
    
    
    
    
//    [demoImageView sd_setImageWithURL:[NSURL URLWithString:userDetails.profileImage] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cathceType, NSURL *imageURL){
//        
//        if (error == nil) {
//            
//            [self saveUserProfileImageForChattingView:image];
//        }
//    }];

}

-(void)saveUserDetails{

    
        if ([FUser isOnboardOk])
        {
            [self saveProfileImageOfUserForChatting];
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
    
    if(userDetails.firstName != nil) firstName = [[userDetails.firstName componentsSeparatedByString:@" "] firstObject];
    if(userDetails.firstName != nil ) lastName = [[userDetails.firstName componentsSeparatedByString:@" "] lastObject];
    
    
    user[FUSER_FULLNAME] = fullname;
    user[FUSER_FIRSTNAME] = firstName;
    user[FUSER_LASTNAME] = lastName;
    user[FUSER_COUNTRY] = country;
    user[FUSER_LOCATION] = location;
    user[FUSER_PHONE] = phone;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [user saveInBackground:^(NSError *error)
     {
         if (error == nil) [self saveProfileImageOfUserForChatting];
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



-(void)saveUserProfileImageForChattingView: (UIImage *)profileImage
{
    
    UIImage *image = profileImage;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UIImage *imagePicture = [Image square:image size:140];
    UIImage *imageThumbnail = [Image square:image size:60];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSData *dataPicture = UIImageJPEGRepresentation(imagePicture, 0.6);
    NSData *dataThumbnail = UIImageJPEGRepresentation(imageThumbnail, 0.6);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *reference1 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_picture", @"jpg")];
    FIRStorageReference *reference2 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_thumbnail", @"jpg")];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [reference1 putData:dataPicture metadata:nil completion:^(FIRStorageMetadata *metadata1, NSError *error)
     {
         if (error == nil)
         {
             [reference2 putData:dataThumbnail metadata:nil completion:^(FIRStorageMetadata *metadata2, NSError *error)
              {
                  if (error == nil)
                  {
                      NSString *linkPicture = metadata1.downloadURL.absoluteString;
                      NSString *linkThumbnail = metadata2.downloadURL.absoluteString;
                      [self saveUserPictures:@{@"linkPicture":linkPicture, @"linkThumbnail":linkThumbnail}];
                  }
                  else [ProgressHUD showError:@"Network error."];
              }];
         }
         else [ProgressHUD showError:@"Network error."];
     }];
    
    
}

- (void)saveUserPictures:(NSDictionary *)links
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    FUser *user = [FUser currentUser];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    user[FUSER_PICTURE] = links[@"linkPicture"];
    user[FUSER_THUMBNAIL] = links[@"linkThumbnail"];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [user saveInBackground:^(NSError *error)
     {
         NSLog(@"Error while saving profile image in Cahtting DB");
     }];
    
}


-(void)getFeedsArray
{

    _feedsArray = [[NSMutableArray alloc]init];
    self.tablView.delegate = nil;
    self.tablView.dataSource = nil;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting Feed";
    
    UserDetails *user = [UserDetails MR_findFirst];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //http://socialmedia.alkurn.info
        //https://closed1app.com
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=get_user_feeds&user_id=%zd", user.userID] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            for (NSDictionary *singleFeed in serverResponce) {
                
                NSMutableDictionary *feedDictionary = [[NSMutableDictionary alloc]init];
                
                BOOL isfeedLiked = NO;
                if (![[singleFeed valueForKey:@"isFeedLiked"] isEqual:[NSNull null]]) {
                    
                    isfeedLiked = [[singleFeed valueForKey:@"isFeedLiked"] boolValue];
                }
                
                [feedDictionary setValue:[NSNumber numberWithBool:isfeedLiked] forKey:@"isLike"];
                
                
                NSInteger likeCount = 0;
                
                if (![[singleFeed valueForKey:@"like"] isEqual:[NSNull null]]) {
                    
                    likeCount = [[singleFeed valueForKey:@"like"] integerValue];
                    
                }
                
                [feedDictionary setValue:[NSNumber numberWithInteger: likeCount] forKey:@"LikeCount"];
                [feedDictionary setValue:singleFeed forKey:@"Feeds"];
                

                
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
                
                
                if ([[[feedDictionary valueForKey:@"Feeds"] valueForKey:@"content"] length]>1) {
                
                    [self.feedsArray addObject:feedDictionary];

                }
            }
            
            
            if (_feedsArray.count == 0) {
                
                [self displayErrorForFeeds];
            }else{
               
                
                NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"FeedTimeNsDate" ascending:NO];
               
                NSArray *feedsSortedArrayy =  [self.feedsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                self.feedsArray = [NSMutableArray arrayWithArray:feedsSortedArrayy];
                
                self.tablView.delegate = self;
                self.tablView.dataSource = self;
                [self.tablView reloadData];

            }
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self hideRefreshControl];
            
            if(![[NSUserDefaults standardUserDefaults]boolForKey:@"FirstTimeExperienceHome"])
            {
                NZTourTip * jgTourTip = [[NZTourTip alloc]initWithViews:@[self.profileButton, self.messageButton, self.myFeedsButton] withMessages:@[@"Tap this to display your profile", @"Tap this to display all the message people send to you", @"Tap this to see your posted Deals"] onScreen:self.view];
                [jgTourTip showTourTip];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"FirstTimeExperienceHome"];
            }
            
        });
        
    });
    
    
    
}


-(void)displayErrorForFeeds
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Welcome to Closed1!" message:@"You don't have any posted deals in your network yet, please proceed to the post a deal page and then invite the rest of your extended sales network. If you believe you received this message in error, please reach out to info@closed1app.com" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)setContactListBadgeCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger freindRequestCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"FreindRequestCount"];
        
        TabBarHandler *tabBarHandler = (TabBarHandler *)self.tabBarController;
        
        UITabBarItem *item2 = tabBarHandler.tabBar.items[1];
        item2.badgeValue = (freindRequestCount != 0) ? [NSString stringWithFormat:@"%ld", (long) freindRequestCount] : nil;
        
        UIUserNotificationSettings *currentUserNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (currentUserNotificationSettings.types & UIUserNotificationTypeBadge)
            [UIApplication sharedApplication].applicationIconBadgeNumber = freindRequestCount;

    });
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
    //[self setContactListBadgeCount];
    
    
    //    //---------------------------------------------------------------------------------------------------------------------------------------------
//    
//    if (total != 0) {
//        self.messageCountLabel.hidden = NO;
//        self.messageCountView.hidden = NO;
//        self.messageCountLabel.text = [NSString stringWithFormat:@"%zd", total];
//        
//    }else{
//        self.messageCountLabel.hidden = YES;
//        self.messageCountView.hidden = YES;
//    }

    
    [self refreshTabCounter];
    
}


- (void)refreshTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSInteger total = 0;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isArchived == NO AND isDeleted == NO AND description CONTAINS[c] %@", @""];
    RLMResults *dbrecents = [[DBRecent objectsWithPredicate:predicate] sortedResultsUsingProperty:FRECENT_LASTMESSAGEDATE ascending:NO];
    TabBarHandler *tabBarHandler = (TabBarHandler *)self.tabBarController;

    for (DBRecent *dbrecent in dbrecents)
        total += dbrecent.counter;
    
    UITabBarItem *item = tabBarHandler.tabBar.items[0];
    item.badgeValue = (total != 0) ? [NSString stringWithFormat:@"%ld", (long) total] : nil;
    
    UIUserNotificationSettings *currentUserNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (currentUserNotificationSettings.types & UIUserNotificationTypeBadge)
        [UIApplication sharedApplication].applicationIconBadgeNumber = total;
    
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

- (IBAction)myFeedsButtonTapped:(id)sender {
    
    EditFeedsViewController *userfeedsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"EditFeedsViewController"];
    [self.navigationController pushViewController:userfeedsScreen animated:YES];

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
    CGFloat heightOfText = [HomeScreenViewController findHeightForText:[[[self.feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"content"] havingWidth:self.view.frame.size.width-16 andFont:[UIFont systemFontOfSize:18.0]];
    
    NSLog(@"%f", heightOfText);
    return heightOfText+230;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeScreenTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCell"];
    
    homeCell.userNameLabel.tag = indexPath.row;
    [homeCell.userNameLabel addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if (![[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"user_fullname"] isEqual:[NSNull null]]) {
        
        [homeCell.userNameLabel setTitle:[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"user_fullname"] forState:UIControlStateNormal];

    }else{
        
        [homeCell.userNameLabel setTitle:@"" forState:UIControlStateNormal];
    }
       [homeCell.userProfileImage sd_setImageWithURL:[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"profile_image_url"]
                                 placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
    if (![[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"Title"] isEqual:@""]) {
        
        homeCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"Title"], [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"company"]];

    }else{
        
        homeCell.userTitleLabel.text = @"No Company name present";
        
    }
    
    
    NSString *titile = @"Not present";
    
    if (![[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"closed"] isEqual:@""] && ![[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"closed"] isEqual:[NSNull null]]) {
        
        titile = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"closed"];
    }
    
    homeCell.closed1Title.text = titile;
    
    [homeCell.profileButton addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    homeCell.profileButton.tag  = indexPath.row;
    
    homeCell.timingLabel.text = [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"FeedTime"] ;
    
    NSInteger likeCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"LikeCount"] integerValue];
    
    
    homeCell.userProfileCOmmnet.text = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"content"];
    
    homeCell.messageButton.tag = indexPath.row;
    [homeCell.messageButton addTarget:self action:@selector(messageButonTapped:) forControlEvents:UIControlEventTouchUpInside];
    homeCell.likeButton.tag = indexPath.row;
    [homeCell.likeButton addTarget:self action:@selector(likeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSInteger messageCount = [[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"message_count"] integerValue];
    
    if (messageCount == 0) {
        
        homeCell.messageView.hidden = NO;
        homeCell.messageCountLabel.text = @"0";

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
        
        homeCell.likeView.hidden = NO;
        homeCell.likeCOuntLabel.text = @"0";

        
    }else{
        homeCell.likeView.hidden = NO;
        
        homeCell.likeCOuntLabel.text = [NSString stringWithFormat:@"%zd", likeCount];
    }
    
    
    
    return homeCell;
}


-(void)messageButonTapped: (UIButton *)sender
{
    CommentListViewController *commentListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentListViewController"];
    commentListVC.feedsDetails= [[self.feedsArray objectAtIndex:sender.tag] valueForKey:@"Feeds"];
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
    
    NSLog(@"%@", [[_feedsArray objectAtIndex:sender.tag] valueForKey:@"Feeds"]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *likeURL = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=like&activity_id=%@&user_id=%@",[[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"Feeds"] valueForKey:@"activity_id"] ,[[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"Feeds"] valueForKey:@"user_id"]];
       
       NSArray *responce = [[ClosedResverResponce sharedInstance] getResponceFromServer: likeURL DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@",responce);
        
        NSLog(@"%@", likeURL);
        
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
