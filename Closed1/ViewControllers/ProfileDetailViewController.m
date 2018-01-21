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
#import "GetMailDictionary.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "EditedFeedsShareViewController.h"

@interface ProfileDetailViewController ()<UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate, ServerFailedDelegate, MailSendDelegates>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic) ProfileDetailsCell *profileDetails;
@property(nonatomic) NSMutableArray *feedsArray;
@property(nonatomic) NSDictionary *userDetails;
@property(nonatomic) BOOL isCurrentUser;
@property(nonatomic) NSInteger currentUserID;
@property(nonatomic) BOOL shouldDisplayEditView;
@property(nonatomic) NSInteger currentIndexTapfeeds;

@end

@implementation ProfileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Fetching details";
    self.tableView.hidden = YES;
    
    if (_shouldNOTDisplayProfile) {
        
        self.segmentedControl.hidden = YES;
        
    }else{
        
        self.segmentedControl.hidden = NO;
    }
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    self.currentUserID = user.userID;
    if(user.userID == self.userid){
        
        self.isCurrentUser = YES;
    }

    
    
    [ClosedResverResponce sharedInstance].delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverREsponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=get_profile_data&user_id=%zd", self.userid] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([serverREsponce valueForKey:@"success"] != nil) {
                
                if ([[serverREsponce valueForKey:@"success"] integerValue] == 1) {
                    self.tableView.hidden = NO;
                    self.userDetails = [serverREsponce valueForKey:@"data"];
                    
                }else{
                    
                    [[[UIAlertView alloc]initWithTitle:@"oopss!!" message:@"We are unable to process your request at this time. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
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
    [navBar setBarTintColor:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0]];
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
        
        CGFloat heightOfText = 0;
        
         if ([[_userDetails valueForKey:@"Target Buyer"] isEqual:@""] || [[_userDetails valueForKey:@"Target Buyer"] isEqual:[NSNull null]]) {
             
             heightOfText += [HomeScreenViewController findHeightForText:[_userDetails valueForKey:@"Target Buyer"] havingWidth:self.view.frame.size.width-16 andFont:[UIFont systemFontOfSize:18.0]];
         }
        
        if ([[_userDetails valueForKey:@"territory"] isEqual:@""] || [[_userDetails valueForKey:@"territory"] isEqual:[NSNull null]]) {
            
            heightOfText += [HomeScreenViewController findHeightForText:[_userDetails valueForKey:@"territory"] havingWidth:self.view.frame.size.width-16 andFont:[UIFont systemFontOfSize:18.0]];
        }
       
        CGFloat defaultHeight = 353;
        if(self.isCurrentUser == YES) defaultHeight = 313;
        
        return defaultHeight + heightOfText;
        
    }else{
        CGFloat heightOfText = [HomeScreenViewController findHeightForText:[[[self.feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"content"] havingWidth:self.view.frame.size.width-16 andFont:[UIFont systemFontOfSize:18.0]];
        
        NSLog(@"%f", heightOfText);
        return heightOfText+230;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
        NSLog(@"%@", _userDetails);
        
        _profileDetails = [tableView dequeueReusableCellWithIdentifier:@"ProfileDetailsCell"];
        
        [_profileDetails.profileImage sd_setImageWithURL:[NSURL URLWithString:[self.userDetails valueForKey:@"profile Image"]] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
        
       if(self.isCurrentUser == YES){
            
            _profileDetails.blockView.hidden = YES;
        }else{
            
            _profileDetails.blockView.hidden = NO;
            [_profileDetails.userBlockButton addTarget:self action:@selector(blockuserButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            [_profileDetails.unfreindUserButton addTarget:self action:@selector(UnfreindUserButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        }
        
        _profileDetails.userName.text = [self.userDetails valueForKey:@"fullname"];
        [_profileDetails.messageButton addTarget:self action:@selector(messageButtonTapped:)   forControlEvents:UIControlEventTouchUpInside];
        [_profileDetails.callButton addTarget:self action:@selector(callButttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _profileDetails.terrotoryTextfield.text = [self.userDetails valueForKey:@"territory"];
        
        
        if (![[self.userDetails valueForKey:@"company"] isEqual:@""]) {
            
            _profileDetails.titleLabel.text =  [NSString stringWithFormat:@"%@ @ %@", [self.userDetails valueForKey:@"title"], [self.userDetails valueForKey:@"company"]];

        }else{
            
            _profileDetails.titleLabel.text = @"No Company name present";
        }
        
        if ([[_userDetails valueForKey:@"Target Buyer"] isEqual:@""] || [[_userDetails valueForKey:@"Target Buyer"] isEqual:[NSNull null]]) {
            
            _profileDetails.targetBuyersTextFiled.text = @"Target Buyers: Not present";
            
        }else{
            _profileDetails.targetBuyersTextFiled.text = [NSString stringWithFormat:@"Target Buyers: %@", [_userDetails valueForKey:@"Target Buyer"]];

        }
        
        if ([[_userDetails valueForKey:@"territory"] isEqual:@""] || [[_userDetails valueForKey:@"territory"] isEqual:[NSNull null]]) {
            
            _profileDetails.terrotoryTextfield.text = @"Territory: Not present";

        }else{
           
            _profileDetails.terrotoryTextfield.text = [NSString stringWithFormat:@"Territory: %@", [_userDetails valueForKey:@"territory "]];

        }
        
        
        
        NSLog(@"%@",[self.userDetails valueForKey:@"designation"] );
        
        
        if (_shouldNOTDisplayProfile) {
            
            
            self.segmentedControl.hidden = YES;
            
        }else{
            
            self.segmentedControl.hidden = NO;
        }
        
        [self.segmentedControl addTarget:self action:@selector(segmentedControlTaped:) forControlEvents:UIControlEventValueChanged];
        
        return _profileDetails;
        
    }else{
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
        
        
        homeCell.closed1Title.text = [NSString stringWithFormat:@"%@",[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"closed"]];
        
        [homeCell.profileButton addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        homeCell.profileButton.tag  = indexPath.row;
        
        homeCell.timingLabel.text = [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"FeedTime"];
        
        NSInteger likeCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"LikeCount"] integerValue];
        
        homeCell.userProfileCOmmnet.text = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"content"];
        
        homeCell.messageButton.tag = indexPath.row;
        [homeCell.messageButton addTarget:self action:@selector(messageButonTapped:) forControlEvents:UIControlEventTouchUpInside];
        homeCell.likeButton.tag = indexPath.row;
        [homeCell.likeButton addTarget:self action:@selector(likeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSInteger messageCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"message_count"] integerValue];
        
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
        
        
        //For Edit/Delete feeds
        NSInteger feedsID = 0;
        
        if (![[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"user_id"] isEqual:[NSNull null]]) {
            feedsID = [[[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Feeds"] valueForKey:@"user_id"] integerValue];
        }
        
        if (feedsID == self.currentUserID) {
            
            homeCell.editFeedsButton.tag = indexPath.row;
            homeCell.deleteFeedsButton.tag = indexPath.row;
            homeCell.editOptionButton.tag = indexPath.row;
            homeCell.editOptionView.hidden = YES;
            homeCell.editOptionImageView.hidden = NO;
            homeCell.editOptionButton.hidden = NO;
            homeCell.editOptionView.hidden = YES;
            
            if(self.currentIndexTapfeeds == indexPath.row && self.shouldDisplayEditView)
            {
                homeCell.editOptionView.hidden = NO;
            }
            
            [homeCell.editOptionButton addTarget:self action:@selector(editOptionVieewTapped:) forControlEvents:UIControlEventTouchUpInside];
            [homeCell.editFeedsButton addTarget:self action:@selector(editFeedsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [homeCell.deleteFeedsButton addTarget:self action:@selector(deleteFeedsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            
            homeCell.editOptionView.hidden = YES;
            homeCell.editOptionImageView.hidden = YES;
            homeCell.editOptionButton.hidden = YES;
        }
        

        
        
        return homeCell;
    }
    
}

-(void)editOptionVieewTapped: (UIButton *) sender
{
    self.shouldDisplayEditView = !self.shouldDisplayEditView;
    self.currentIndexTapfeeds = sender.tag;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
}

-(void)editFeedsButtonTapped: (UIButton *)sender
{
    EditedFeedsShareViewController *editFeedsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditedFeedsShareViewController"];
    editFeedsViewController.singlefeedsDetails = [[_feedsArray objectAtIndex:sender.tag] valueForKey:@"Feeds"];
    [self.navigationController pushViewController:editFeedsViewController animated:YES];
}

-(void)deleteFeedsButtonTapped: (UIButton *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete this feed?" message:@"This action cannot be Reversible" preferredStyle: UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleDestructive handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *ACTION){
        
        [self deleteuserFeedsFromServerWithIndex:sender.tag];
        
    }]];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)deleteuserFeedsFromServerWithIndex: (NSInteger)index
{
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    NSDictionary *singlefeed = [[_feedsArray objectAtIndex: index] valueForKey:@"Feeds"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Deleting feed";
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=activity_delete&user_id=%zd&activityid=%@", userDetails.userID, [singlefeed valueForKey:@"activity_id"]] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    [[[UIAlertView alloc]initWithTitle:@"Sucessfully Deleted feed" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                    
                    [self getFeedsArray];
                    
                }else{
                    
                    [[[UIAlertView alloc]initWithTitle:@"Failed to delete Feed" message:@"We are unable to process your request. Please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                    
                }
                
            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Failed to delete Feed" message:@"We are unable to process your request. Please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            }
            
            
        });
        
    });
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.shouldDisplayEditView = NO;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: indexPath.row inSection: indexPath.section]] withRowAnimation: UITableViewRowAnimationNone];
    
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
        
        NSString *likeURL = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=like&activity_id=%@&user_id=%@",[[[_feedsArray objectAtIndex:sender.tag] valueForKey: @"Feeds"] valueForKey:@"activity_id"] ,[[[_feedsArray objectAtIndex:sender.tag] valueForKey: @"Feeds"] valueForKey:@"user_id"]];
        
        NSArray *responce = [[ClosedResverResponce sharedInstance] getResponceFromServer: likeURL DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@",responce);
        
        NSLog(@"%@", likeURL);
        
        
    });
}

-(void)userImageButtonTapped: (UIButton *)sender
{
    [self.segmentedControl setSelectedSegmentIndex:0];
}


-(void)callButttonTapped: (id)sender
{
    NSString *userPhone = [_userDetails valueForKey:@"phone"];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:userPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(void)messageButtonTapped: (id)sender
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", [self.userDetails valueForKey:@"user_email"]];
    DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
    
    NSLog(@"%@", dbuser);
    
    if ([dbuser.objectId isEqualToString:[FUser currentId]] == YES)
    {
        [ProgressHUD showSuccess:@"This is you."];
        
    }else if (dbuser.objectId != nil) {
        
        [self didSelectSingleUser:dbuser];
    }else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"It seems the user you are connecting with haven't installed the \"Closed1\" App" message:@"would you like to send invite to him or her?" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [self sendInVites];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Mail Delegate

-(void)isMailSendingSuccess:(BOOL)isSuccess withMesssage:(NSString *)message
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (isSuccess) {
        
        [[[UIAlertView alloc]initWithTitle:message message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
    }else{
       
        [[[UIAlertView alloc]initWithTitle:@"Failed to send emails" message:@"Sorry we are unable to send emails right now. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}
    
-(void)sendInVites
{
    
    GetMailDictionary *mailDict = [[GetMailDictionary alloc]init];
    mailDict.delegate = self;
    [mailDict getMailCOmposerDictionary:@[[self.userDetails valueForKey:@"user_email"]] withNameArray:@[[self.userDetails valueForKey:@"fullname"]] WithView:self.view];
    
    
//    if([MFMailComposeViewController canSendMail]) {
//        
//        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
//        mailCont.mailComposeDelegate = self;
//        
//        [mailCont setSubject:[self.userDetails valueForKey:@"user_email"]];
//        [mailCont setToRecipients:@[]];
//        [mailCont setMessageBody:@"Hi, I would like to invite you to join me on Closed1 to help each other close more deals! Please see the link below to join" isHTML:NO];
//        
//        // Get the resource path and read the file using NSData
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"closed1mail_form" ofType:@"html"];
//        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
//        
//        NSString *mimeType = @"text/html";
//       // [mailCont addAttachmentData:fileData mimeType:mimeType fileName:@""];
//
//        
//        
//        [self presentViewController:mailCont animated:YES completion:nil];
//        
//    }else{
//        
//        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"It seems mail is not configured in your device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//    }
    
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
    self.shouldDisplayEditView = NO;

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=get_profile_feeds&user_id=%zd",self.userid] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (serverResponce.count>0) {
                
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
                    
                    
                    [feedDictionary setValue:[NSNumber numberWithInteger:likeCount] forKey:@"LikeCount"];
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

                    
                    
                    
                    
                    [self.feedsArray addObject:feedDictionary];
                    
                }
            }
            
            
            if (_feedsArray.count == 0) {
                
                [self displayErrorForFeeds];
            }else{

            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"FeedTimeNsDate" ascending:NO];
            
            NSArray *feedsSortedArrayy =  [self.feedsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            self.feedsArray = [NSMutableArray arrayWithArray:feedsSortedArrayy];
            }
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];
        });
        
    });
    
    
}


-(void)displayErrorForFeeds{
    
    [[[UIAlertView alloc] initWithTitle:@"Welcome to Closed1!" message:@"You don't have any posted deals in your network yet, please proceed to the post a deal page and then invite the rest of your extended sales network. If you believe you received this message in error, please reach out to info@closed1app.com" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
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


#pragma mark:- New Code

-(void)blockuserButtonTapped
{
    
    
    if(self.isCurrentUser == YES){
        
        [ProgressHUD showSuccess:@"This is you!"];
        
    }else{
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to block this user?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [self callAPiForBlockingtheUser];
        
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)UnfreindUserButtonTapped
{
    
}

-(void)callAPiForBlockingtheUser{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Please wait..";
    hud.detailsLabelText = @"Blocking user";
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *apiName = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=block_user&initiator_user_id=%@&friend_user_id=%zd", [self.userDetails valueForKey:@"ID"], user.userID];
        
        NSArray *serverresponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:apiName DictionartyToServer:@{} IsEncodingRequires:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            
            if (![[serverresponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                
                if ([[serverresponce valueForKey:@"success"] integerValue] == 1) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BlockingUserNotification" object:nil];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You have sucessfully blocked the user" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }]];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                }else{
                   
                    [[[UIAlertView alloc]initWithTitle:@"Failed to Block the user" message:@"Currently we are unable to process you request. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
                
            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Failed to Block the user" message:@"Currently we are unable to process you request. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
           

        });
        
       
        
    });
    
    

    
    
}


@end
