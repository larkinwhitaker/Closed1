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


@interface HomeScreenViewController ()<UITableViewDelegate , UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tablView;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;

@property(nonatomic) NSArray *feedsArray;

@end

@implementation HomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tablView registerNib:[UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeScreenTableViewCell"];
    
    self.tablView.estimatedRowHeight = 175;
    self.tablView.rowHeight = UITableViewAutomaticDimension;
    
    self.tablView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    [self getFeedsArray];
    
    
}

-(void)getFeedsArray
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting Feed";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:@"http://socialmedia.alkurn.info/api-mobile/?function=get_feeds" DictionartyToServer:@{}];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _feedsArray = [serverResponce valueForKey:@"user_data"];

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tablView reloadData];
        });

        
    });
    
   
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:YES];
//    _countingView.backgroundColor = [UIColor whiteColor];
//    _countingView.fillColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
//    _countingView.strokeColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
//    _countingView.textColor = [UIColor whiteColor];
//    _countingView.hideWhenZero = YES;
//    _countingView.value = 10;
    
}
- (IBAction)messsgaeButtonTapped:(id)sender {
    
    
    
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
    return 250;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeScreenTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCell"];
    
    homeCell.userNameLabel.text = [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"display_name"];
    [homeCell.userProfileImage sd_setImageWithURL:[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@""]
                                 placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
    homeCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"Title"], [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"closed"]];
    
    homeCell.closed1Title.text = [NSString stringWithFormat:@"Closed1: %@",[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"closed"]];
    
    [homeCell.profileButton addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    homeCell.timingLabel.text = [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"date_recorded"];
    
    NSInteger likeCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"like"] integerValue];
    
//    homeCell.userProfileCOmmnet.text = [[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"type"];
    
    if (likeCount == 0) {
        homeCell.likeView.hidden = YES;
        
        
    }else{
        homeCell.likeView.hidden = NO;

        homeCell.likeCOuntLabel.text = [NSString stringWithFormat:@"%zd", likeCount];
    }
    
    
    
    return homeCell;
}


-(void)userImageButtonTapped: (id)sender
{
    
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.title = @"Profile";
    webView.urlString = [[_feedsArray objectAtIndex:0] valueForKey:@"primary_link"];
    
    [self.navigationController pushViewController:webView animated:YES];
    
}


@end
