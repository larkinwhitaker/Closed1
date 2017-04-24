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

@interface SearchViewController () <UITabBarDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate, ServerFailedDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *seachBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) NSMutableArray *feedsArray;
@property(nonatomic) NSMutableArray *filteredArray;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeScreenTableViewCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"HomeScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeScreenTableViewCell"];

    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [self getFeedsArray];

    [self createCustumNavigationBar];
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
                [feedDictionary setValue:[singleFeed valueForKey:@"display_name"] forKey:@"display_name"];
                [feedDictionary setValue:[singleFeed valueForKey:@"profile_image_url"] forKey:@"profile_image_url"];
                [feedDictionary setValue:[singleFeed valueForKey:@"Title"] forKey:@"Title"];
                [feedDictionary setValue:[singleFeed valueForKey:@"closed"] forKey:@"closed"];
                [feedDictionary setValue:[singleFeed valueForKey:@"date_recorded"] forKey:@"date_recorded"];

                [feedDictionary setValue:[singleFeed valueForKey:@"content"] forKey:@"content"];


                
                [self.feedsArray addObject:feedDictionary];
            }
            
            self.filteredArray = _feedsArray;
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
    [navBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]];
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
    
    if (![[[_filteredArray objectAtIndex:indexPath.row] valueForKey:@"display_name"] isEqual:[NSNull null]]) {
        
        homeCell.userNameLabel.text = [[_filteredArray objectAtIndex:indexPath.row]  valueForKey:@"display_name"];
        
    }else{
        
        homeCell.userNameLabel.text = @"";
    }
    [homeCell.userProfileImage sd_setImageWithURL:[[_filteredArray objectAtIndex:indexPath.row]  valueForKey:@"profile_image_url"]
                                 placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
    homeCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[_filteredArray objectAtIndex:indexPath.row] valueForKey:@"Title"], [[_filteredArray objectAtIndex:indexPath.row] valueForKey:@"closed"]];
    
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
    }else{
        
        HomeScreenTableViewCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"HomeScreenTableViewCell"];
        
        if (![[[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"display_name"] isEqual:[NSNull null]]) {
            
            homeCell.userNameLabel.text = [[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"display_name"];
            
        }else{
            
            homeCell.userNameLabel.text = @"";
        }
        [homeCell.userProfileImage sd_setImageWithURL:[[_feedsArray objectAtIndex:indexPath.row] valueForKey:@"profile_image_url"]
                                     placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
        
        homeCell.userTitleLabel.text = [NSString stringWithFormat:@"%@ @ %@", [[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"Title"], [[_feedsArray objectAtIndex:indexPath.row]  valueForKey:@"closed"]];
        
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
-(void)userImageButtonTapped: (UIButton *)sender
{
    
    ProfileDetailViewController *profileDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileDetailViewController"];
    
    profileDetail.userid = [[[[self.feedsArray objectAtIndex:sender.tag] valueForKey:@"Feeds"] valueForKey:@"user_id"] integerValue];
    
    NSLog(@"Userd id : %zd",[[[[self.feedsArray objectAtIndex:sender.tag] valueForKey:@"Feeds"] valueForKey:@"user_id"] integerValue]);
    
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
        
        NSArray *responce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=like&activity_id=%zd&user_id=%zd",[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"item_id"] ,[[_feedsArray objectAtIndex:sender.tag] valueForKey:@"user_id"]] DictionartyToServer:@{}];
        
        NSLog(@"%@",responce);
        
    });
}

#pragma mark - Search Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", @"display_name", searchString, @"Title", searchString, @"closed", searchString, @"content", searchString];
    NSMutableArray *filteredList = [NSMutableArray arrayWithArray:[_feedsArray filteredArrayUsingPredicate:predicate]];
    
    self.filteredArray = [[NSMutableArray alloc]init];
    self.filteredArray = filteredList;
    NSLog(@"%@", _filteredArray);

    
    
    
    return YES;

}


@end
