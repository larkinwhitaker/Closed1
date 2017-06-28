//
//  AddFreindsViewController.m
//  Closed1
//
//  Created by Nazim on 13/05/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "AddFreindsViewController.h"
#import "MBProgressHUD.h"
#import "ClosedResverResponce.h"
#import "AddFreindsCell.h"
#import "MagicalRecord.h"
#import "UserDetails+CoreDataClass.h"
#import "UIImageView+WebCache.h"
#import "ChatsView.h"
#import "ChatView.h"
#import "FreindRequestViewController.h"
#import "ProfileDetailViewController.h"


@interface AddFreindsViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property(nonatomic) NSMutableArray *freindList;
@property(nonatomic) NSMutableArray *filteredArray;
@property(nonatomic) UILabel *nofreindsLabel;

@end

@implementation AddFreindsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
    
    _nofreindsLabel = [[UILabel alloc]initWithFrame:self.navigationController.view.frame];
    _nofreindsLabel.hidden = YES;
    _nofreindsLabel.text = @"Search name of freind whom\nyou wish to send freind request";
    _nofreindsLabel.numberOfLines = 0;
    _nofreindsLabel.textAlignment = NSTextAlignmentCenter;
    _nofreindsLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:_nofreindsLabel];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    
    [self getFreindListFromServer];
    
}

-(void)getFreindListFromServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting List";
    self.tableView.allowsSelection = NO;
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    
    NSString *URL = [NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=getallmembers&user_id=%zd", user.userID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:URL DictionartyToServer:@{} IsEncodingRequires:NO];
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                
                self.freindList = [serverResponce valueForKey:@"data"];
//                self.filteredArray = self.freindList;
//                [self.tableView reloadData];
                _nofreindsLabel.hidden = NO;

                
            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Failed to get List" message:@"Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
            }
            
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        
        
        
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createCustumNavigationBar];
    
    self.filteredArray = [[NSMutableArray alloc]init];
    [self.filteredArray removeAllObjects];
    [self.tableView reloadData];
    self.searchBar.text = @"";
    _nofreindsLabel.hidden = NO;
}

- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
    
    navItem.leftBarButtonItem = backButton;
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Add Freind"];
    [self.view addSubview:navBar];
    
}

-(void)backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddFreindsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFreindsCell"];
    cell.sendrequest.tag = indexPath.row;
    cell.profileImageButton.tag = indexPath.row;
    cell.userName.tag = indexPath.row;

    [cell.userName setTitle:[[self.filteredArray objectAtIndex:indexPath.row] valueForKey:@"fullname"] forState:UIControlStateNormal];
    [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[[self.filteredArray objectAtIndex:indexPath.row] valueForKey:@"profile_image_url"]] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    [cell.sendrequest addTarget:self action:@selector(sendFreindRequestTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.profileImageButton addTarget:self action:@selector(sendFreindRequestTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.userName addTarget:self action:@selector(openScreenForProfileDetail:) forControlEvents:UIControlEventTouchUpInside];


    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}


-(void)openScreenForProfileDetail: (UIButton *)sender
{
    ProfileDetailViewController *profileDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileDetailViewController"];
    
    NSLog(@"%@",[self.filteredArray objectAtIndex:sender.tag] );
    
    profileDetail.userid = [[[self.filteredArray objectAtIndex:sender.tag] valueForKey:@"ID" ] integerValue];
    profileDetail.shouldNOTDisplayProfile = YES;
    [self.navigationController pushViewController:profileDetail animated:YES];

    
}

-(void)sendFreindRequestTapped: (UIButton *)sender
{
    //     http://socialmedia.alkurn.info/api-mobile/?function=add_friend&initiator_user_id=3&friend_user_id=65
    
    NSLog(@"%@",[self.filteredArray objectAtIndex:sender.tag] );
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Sending Request";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=add_friend&initiator_user_id=%zd&friend_user_id=%@", user.userID,[[self.filteredArray objectAtIndex:sender.tag] valueForKey:@"ID" ]] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
            if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", [[self.filteredArray objectAtIndex:sender.tag] valueForKey:@"user_email" ]];
                DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
                
                NSLog(@"%@", dbuser);
                
                
                NSMutableArray *oneSignalIds = [[NSMutableArray alloc] init];
                
                if ([dbuser.oneSignalId length] != 0)
                    [oneSignalIds addObject:dbuser.oneSignalId];
                
                NSLog(@"Push notification users are : %@", oneSignalIds);
                
                NSString *message = [NSString stringWithFormat:@"%@ sent you a freind request.", [[self.filteredArray objectAtIndex:sender.tag] valueForKey:@"fullname"]];
                
                [OneSignal postNotification:@{@"contents":@{@"en":message}, @"include_player_ids":oneSignalIds}];
                
                
                [[[UIAlertView alloc]initWithTitle:@"Sucessfully send friend reuest" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
                
            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Failed send friend reuest" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
            }
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
        });
        
    });
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString: @""]) {
        
        self.filteredArray = [[NSMutableArray alloc]init];
        [self.filteredArray removeAllObjects];
        [self.tableView reloadData];
        _nofreindsLabel.hidden = NO;

        
    }else{
        
        _nofreindsLabel.hidden = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"fullname", searchText];
        NSMutableArray *filteredList = [NSMutableArray arrayWithArray:[self.freindList filteredArrayUsingPredicate:predicate]];
        
        self.filteredArray = [[NSMutableArray alloc]init];
        self.filteredArray = filteredList;
        //[self.filteredArray addObject:filteredList];
        NSLog(@"%@", _filteredArray);
        
        [_tableView reloadData];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}




    
    @end
