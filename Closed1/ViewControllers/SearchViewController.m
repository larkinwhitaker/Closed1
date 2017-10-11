//
//  SearchViewController.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "SearchViewController.h"
#import "HomeScreenTableViewCell.h"
#import "MBProgressHUD.h"
#import "ClosedResverResponce.h"
#import "CommentListViewController.h"
#import "UIImageView+WebCache.h"
#import "HomeScreenViewController.h"
#import "ProfileDetailViewController.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"


@interface SearchViewController () <UITabBarDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate, ServerFailedDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *seachBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) NSMutableArray *feedsArray;
@property(nonatomic) NSMutableArray *filteredArray;
@property(nonatomic) UIRefreshControl *refreshControl;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeScreenTableViewCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeScreenTableViewCell"];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_bgr"]];
    self.searchDisplayController.searchResultsTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_bgr"]];

    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];


    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [self getFeedsArray];

    [self createCustumNavigationBar];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [_refreshControl addTarget:self action:@selector(refreshButtonTapped:) forControlEvents:UIControlEventValueChanged];
    _refreshControl.backgroundColor = [UIColor clearColor];
    _refreshControl.tintColor = [UIColor whiteColor];
    self.tableView.refreshControl = _refreshControl;
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

- (void)refreshButtonTapped:(id)sender
{
    [self getFeedsArray];
}

-(void)getFeedsArray
{
    _feedsArray = [[NSMutableArray alloc]init];
    _filteredArray = [[NSMutableArray alloc]init];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting Feed";
    UserDetails *user = [UserDetails MR_findFirst];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=get_user_feeds&user_id=%zd", user.userID] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            for (NSDictionary *singleFeed in serverResponce) {
                
                NSMutableDictionary *feedDictionary = [[NSMutableDictionary alloc]init];
                
                [feedDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"isLike"];
            
                NSInteger likeCount = 0;
                
                if (![[singleFeed valueForKey:@"like"] isEqual:[NSNull null]]) {
                    
                    likeCount = [[singleFeed valueForKey:@"like"] integerValue];
                    
                }
                [feedDictionary setValue:[NSNumber numberWithInteger:likeCount] forKey:@"LikeCount"];
                [feedDictionary setValue:[singleFeed valueForKey:@"user_fullname"] forKey:@"user_fullname"];
                [feedDictionary setValue:[singleFeed valueForKey:@"profile_image_url"] forKey:@"profile_image_url"];
                [feedDictionary setValue:[singleFeed valueForKey:@"Title"] forKey:@"Title"];
                [feedDictionary setValue:[singleFeed valueForKey:@"closed"] forKey:@"closed"];
                [feedDictionary setValue:[singleFeed valueForKey:@"date_recorded"] forKey:@"date_recorded"];

                [feedDictionary setValue:[singleFeed valueForKey:@"content"] forKey:@"content"];
                [feedDictionary setValue:[singleFeed valueForKey:@"user_id"] forKey:@"user_id"];

                [feedDictionary setValue:[singleFeed valueForKey:@"company"] forKey:@"company"];
                [feedDictionary setValue:[singleFeed valueForKey:@"message_count"] forKey:@"message_count"];

                
                if ([[singleFeed valueForKey:@"content"] length]>1) {
                    
                    [self.feedsArray addObject:feedDictionary];
                    
                }
            }
            
            self.filteredArray = _feedsArray;
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self hideRefreshControl];

            [self.tableView reloadData];
        });
        
    });
}


- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Search"];
    [self.view addSubview:navBar];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        
        CGFloat heightOfText = [HomeScreenViewController findHeightForText:[[self.filteredArray objectAtIndex:indexPath.row] valueForKey:@"content"] havingWidth:self.view.frame.size.width-16 andFont:[UIFont systemFontOfSize:18.0]];
        
        NSLog(@"%f", heightOfText);
        return heightOfText+230;
    }else{
        
        CGFloat heightOfText = [HomeScreenViewController findHeightForText:[[self.feedsArray objectAtIndex:indexPath.row] valueForKey:@"content"] havingWidth:self.view.frame.size.width-16 andFont:[UIFont systemFontOfSize:18.0]];
        
        NSLog(@"%f", heightOfText);
        return heightOfText+230;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return _filteredArray.count;
    }
    else
    {
        return _feedsArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
    HomeScreenTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCell"];
    
        
        [homeCell.userNameLabel addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        homeCell.userNameLabel.tag = indexPath.row;
    if (![[[_filteredArray objectAtIndex:indexPath.row] valueForKey:@"user_fullname"] isEqual:[NSNull null]]) {
        
        [homeCell.userNameLabel setTitle:[[_filteredArray objectAtIndex:indexPath.row]  valueForKey:@"user_fullname"] forState:UIControlStateNormal];
        
    }else{
        
        [homeCell.userNameLabel setTitle:@"" forState:UIControlStateNormal];
    }
    [homeCell.userProfileImage sd_setImageWithURL:[[_filteredArray objectAtIndex:indexPath.row]  valueForKey:@"profile_image_url"]
                                 placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
        if (![[[_filteredArray objectAtIndex:indexPath.row]  valueForKey:@"Title"] isEqual:@""]) {
            
            homeCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[_filteredArray objectAtIndex:indexPath.row] valueForKey:@"Title"], [[_filteredArray objectAtIndex:indexPath.row]  valueForKey:@"company"]];
            
        }else{
            
            homeCell.userTitleLabel.text = @"No Company name present";
            
        }
        
    
    homeCell.closed1Title.text = [NSString stringWithFormat:@"%@",[[_filteredArray objectAtIndex:indexPath.row]  valueForKey:@"closed"]];
    
    [homeCell.profileButton addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    homeCell.profileButton.tag  = indexPath.row;
    
    homeCell.timingLabel.text = [[_filteredArray objectAtIndex:indexPath.row]  valueForKey:@"date_recorded"];
    
    NSInteger likeCount = [[[_filteredArray objectAtIndex:indexPath.row] valueForKey:@"LikeCount"] integerValue];
    
    
    homeCell.userProfileCOmmnet.text = [[_filteredArray objectAtIndex:indexPath.row]  valueForKey:@"content"];
    
    homeCell.messageButton.tag = indexPath.row;
    [homeCell.messageButton addTarget:self action:@selector(messageButonTapped:) forControlEvents:UIControlEventTouchUpInside];
    homeCell.likeButton.tag = indexPath.row;
    [homeCell.likeButton addTarget:self action:@selector(likeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSInteger messageCount = [[[_filteredArray objectAtIndex:indexPath.row] valueForKey:@"message_count"] integerValue];
    
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
    }else{
        
        HomeScreenTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCell"];
        
        
        [homeCell.userNameLabel addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        homeCell.userNameLabel.tag = indexPath.row;
        if (![[[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"user_fullname"] isEqual:[NSNull null]]) {
            
            [homeCell.userNameLabel setTitle:[[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"user_fullname"] forState:UIControlStateNormal];
            
        }else{
            
            [homeCell.userNameLabel setTitle:@"" forState:UIControlStateNormal];
        }
        [homeCell.userProfileImage sd_setImageWithURL:[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"profile_image_url"]
                                     placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
        
        
        if (![[[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"Title"] isEqual:@""]) {
            
            homeCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"Title"], [[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"company"]];
            
        }else{
            
            homeCell.userTitleLabel.text = @"No Company name present";
            
        }
        homeCell.closed1Title.text = [NSString stringWithFormat:@"%@",[[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"closed"]];
        
        [homeCell.profileButton addTarget:self action:@selector(userImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        homeCell.profileButton.tag  = indexPath.row;
        
        homeCell.timingLabel.text = [[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"date_recorded"];
        
        NSInteger likeCount = [[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"LikeCount"] integerValue];
        
        
        homeCell.userProfileCOmmnet.text = [[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"content"];
        
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
-(void)userImageButtonTapped: (UIButton *)sender
{
    
    ProfileDetailViewController *profileDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileDetailViewController"];
    
    
    if([self.searchDisplayController isActive]){
        
        profileDetail.userid = [[[self.filteredArray objectAtIndex:sender.tag]  valueForKey:@"user_id"] integerValue];
        NSLog(@"Userd id : %zd",[[[self.filteredArray objectAtIndex:sender.tag]  valueForKey:@"user_id"] integerValue]);


    }else{
        
        profileDetail.userid = [[[self.feedsArray objectAtIndex:sender.tag]  valueForKey:@"user_id"] integerValue];
        NSLog(@"Userd id : %zd",[[[self.feedsArray objectAtIndex:sender.tag]  valueForKey:@"user_id"] integerValue]);


    }

    
    
    
    [self.navigationController pushViewController:profileDetail animated:YES];
    
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
        
        NSArray *responce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=like&activity_id=%zd&user_id=%zd",[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"item_id"] ,[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"user_id"]] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@",responce);
        
    });
}

#pragma mark - Search Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", @"user_fullname", searchString, @"Title", searchString, @"closed", searchString, @"content", searchString];
    NSMutableArray *filteredList = [NSMutableArray arrayWithArray:[_feedsArray filteredArrayUsingPredicate:predicate]];
    
    self.filteredArray = [[NSMutableArray alloc]init];
    self.filteredArray = filteredList;
    NSLog(@"%@", _filteredArray);

    
    
    
    return YES;

}

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    });
}


@end
