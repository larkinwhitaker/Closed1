//
//  RewardsViewController.m
//  Closed1
//
//  Created by Nazim on 15/10/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "RewardsViewController.h"
#import "UserDetails+CoreDataClass.h"
#import "MBProgressHUD.h"
#import "MagicalRecord.h"
#import "ClosedResverResponce.h"
#import "UINavigationController+NavigationBarAttribute.h"

@interface RewardsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *rewardsLabel;
@property (weak, nonatomic) IBOutlet UIButton *claimrewardButton;

@end

@implementation RewardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.claimrewardButton.layer.cornerRadius = 5.0f;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getRewardsDetailsfromServer)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
//    [self createCustumNavigationBar];
    [self getRewardsDetailsfromServer];
    self.claimrewardButton.hidden = YES;
    
    [self.navigationController configureNavigationBar:self];
}
- (IBAction)claimRewardtapped:(id)sender {
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Claiming Reward";
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *apiName = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=claim_reward&user_id=%zd&reward=1", user.userID];
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:apiName DictionartyToServer:@{} IsEncodingRequires:nil];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if(![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]){
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    [[[UIAlertView alloc]initWithTitle:[serverResponce valueForKey:@"message"] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    
                }else{
                    [[[UIAlertView alloc]initWithTitle:@"Failed to get Rewards Details" message:@"Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
            }else{
                [[[UIAlertView alloc]initWithTitle:@"Failed to get Rewards Details" message:@"Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
        });
        
    });
    
}

-(void)getRewardsDetailsfromServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Getting Rewards";
    
    UserDetails *user = [UserDetails MR_findFirst];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *apiName = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=claim_reward&user_id=%zd", user.userID];
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:apiName DictionartyToServer:@{} IsEncodingRequires:nil];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if(![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]){
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    if (![[serverResponce valueForKey:@"message"] isEqual:[NSNull null]]) {
                        
                        self.rewardsLabel.text = [serverResponce valueForKey:@"message"];
                        [self.navigationItem.rightBarButtonItem setEnabled:YES];

                        if ([[serverResponce valueForKey:@"count"] integerValue] > 2) {
                            
                            self.claimrewardButton.hidden = NO;
                        }else{
                            self.claimrewardButton.hidden = YES;
                        }
                        
                    }else{
                        
                        [[[UIAlertView alloc]initWithTitle:@"Failed to get Rewards Details" message:@"Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    }
                }else{
                    [[[UIAlertView alloc]initWithTitle:@"Failed to get Rewards Details" message:@"Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
            }else{
                [[[UIAlertView alloc]initWithTitle:@"Failed to get Rewards Details" message:@"Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
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
    [navItem setTitle:@"Rewards"];
    [self.view addSubview:navBar];
    
}

-(void) backButtonTapped: (id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
