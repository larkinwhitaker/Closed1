//
//  BlockuserListViewController.m
//  Closed1
//
//  Created by Nazim on 10/01/18.
//  Copyright © 2018 Alkurn. All rights reserved.
//

#import "BlockuserListViewController.h"
#import "MBProgressHUD.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "ClosedResverResponce.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "CommonFunction.h"

@interface BlockuserListViewController () <UITableViewDelegate , UITableViewDataSource>

@property(nonatomic) NSMutableArray *blockeduserListArray;

@end

@implementation BlockuserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.blockeduserListArray = [[NSMutableArray alloc] init];
    [self getBlockedFreindListFromServer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController configureNavigationBar:self];
    self.navigationItem.titleView = [CommonFunction createNavigationView:@"Blocked users" withView:self.view];
}

-(void)backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)getBlockedFreindListFromServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Please wait..";
    hud.detailsLabelText = @"Getting list";
    
    UserDetails *user = [UserDetails MR_findFirst];

    NSString *apiName = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=unblock_user&initiator_user_id&friend_user_id=%zd", user.userID];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverresponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:apiName DictionartyToServer:@{} IsEncodingRequires:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        });
        
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.blockeduserListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BlockedUserListCell"];
    
    UILabel *userNameLabel = (UILabel *)[cell viewWithTag: 1];
    userNameLabel.text = [[self.blockeduserListArray objectAtIndex:indexPath.row] valueForKey:@""];
    
    return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to Unblock this user?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction: [UIAlertAction actionWithTitle:@"Yws" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [self callApiForUnblockingUser:indexPath.row];
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)callApiForUnblockingUser: (NSInteger )indexofuser
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Please wait..";
    hud.detailsLabelText = @"Unblocking user";
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *apiName = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=unblock_user&initiator_user_id=%@&friend_user_id=%zd", [[self.blockeduserListArray objectAtIndex:indexofuser] valueForKey:@"ID"], user.userID];
        
        NSArray *serverresponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:apiName DictionartyToServer:@{} IsEncodingRequires:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            
            if (![[serverresponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                
                if ([[serverresponce valueForKey:@"success"] integerValue] == 1) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BlockingUserNotification" object:nil];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You have sucessfully Unblocked the user" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }]];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                }else{
                    
                    [[[UIAlertView alloc]initWithTitle:@"Failed to UnBlock the user" message:@"Currently we are unable to process you request. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
                
            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Failed to UnBlock the user" message:@"Currently we are unable to process you request. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
            
            
        });
        
        
        
    });
    
}

@end
