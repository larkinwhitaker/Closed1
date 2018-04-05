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
#import "InappPurchaseTermViewController.h"
#import "TabBarHandler.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"NewFeedsAvilable" object:nil];

}

-(void)reloadTableData
{
    [self.tableView reloadData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    TabBarHandler *tabBarHandler = (TabBarHandler *)self.tabBarController;
    [tabBarHandler.navigationController setNavigationBarHidden:YES animated:NO];
//    [tabBarHandler.navigationController configureNavigationBar:self];
//    tabBarHandler.title = @"Settings";
//    tabBarHandler.navigationItem.hidesBackButton = YES;
//    tabBarHandler.navigationItem.leftBarButtonItem = nil;

    [self reloadTableData];
}

- (IBAction)myDealsButtonTapped:(id)sender {
    
    EditFeedsViewController *userfeedsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"EditFeedsViewController"];
    [self.navigationController pushViewController:userfeedsScreen animated:YES];
}
- (IBAction)inappPurchasetermButtonTapped:(id)sender {
    
    InappPurchaseTermViewController *userfeedsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"InappPurchaseTermViewController"];
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

#pragma mark - TableView Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 640;
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
