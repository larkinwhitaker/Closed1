//
//  SettingsViewController.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"
#import "EditProfileViewController.h"
#import "ChangePasswordViewController.h"
#import "ContactDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "UIImageView+WebCache.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "ClosedResverResponce.h"
#import "UserDetails+CoreDataClass.h"
#import "MBProgressHUD.h"
#import "utilities.h"
#import "JobProfile+CoreDataProperties.h"
#import "RewardsViewController.h"
#import "EditFeedsViewController.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustumNavigationBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"NewFeedsAvilable" object:nil];

}

-(void)reloadTableData
{
    [self.tableView reloadData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadTableData];

    [self.navigationController setNavigationBarHidden:YES];
    
}

- (IBAction)myDealsButtonTapped:(id)sender {
    
    EditFeedsViewController *userfeedsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"EditFeedsViewController"];
    [self.navigationController pushViewController:userfeedsScreen animated:YES];
}


- (IBAction)claimrewardsPatted:(id)sender {
    
    RewardsViewController *rewardScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"RewardsViewController"];
    [self.navigationController pushViewController: rewardScreen animated:YES];

    
}
- (IBAction)changePasswordTapped:(id)sender {
    
    ChangePasswordViewController *changePassword = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    changePassword.userEmail = @"aasif.demo@gmail.com";
    [self.navigationController pushViewController:changePassword animated:YES];
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
    [navItem setTitle:@"Settings"];
    [self.view addSubview:navBar];
    
}

#pragma mark - TableView Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 600;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell"];
    
    [cell.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.editProfile addTarget:self action:@selector(editProfileTapped) forControlEvents:UIControlEventTouchUpInside];
    
    cell.userNameLabel.text = userDetails.firstName;
    
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:userDetails.profileImage] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
    return cell;
}


-(void)editProfileTapped
{
    EditProfileViewController *editProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    
    [self.navigationController pushViewController:editProfileVC animated:YES];
}


-(void)deleteButtonTapped
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to logout?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        [UserDetails MR_truncateAll];
        LogoutUser(DEL_ACCOUNT_ALL);
        [JobProfile MR_truncateAll];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
