//
//  FreindRequestViewController.m
//  Closed1
//
//  Created by Nazim on 20/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "FreindRequestViewController.h"
#import "FreindsCell.h"
#import "MBProgressHUD.h"
#import "UserDetails+CoreDataClass.h"
#import "ClosedResverResponce.h"
#import "MagicalRecord.h"
#import "UIImageView+WebCache.h"



@interface FreindRequestViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic) NSArray *friendListArray;
@property(nonatomic) UserDetails *userdDetails;

@end

@implementation FreindRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCustumNavigationBar];
    
    _userdDetails = [UserDetails MR_findFirst];
    
    _friendListArray = [[NSArray alloc]init];
    NSArray *arrayOfContacts = [self getDataFromLocalJSONFileForEntity:@"Contacts"];
    _friendListArray = [arrayOfContacts valueForKey:@"data"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting List";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray *servreResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=get_friends_request&user_id=%zd",_userdDetails.userID] DictionartyToServer:@{}];
        
        NSLog(@"%@", servreResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
    
    navItem.leftBarButtonItem = backButton;
    
    
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Friend Requests"];
    [self.view addSubview:navBar];
    
}

-(void)backButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSArray *)getDataFromLocalJSONFileForEntity:(NSString *)entityName
{
    NSString * filePath = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@",entityName] ofType:@"json"];
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataFromlLocal = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    return dataFromlLocal;
}


#pragma mark - TablevIew Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friendListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FreindsCell *freindCell = [tableView dequeueReusableCellWithIdentifier:@"FreindsCell"];
    
    [freindCell.profileImage sd_setImageWithURL:[NSURL URLWithString:[[_friendListArray objectAtIndex:indexPath.row] valueForKey:@"profile_image_url"]] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
    freindCell.nameLabel.text = [[_friendListArray objectAtIndex:indexPath.row] valueForKey:@"contact"];
    freindCell.companyLabel.text = [[_friendListArray objectAtIndex:indexPath.row] valueForKey:@"company"];
    freindCell.titleNameLabel.text = [[_friendListArray objectAtIndex:indexPath.row] valueForKey:@"title"];
    
    freindCell.acceptButton.tag = indexPath.row;
    freindCell.rejectButton.tag = indexPath.row;
    
    [freindCell.acceptButton addTarget:self action:@selector(acceptButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [freindCell.rejectButton addTarget:self action:@selector(rejectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return freindCell;
}

-(void)acceptButtonTapped: (UIButton *)sender
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Accepting..";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=accept_friend_request&request_id=%zd", [[[self.friendListArray objectAtIndex:sender.tag] valueForKey:@""] integerValue]] DictionartyToServer:@{}];
        
        NSLog(@"%@", serverResponce);
        
        
        NSArray *freindResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=add_friend&initiator_user_id=%zd&friend_user_id=%zd", self.userdDetails.userID, [[serverResponce valueForKey:@""] integerValue]] DictionartyToServer:@{}];
        
        NSLog(@"%@", freindResponce);
        
        if ([freindResponce valueForKey:@""]) {
            
            [self.delegate freindListAddedSucessFully];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        
    });
    
}

-(void)rejectButtonTapped: (UIButton *)sender
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Rejecting..";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=reject_friend_request&request_id=%zd", [[[self.friendListArray objectAtIndex:sender.tag] valueForKey:@""] integerValue]] DictionartyToServer:@{}];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        
    });
    
}



@end
