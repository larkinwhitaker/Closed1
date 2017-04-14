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


@interface ProfileDetailViewController ()<UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic) ProfileDetailsCell *profileDetails;
@property(nonatomic) NSArray *feedsArray;


@end

@implementation ProfileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%@", _singleContact);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeScreenTableViewCell"];

    
    [self createCustumNavigationBar];
   
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
        
        return 307 + [HomeScreenViewController findHeightForText:_singleContact.territory havingWidth:self.view.frame.size.width/2 andFont:[UIFont systemFontOfSize:18.0]];
    }else{
        return 223;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
    
    
    _profileDetails = [tableView dequeueReusableCellWithIdentifier:@"ProfileDetailsCell"];
    
    [_profileDetails.profileImage sd_setImageWithURL:[NSURL URLWithString:self.singleContact.imageURL] placeholderImage:[UIImage imageNamed:@""]];
    _profileDetails.userName.text = _singleContact.userName;
    [_profileDetails.messageButton addTarget:self action:@selector(messageButtonTapped:)   forControlEvents:UIControlEventTouchUpInside];
    [_profileDetails.callButton addTarget:self action:@selector(callButttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _profileDetails.territoryLabel.text = _singleContact.territory;
    _profileDetails.previosRoleLabel.text = _singleContact.designation;
    _profileDetails.titleLabel.text =  [NSString stringWithFormat:@"%@ @ %@", _singleContact.designation, _singleContact.company];
    
        [self.segmentedControl addTarget:self action:@selector(segmentedControlTaped:) forControlEvents:UIControlEventValueChanged];
        
    return _profileDetails;
        
    }else{
        
        HomeScreenTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCell"];
        
        homeCell.userNameLabel.text = [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"display_name"];
        [homeCell.userProfileImage sd_setImageWithURL:[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@""]
                                     placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
        
        homeCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Title"], [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"closed"]];
        
        homeCell.closed1Title.text = [NSString stringWithFormat:@"Closed1: %@",[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"closed"]];
        
        [homeCell.profileButton addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        homeCell.timingLabel.text = [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"date_recorded"];
        
        NSInteger likeCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"like"] integerValue];
        
        homeCell.userProfileCOmmnet.text = [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"content"];
        
        homeCell.messageButton.tag = indexPath.row;
        [homeCell.messageButton addTarget:self action:@selector(messageButonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        NSInteger messageCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"message_count"] integerValue];
        
        if (messageCount == 0) {
            
            homeCell.messageView.hidden = YES;
            
        }else{
            
            homeCell.messageView.hidden = NO;
            homeCell.messageCountLabel.text = [NSString stringWithFormat:@"%zd", messageCount];
        }
        
        if (likeCount == 0) {
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

-(void)userImageButtonTapped: (id)sender
{
    
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.title = @"Profile";
    webView.urlString = [[_feedsArray objectAtIndex:0] valueForKey:@"primary_link"];
    
    [self.navigationController pushViewController:webView animated:YES];
    
}


-(void)callButttonTapped: (id)sender
{
    NSString *phoneNumber = [@"tel://" stringByAppendingString:@"1234567890"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(void)messageButtonTapped: (id)sender
{
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:@""];
        [mailCont setToRecipients:@[]];
        [mailCont setMessageBody:@"" isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
        
    }

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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting Feed";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _feedsArray = [[ClosedResverResponce sharedInstance] getResponceFromServer:@"http://socialmedia.alkurn.info/api-mobile/?function=get_feeds" DictionartyToServer:@{}];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];
        });
        
        
    });
    
    
    
    
}



@end
