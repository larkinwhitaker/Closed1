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

@interface AddFreindsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic) NSMutableArray *freindList;
@end

@implementation AddFreindsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getFreindListFromServer];
}

-(void)getFreindListFromServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting List";
    self.tableView.allowsSelection = NO;
    
    
    NSString *URL = [NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=getallmembers"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer: URL DictionartyToServer:@{}];
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
               
                self.freindList = [serverResponce valueForKey:@"data"];
                [self.tableView reloadData];
                
                
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
    return _freindList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddFreindsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFreindsCell"];
    cell.sendrequest.tag = indexPath.row;
    cell.userName.text = [[self.freindList objectAtIndex:indexPath.row] valueForKey:@"fullname"];
    [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[[self.freindList objectAtIndex:indexPath.row] valueForKey:@"profile_image_url"]] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    [cell.sendrequest addTarget:self action:@selector(sendFreindRequestTapped:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}


-(void)sendFreindRequestTapped: (UIButton *)sender
{
//     http://socialmedia.alkurn.info/api-mobile/?function=add_friend&initiator_user_id=3&friend_user_id=65
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Sending Request";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=add_friend&initiator_user_id=%@&friend_user_id=%zd", [[self.freindList objectAtIndex:sender.tag] valueForKey:@"ID" ], user.userID] DictionartyToServer:@{}];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
    
        
        if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
            
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", [[self.freindList objectAtIndex:sender.tag] valueForKey:@"user_email" ]];
            DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
            
            NSLog(@"%@", dbuser);
            
            
            NSMutableArray *oneSignalIds = [[NSMutableArray alloc] init];
            
            if ([dbuser.oneSignalId length] != 0)
                [oneSignalIds addObject:dbuser.oneSignalId];
            
            NSLog(@"Push notification users are : %@", oneSignalIds);
            
            NSString *message = [NSString stringWithFormat:@"%@ sent you a freind request.", [[self.freindList objectAtIndex:sender.tag] valueForKey:@"fullname"]];
            
            [OneSignal postNotification:@{@"contents":@{@"en":message}, @"include_player_ids":oneSignalIds}];
            
            
            [[[UIAlertView alloc]initWithTitle:@"Sucessfully send freind reuest" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
            
        }else{
            
            [[[UIAlertView alloc]initWithTitle:@"Failed send freind reuest" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
        });
        
    });
}



@end
