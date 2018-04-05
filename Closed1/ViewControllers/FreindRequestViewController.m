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
#import "ContactDetails+CoreDataProperties.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "ChatsView.h"
#import "ChatView.h"

@interface FreindRequestViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic) NSArray *friendListArray;
@property(nonatomic) UserDetails *userdDetails;

@end

@implementation FreindRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userdDetails = [UserDetails MR_findFirst];
    [self.navigationController configureNavigationBar:self];
    self.title = @"Friend Requests";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackButton"] style: UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    [self getFreindList];
}

-(void)backButtonTapped: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getFreindList
{
    
    _friendListArray = [[NSArray alloc]init];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Getting List";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *servreResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=get_friends_request&user_id=%zd",_userdDetails.userID] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", servreResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if ([servreResponce valueForKey:@"success"] != nil) {
                
                if ([[servreResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    self.friendListArray = [servreResponce valueForKey:@"data"];
                    [[NSUserDefaults standardUserDefaults] setInteger:self.friendListArray.count forKey:@"FreindRequestCount"];
                    [self.tableView reloadData];
                }else{
                    
                    [[[UIAlertView alloc]initWithTitle:@"Sorry! No friend request found." message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"FreindRequestCount"];

                }
            }
            
        });
        
    });
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
        
        NSString *url = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=accept_friend_request&request_id=%@", [[[[self.friendListArray objectAtIndex:sender.tag] valueForKey:@"accept_link"] firstObject] valueForKey:@"id"]];
        NSLog(@"%@", url);
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer: url DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            
            NSDictionary *entity = [self.friendListArray objectAtIndex:sender.tag];
            
            NSString *userID = [entity valueForKey:@"user_id"];
            
            NSString *url = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=get_profile_data&user_id=%@", userID];
            
            NSLog(@"%@", url);
            
            NSArray *responceDict = [[ClosedResverResponce sharedInstance] getResponceFromServer: url DictionartyToServer:@{} IsEncodingRequires:NO];
            
            
            
            
            if (![[responceDict valueForKey:@"success"] isEqual:[NSNull null]]) {
                
                if ([[responceDict valueForKey:@"success"] integerValue] == 1) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        
                        if ([[serverResponce valueForKey:@"sucess"] integerValue] == 1) {
                            
                            
                            NSString *userEmail = [[responceDict valueForKey:@"data"] valueForKey:@"user_email"];
                            
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", userEmail];
                            DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
                            
                            NSLog(@"%@", dbuser);
                            
                            
                            NSMutableArray *oneSignalIds = [[NSMutableArray alloc] init];
                            
                            if ([dbuser.oneSignalId length] != 0)
                                [oneSignalIds addObject:dbuser.oneSignalId];
                            
                            NSLog(@"Push notification users are : %@", oneSignalIds);
                            
                            NSString *fullName = self.userdDetails.firstName;
                            
                            
                            NSString *message = [NSString stringWithFormat:@"%@ has accepted your friend request.", fullName];
                            
                            [OneSignal postNotification:@{@"contents":@{@"en":message}, @"include_player_ids":oneSignalIds}];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                            [self.delegate freindListAddedSucessFully];
                            
                        }else{
                            
                            [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:[serverResponce valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
                        }
                        
                    });
                    
                }else{
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        
                        if ([[serverResponce valueForKey:@"sucess"] integerValue] == 1) {
                            
                            [self.navigationController popViewControllerAnimated:YES];
                            [self.delegate freindListAddedSucessFully];
                        }else{
                            
                            [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:[serverResponce valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
                            
                        }
                        
                    });
                }
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                    if ([[serverResponce valueForKey:@"sucess"] integerValue] == 1) {
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        [self.delegate freindListAddedSucessFully];
                    }else{
                        
                        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:[serverResponce valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
                        
                    }
                });
            }
            
        });
        

            
        
       
    });
    
}

-(void)rejectButtonTapped: (UIButton *)sender
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Rejecting..";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=reject_friend_request&request_id=%@", [[[[self.friendListArray objectAtIndex:sender.tag] valueForKey:@"reject_link"] firstObject] valueForKey:@"id"]] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if ([[serverResponce valueForKey:@"sucess"] integerValue] == 1) {
                
                [self getFreindList];
                
            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:[serverResponce valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
            }
        });
        
    });
    
}



@end
