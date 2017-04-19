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


@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustumNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

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
    [navBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]];
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
    return 454;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell"];
    [cell.emailButton addTarget:self action:@selector(emaiButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.gemeralButton addTarget:self action:@selector(openGeneralView) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.profileButton addTarget:self action:@selector(profileVisibility) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.editProfile addTarget:self action:@selector(editProfileTapped) forControlEvents:UIControlEventTouchUpInside];
    
    cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", userDetails.firstName, userDetails.lastName];
    
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:userDetails.profileImage] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
    return cell;
}


-(void)editProfileTapped
{
    EditProfileViewController *editProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    
    [self.navigationController pushViewController:editProfileVC animated:YES];
}

-(void)openGeneralView
{
    
}

-(void)emaiButtonTapped
{
    
}

-(void)profileVisibility
{
    
}

-(void)deleteButtonTapped
{
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete?" message:@"Deleting your account will delete all of the content you have created. It will be completely irrecoverable." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.dimBackground = YES;
        hud.labelText = @"Deleting..";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *responce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=deleteUser&ID=%zd", userDetails.userID] DictionartyToServer:@{}];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if ([[responce valueForKey:@"success"] integerValue] == 1) {
                    
                    [UserDetails MR_truncateAll];
                    LogoutUser(DEL_ACCOUNT_ALL);

                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                }else{
                    
                    [[[UIAlertView alloc]initWithTitle:@"Failed to Delete Profile" message:@"We are getting some issu while deleting your profile. Please try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
                }
                
               

            });
        });
        
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
