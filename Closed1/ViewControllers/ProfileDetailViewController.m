//
//  ProfileDetailViewController.m
//  Closed1
//
//  Created by Nazim on 31/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ProfileDetailViewController.h"
#import "ProfileDetailsCell.h"
#import "UIImageView+WebCache.h"
#import <MessageUI/MessageUI.h>
#import "HomeScreenTableViewCell.h"
#import "ClosedResverResponce.h"
#import "MBProgressHUD.h"
#import "HomeScreenViewController.h"
#import "CommentListViewController.h"
#import "WebViewController.h"
#import "ChatView.h"
#import "NavigationController.h"

@interface ProfileDetailViewController ()<UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate, ServerFailedDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic) ProfileDetailsCell *profileDetails;
@property(nonatomic) NSMutableArray *feedsArray;
@property(nonatomic) NSDictionary *userDetails;


@end

@implementation ProfileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Fetching details";
    self.tableView.hidden = YES;
    
    [ClosedResverResponce sharedInstance].delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverREsponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=get_profile_data&user_id=%zd", self.userid] DictionartyToServer:@{}];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([serverREsponce valueForKey:@"success"] != nil) {
                
                if ([[serverREsponce valueForKey:@"success"] integerValue] == 1) {
                    self.tableView.hidden = NO;
                    self.userDetails = [serverREsponce valueForKey:@"data"];
                }else{
                    
                    [self serverFailedWithTitle:@"Failed to fetch profile" SubtitleString:@"We are unable to process your request at this time. Please try again later."];
                }
            }else{
                
                [self serverFailedWithTitle:@"Failed to fetch profile" SubtitleString:@"We are unable to process your request at this time. Please try again later."];
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];
        });
    });
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeScreenTableViewCell"];
    
    
    [self createCustumNavigationBar];
    
    self.tableView.estimatedRowHeight = 362;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    
    navItem.leftBarButtonItem = backButton;
    
    
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Profile"];
    [self.view addSubview:navBar];
    
}
-(IBAction)backButtonTapped:(UIBarButtonItem *)sender

{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backButtontapped: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Tableview Delegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
        return 1;
        
    }else{
        
        return _feedsArray.count;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
        return 307 + [HomeScreenViewController findHeightForText:[self.userDetails valueForKey:@"territory"] havingWidth:self.view.frame.size.width/2 andFont:[UIFont systemFontOfSize:18.0]];
    }else{
        CGFloat heightOfText = [HomeScreenViewController findHeightForText:[[self.feedsArray objectAtIndex:indexPath.row] valueForKey:@"content"] havingWidth:self.view.frame.size.width-16 andFont:[UIFont systemFontOfSize:18.0]];
        
        NSLog(@"%f", heightOfText);
        return heightOfText+207;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
        NSLog(@"%@", _userDetails);
        
        _profileDetails = [tableView dequeueReusableCellWithIdentifier:@"ProfileDetailsCell"];
        
        
        [_profileDetails.profileImage sd_setImageWithURL:[NSURL URLWithString:[self.userDetails valueForKey:@"imageURL"]] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
        _profileDetails.userName.text = [self.userDetails valueForKey:@"userName"];
        [_profileDetails.messageButton addTarget:self action:@selector(messageButtonTapped:)   forControlEvents:UIControlEventTouchUpInside];
        [_profileDetails.callButton addTarget:self action:@selector(callButttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _profileDetails.territoryLabel.text = [self.userDetails valueForKey:@"territory"];
        _profileDetails.previosRoleLabel.text = [self.userDetails valueForKey:@"designation"];
        _profileDetails.titleLabel.text =  [NSString stringWithFormat:@"%@ @ %@", [self.userDetails valueForKey:@"title"], [self.userDetails valueForKey:@"company"]];
        
        NSLog(@"%@",[self.userDetails valueForKey:@"designation"] );
        
        [self.segmentedControl addTarget:self action:@selector(segmentedControlTaped:) forControlEvents:UIControlEventValueChanged];
        
        return _profileDetails;
        
    }else{
        HomeScreenTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCell"];
        
        if (![[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"display_name"] isEqual:[NSNull null]]) {
            
            homeCell.userNameLabel.text = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"display_name"];
            
        }else{
            
            homeCell.userNameLabel.text = @"";
        }
        [homeCell.userProfileImage sd_setImageWithURL:[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"profile_image_url"]
                                     placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
        
        homeCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"Title"], [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"closed"]];
        
        homeCell.closed1Title.text = [NSString stringWithFormat:@"Closed1: %@",[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"closed"]];
        
        [homeCell.profileButton addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        homeCell.timingLabel.text = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"date_recorded"];
        
        NSInteger likeCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"LikeCount"] integerValue];
        
        homeCell.userProfileCOmmnet.text = [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"content"];
        
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
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *responce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=like&activity_id=%zd&user_id=%zd",[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"item_id"] ,[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"user_id"]] DictionartyToServer:@{}];
        
        NSLog(@"%@",responce);
        
    });
}

-(void)userImageButtonTapped: (UIButton *)sender
{
    
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.title = @"Profile";
    webView.urlString = [[_feedsArray objectAtIndex:0] valueForKey:@"primary_link"];
    
    [self.navigationController pushViewController:webView animated:YES];
    
}


-(void)callButttonTapped: (id)sender
{
    NSString *userPhone = [_userDetails valueForKey:@"phone"];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:userPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(void)messageButtonTapped: (id)sender
{
    
#pragma mark - For Now Chatting Disabled
    
//    [self sendInVites];
   
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", [self.userDetails valueForKey:@"user_email"]];
    DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
    
    NSLog(@"%@", dbuser);
    
    if ([dbuser.objectId isEqualToString:[FUser currentId]] == YES)
    {
     [ProgressHUD showSuccess:@"This is you."];
        
    }else if (dbuser.objectId != nil) {
        
        [self didSelectSingleUser:dbuser];
    }else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"It seems the user you are connecting with haven't installed the \"Closed1\" App" message:@"would you like to send invite to him?" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [self sendInVites];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


//    NSDictionary *dictionary = [Chat startPrivate:dbuser2];
//    [self actionChat:dictionary];


//}


-(void)sendInVites
{
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:[self.userDetails valueForKey:@"user_email"]];
        [mailCont setToRecipients:@[]];
        [mailCont setMessageBody:@"Hi, I would like to invite you to join me on Closed1 to help each other close more deals! Please see the link below to join" isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
        
    }
    
}

- (void)didSelectSingleUser:(DBUser *)dbuser2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSDictionary *dictionary = [Chat startPrivate:dbuser2];
    [self actionChat:dictionary];
}

- (void)actionChat:(NSDictionary *)dictionary
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    ChatView *chatView = [[ChatView alloc] initWith:dictionary];
    chatView.hidesBottomBarWhenPushed = YES;
    NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:chatView];
    
    [self presentViewController:navController1 animated:YES completion:nil];
}

#pragma mark - Mail Delegates

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)segmentedControlTaped: (id)sender
{
    
    if (_segmentedControl.selectedSegmentIndex == 1) {
        
        if (_feedsArray.count == 0) {
            
            [self getFeedsArray];
        }
    }
    
    [self.tableView reloadData];
}

-(void)getFeedsArray
{
    _feedsArray = [[NSMutableArray alloc]init];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting Feed";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=get_profile_feeds&user_id=%zd",self.userid] DictionartyToServer:@{}];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (serverResponce.count>2) {
                
                for (NSDictionary *singleFeed in serverResponce) {
                    
                    NSMutableDictionary *feedDictionary = [[NSMutableDictionary alloc]init];
                    
                    [feedDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isLike"];
                    [feedDictionary setValue:[NSNumber numberWithInteger:[[singleFeed valueForKey:@"like"] integerValue]] forKey:@"LikeCount"];
                    [feedDictionary setValue:singleFeed forKey:@"Feeds"];
                    
                    [self.feedsArray addObject:feedDictionary];
                }
            }
            
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];
        });
        
    });
    
    
    
}

#pragma mark - Sserver Failed

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:subtitle preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDestructive handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    });
}


@end
