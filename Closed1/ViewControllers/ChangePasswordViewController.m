//
//  ChangePasswordViewController.m
//  Closed1
//
//  Created by Nazim on 01/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "ClosedResverResponce.h"
#import "MBProgressHUD.h"
#import "ClosedResverResponce.h"
#import "UserDetails+CoreDataClass.h"
#import "MBProgressHUD.h"
#import "MagicalRecord.h"
#import "utilities.h"


@interface ChangePasswordViewController ()<ServerFailedDelegate>

@property (strong, nonatomic) IBOutlet UIView *changePasswordView;
@property (strong, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *updatedPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deleteButton.layer.borderWidth = 2.0f;
    self.deleteButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.deleteButton.layer.cornerRadius = 5.0f;
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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    
    navItem.leftBarButtonItem = backButton;
    
    
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Change Password"];
    [self.view addSubview:navBar];
    
}
-(IBAction)backButtonTapped:(UIBarButtonItem *)sender

{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)deleteTapped:(id)sender {
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete?" message:@"Deleting your account will delete all of the content you have created. It will be completely irrecoverable." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.dimBackground = YES;
        hud.labelText = @"Deleting..";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *responce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=deleteUser&ID=%zd", userDetails.userID] DictionartyToServer:@{} IsEncodingRequires:NO];
            
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

-(void)setAnimatingView: (UIView *)viewToAnimate
{
    viewToAnimate.layer.cornerRadius = 5.0f;
    viewToAnimate.layer.shadowOffset = CGSizeMake(-3, 3);
    viewToAnimate.layer.shadowColor = [UIColor colorWithRed:223/255.0 green:224/255.0 blue:223/255.0 alpha:1.0].CGColor;
    viewToAnimate.layer.shadowRadius = 1.0;
    viewToAnimate.layer.shadowOpacity = 0.5;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)changePasswordTapped:(id)sender {
    
    if ([[self.currentPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        
        [self animateTextField: self.currentPasswordTextField];
        
    }else if ([[self.updatedPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0){
        
        [self animateTextField:self.updatedPasswordTextField];
        
    }else if ([[self.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0){
        
        [self animateTextField:self.currentPasswordTextField];
        
    }else if (![self.confirmPasswordTextField.text isEqualToString:self.updatedPasswordTextField.text]){
        
        [[[UIAlertView alloc]initWithTitle:@"Passwords don't match" message:@"Please enter the same passwords" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }else if (self.currentPasswordTextField.text == self.updatedPasswordTextField.text) {
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"New password and old password must be different" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }else{
        
        [self submitDataToServer:nil];
        
    }
}

-(void)submitDataToServer:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Changing Password";
    hud.dimBackground = YES;
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=setNewPassword&email=%@&password=%@",_userEmail, self.confirmPasswordTextField.text] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            if (serverResponce != nil) {
                
                if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                    
                    if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                        
                        
                        UIAlertController *alertCobtroller = [UIAlertController alertControllerWithTitle:@"Password changed successfully" message:@"You have successfully change password. Please login again" preferredStyle:UIAlertControllerStyleAlert];
                        
                        [alertCobtroller addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                            
                            [self.navigationController popToRootViewControllerAnimated:YES];
                            
                        }]];
                        
                        [self presentViewController:alertCobtroller animated:YES completion:nil];
                        
                        
                    }else{
                        [self serverFailedWithTitle:@"Failed to Identify it's you" SubtitleString:@"Sorry we are unable to identify you please try again later or check your email ID."];
                    }
                }else{
                    [self serverFailedWithTitle:@"Failed to Identify it's you" SubtitleString:@"Sorry we are unable to identify you please try again later or check your email ID."];
                }
            }
        });
        
        
    });
    
}


-(void)animateTextField: (UITextField *) textField
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.07;
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x - 10, textField.center.y)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x + 10, textField.center.y)];
    [textField.layer addAnimation:animation forKey:@"position"];
    
}

#pragma mark - Server Failed Delegate

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    });
}
@end
