//
//  LoginViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "LoginViewController.h"
#import "JVFloatLabeledTextField.h"
#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "TabBarHandler.h"
#import "ClosedResverResponce.h"
#import "ChangePasswordViewController.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "AFNetworking.h"
#import <linkedin-sdk/LISDK.h>
#import "JobProfile+CoreDataProperties.h"

#define kTitle @"title"
#define kCopmpany @"company"
#define kTerritory @"territory"
#define kTargetBuyers @"target"
#define kisCurrentPosition @"current_position"

@interface LoginViewController ()<LinkedInLoginDelegate,ServerFailedDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *linkedinButton;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *emailtextField;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *passwordTextField;
@property(atomic) NSString *acessToken;
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property(nonatomic) NSString *imageURL;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"FreindRequestCount"];
#pragma mark - Remove Code
    
//    [UserDetails MR_truncateAll];
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    _imageURL = @"";
    self.loginView.layer.cornerRadius = 5;
    UIBezierPath *shadowPath = [UIBezierPath
                                bezierPathWithRoundedRect: self.loginView.bounds
                                cornerRadius: 5];
    
    
    self.loginView.layer.masksToBounds = false;
    self.loginView.layer.shadowColor = [[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0] CGColor];
    self.loginView.layer.shadowOffset = CGSizeMake(-3, 3);
    self.loginView.layer.shadowOpacity = 0.5;
    self.loginView.layer.shadowPath = shadowPath.CGPath;
    
  [self.navigationController setNavigationBarHidden:YES];
    
    [self checkUserLoginStataus];
    
#pragma mark - Demo Login Code
//    NSArray *userData = @[@{@"success":[NSNumber numberWithInteger:1],@"data":@{@"ID":[NSNumber numberWithInteger:4],@"user_login":@"muzammil",@"user_email":@"muzammil.alkurn@gmail.com",@"first_name":@"Muzammil",@"last_name":@"Alkurn",@"title":@"HTML Developer",@"company":@"Alkurn Technologies",@"city":@"Nagpur",@"country":@"India",@"territory ":@"Nagpur",@"fullname":@"Muzammil Alkurn",@"secondary @email":@"muza@rediffmail.com",@"profile Image":@"http://0.gravatar.com/avatar/62b33a60cd80b124ce316743f333a25d?s=96&d=mm&r=g"}}];
    
//    [self saveUserDetails:[userData firstObject]];
    
}

-(void)checkUserLoginStataus
{
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    if (userDetails.userEmail != nil) [self openHomeScreen];
}

- (IBAction)loginViaLinkedIn:(id)sender {
    
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.isLinkedinSelected = YES;
    webView.delegate = self;
    [self.navigationController pushViewController:webView animated:YES];
    
    /*
    [LISDKSessionManager createSessionWithAuth:[NSArray arrayWithObjects:LISDK_BASIC_PROFILE_PERMISSION, LISDK_EMAILADDRESS_PERMISSION, nil]
state:@"some state"
showGoToAppStoreDialog:YES
successBlock:^(NSString *returnState) {
    
    NSLog(@"%s","success called!");
    LISDKSession *session = [[LISDKSessionManager sharedInstance] session];
    NSLog(@"value=%@ isvalid=%@",[session value],[session isValid] ? @"YES" : @"NO");
    NSMutableString *text = [[NSMutableString alloc] initWithString:[session.accessToken description]];
    [text appendString:[NSString stringWithFormat:@",state=\"%@\"",returnState]];
    NSLog(@"Response label text %@",text);
//    _responseLabel.text = text;
//    self.lastError = nil;
    // retain cycle here?
//    [self updateControlsWithResponseLabel:NO];
    
}
errorBlock:^(NSError *error) {
    NSLog(@"%s %@","error called! ", [error description]);
//    self.lastError = error;
    //  _responseLabel.text = [error description];
//    [self updateControlsWithResponseLabel:YES];
}
    ];
    
    */
    
}


- (IBAction)loginbButtonTapped:(id)sender {
    
    
    [self.view endEditing:YES];
    
    if ([[self.emailtextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_emailtextField];
        
    }else if ([[self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        
        [self animateView:self.passwordTextField];
    }else{
            [self submitDataToServer];
    }
    
    
}
- (IBAction)forgotPasswordTapped:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([[self.emailtextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        
        [self animateView:self.emailtextField];
    }else{
        
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Fetching Details";
    hud.dimBackground = YES;
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [ClosedResverResponce sharedInstance].delegate = self;
            NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=forgotPassword&email=%@", self.emailtextField.text] DictionartyToServer:@{} IsEncodingRequires:NO];
            
            NSLog(@"%@", serverResponce);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (serverResponce != nil) {
                    
                    if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                        
                        if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                            
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            self.emailtextField.text = @"";
                            self.passwordTextField.text = @"";
                            
                            ChangePasswordViewController *changePasswordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
                            
                            changePasswordVC.userEmail = self.emailtextField.text;
                            [self.navigationController pushViewController:changePasswordVC animated:YES];
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
    
}

-(void)submitDataToServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Loggin you in";
    [ClosedResverResponce sharedInstance].delegate= self;
    
    NSString *apiName = [NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=getLogin&username=%@&password=%@", _emailtextField.text, _passwordTextField.text];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer: apiName DictionartyToServer:@{} IsEncodingRequires:NO];
    
    NSLog(@"%@", serverResponce);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (serverResponce != nil) {
            
            if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    [self saveUserDetails:serverResponce];
                    [self openHomeScreen];
                    
                }else{
                    [self serverFailedWithTitle:@"Login Failed" SubtitleString:@"Please check your email and password."];

                }
                
            }else{
                [self serverFailedWithTitle:@"Login Failed" SubtitleString:@"Please check your email and password."];

            }
        }else{
            
            [self serverFailedWithTitle:@"Login Failed" SubtitleString:@"Please check your email and password."];
        }
    });
    
    });
    
    
}

-(void)openHomeScreen
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.emailtextField.text = @"";
    self.passwordTextField.text = @"";
    
    
    TabBarHandler *tabBarScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarHandler"];
    
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.navigationController pushViewController:tabBarScreen animated:NO];
                    }
                    completion:nil];
    
    [self getFreindListCount];
    
    [self getUpdatedUserDetails];
    
}


-(void)getUpdatedUserDetails
{
    UserDetails *_userdDetails = [UserDetails MR_findFirst];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=get_profile_data&user_id=%zd", _userdDetails.userID] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        if (serverResponce != nil) {
            
            if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{

                    [self saveData:serverResponce];
                    });
                    
                }
            }
        }
            });
}

-(void)getFreindListCount
{
    
    UserDetails *_userdDetails = [UserDetails MR_findFirst];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *servreResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=get_friends_request&user_id=%zd",_userdDetails.userID] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", servreResponce);
        
                if ([servreResponce valueForKey:@"success"] != nil) {
                
                if ([[servreResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    NSArray *freinListCOunt = [servreResponce valueForKey:@"data"];
                    [[NSUserDefaults standardUserDefaults] setInteger:freinListCOunt.count forKey:@"FreindRequestCount"];
                }
            }
        });

}


-(void)saveData: (NSArray *)userData
{
    
    
    userData = [userData valueForKey:@"data"];
    [UserDetails MR_truncateAll];
    [JobProfile MR_truncateAll];

    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        UserDetails *userDetails = [UserDetails MR_createEntityInContext:localContext];
        
        userDetails.userID = [[userData valueForKey:@"ID"] integerValue];
        userDetails.firstName = [userData valueForKey:@"fullname"];
        userDetails.userEmail = [userData valueForKey:@"user_email"];
        userDetails.userLogin = [userData valueForKey:@"user_login"];
        userDetails.title = [userData valueForKey:@"title"];
        userDetails.company = [userData valueForKey:@"company"];
        userDetails.city = [userData valueForKey:@"city"];
        userDetails.country = [userData valueForKey:@"country"];
        userDetails.territory = [userData valueForKey:@"territory"];
        userDetails.econdaryemail = [userData valueForKey:@"secondary email"];
        userDetails.phoneNumber = [userData valueForKey:@"phone"];
        userDetails.profileImage = [userData valueForKey:@"profile_image_url"];
        
        
        
        
        NSArray *flightDetailsArray = [userData valueForKey:@"profile_job"];
        
        if (flightDetailsArray.count != 0) {
            
            for (NSDictionary *singleJob in flightDetailsArray) {
                
                JobProfile *jobDetails = [JobProfile MR_createEntityInContext:localContext];
                
                jobDetails.title = [singleJob valueForKey:kTitle];
                jobDetails.territory = [singleJob valueForKey:kTerritory];
                jobDetails.compnay = [singleJob valueForKey:kCopmpany];
                jobDetails.targetBuyers = [singleJob valueForKey:kTargetBuyers];
                if (![[singleJob valueForKey:kisCurrentPosition] isEqual:[NSNull null]]) {
                    
                    jobDetails.currentPoistion = [singleJob valueForKey:kisCurrentPosition];
                }
                
                [localContext MR_saveToPersistentStoreAndWait];
                
                
            }
        }
        
        
        
        
        [localContext MR_saveToPersistentStoreAndWait];
        
    }completion:^(BOOL didSave, NSError *error){
        
        if (!didSave) {
            
            NSLog(@"Error While Saving: %@", error);
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }];
    
}


-(void)saveUserDetails: (NSArray *)userData{
    
    userData = [userData valueForKey:@"data"];
    [UserDetails MR_truncateAll];
    [JobProfile MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        UserDetails *userDetails = [UserDetails MR_createEntityInContext:localContext];
        
        userDetails.userID = [[userData valueForKey:@"ID"] integerValue];
        userDetails.firstName = [userData valueForKey:@"fullname"];
        userDetails.userEmail = [userData valueForKey:@"user_email"];
        userDetails.userLogin = [userData valueForKey:@"user_login"];
        userDetails.title = [userData valueForKey:@"title"];
        userDetails.company = [userData valueForKey:@"company"];
        userDetails.city = [userData valueForKey:@"city"];
        userDetails.country = [userData valueForKey:@"country"];
        userDetails.territory = [userData valueForKey:@"territory"];
        userDetails.econdaryemail = [userData valueForKey:@"secondary email"];
        userDetails.phoneNumber = [userData valueForKey:@"phone"];
        
        if ([[userData valueForKey:@"profile Image"] isEqualToString:@""]) {
            
            userDetails.profileImage = _imageURL;


        }else{
         
            userDetails.profileImage = [userData valueForKey:@"profile Image"];

        }
        
        
        NSArray *flightDetailsArray = [userData valueForKey:@"profile_job"];
        
        if (flightDetailsArray.count != 0) {
            
            for (NSDictionary *singleJob in flightDetailsArray) {
                
                JobProfile *jobDetails = [JobProfile MR_createEntityInContext:localContext];
                
                jobDetails.title = [singleJob valueForKey:kTitle];
                jobDetails.territory = [singleJob valueForKey:kTerritory];
                jobDetails.compnay = [singleJob valueForKey:kCopmpany];
                jobDetails.targetBuyers = [singleJob valueForKey:kTargetBuyers];
                if (![[singleJob valueForKey:kisCurrentPosition] isEqual:[NSNull null]]) {
                    
                    jobDetails.currentPoistion = [singleJob valueForKey:kisCurrentPosition];
                }
                
                [localContext MR_saveToPersistentStoreAndWait];
                
                
            }
        }
        
        
        
        
        [localContext MR_saveToPersistentStoreAndWait];
        
    }completion:^(BOOL didSave, NSError *error){
       
        if (!didSave) {
            
            NSLog(@"Error While Saving: %@", error);
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }];
   
}


-(void)animateView: (JVFloatLabeledTextField *)textField
{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.07;
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x - 10, textField.center.y)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x + 10, textField.center.y)];
    [textField.layer addAnimation:animation forKey:@"position"];
    
}


#pragma mark - Linked Login Sucess Delegate

-(void)linkedInAcessToken:(NSString *)acessToken
{
    
    if (acessToken != nil) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        NSString *acessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"LIAccessToken"];
        
        // Specify the URL string that we'll get the profile info from.
        NSString *targetURLString = [NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,maiden-name,email-address,picture-url,headline)?oauth2_access_token=%@&format=json", acessToken] ;
        
        // Initialize a mutable URL request object.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:targetURLString]];
        
        // Indicate that this is a GET request.
        request.HTTPMethod = @"GET";
        
        // Add the access token as an HTTP header field.
//        [request addValue:[NSString stringWithFormat:@"Bearer %@",acessToken] forHTTPHeaderField:@"Authorization"];
        
        NSURLSession *seesion = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDataTask *task = [seesion dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *responce,NSError *error){
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
            
            if (httpResponse.statusCode == 200) {
            
                NSArray * arrayOfDictionaryFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                NSLog(@"%@", arrayOfDictionaryFromServer);
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self submitDataViaLinkedIn:[arrayOfDictionaryFromServer valueForKey:@"emailAddress"] withImageURl:[arrayOfDictionaryFromServer valueForKey:@"pictureUrl"]];
                    _imageURL = [arrayOfDictionaryFromServer valueForKey:@"pictureUrl"];
                    
                });
            }
            
        }];
        
        [task resume];
        
    
        
        
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"oopss!!" message:@"Failed to login with linkedin. Please try again or login manually" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }
}


#pragma mark - Server Failed Delegates

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
 
    dispatch_async(dispatch_get_main_queue(), ^{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    });
}

-(void)submitDataViaLinkedIn: (NSString *)email withImageURl: (NSString *)imageURL
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Loggin you in";
    [ClosedResverResponce sharedInstance].delegate= self;
    
    NSString *apiName = [NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=linkedinlogin&email=%@&device_id=%@&user_avatar_urls=%@", email, @"123", imageURL];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer: apiName DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (serverResponce != nil) {
                
                if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                    
                    if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                        
                        [self saveUserDetails:serverResponce];
                        [self openHomeScreen];
                        
                    }else{
                        [self serverFailedWithTitle:@"Login Failed" SubtitleString:@"Please check your email and password."];
                        
                    }
                    
                }else{
                    [self serverFailedWithTitle:@"Login Failed" SubtitleString:@"Please check your email and password."];
                    
                }
            }else{
                
                [self serverFailedWithTitle:@"Login Failed" SubtitleString:@"Please check your email and password."];
            }
        });
        
    });

}

-(void)textFieldDidEndEditing:(JVFloatLabeledTextField *)textField
{
   
}

-(BOOL)textFieldShouldReturn:(JVFloatLabeledTextField *)textField
{
    if (textField == self.passwordTextField) {
        
        [self loginbButtonTapped:nil];
    }
    
    return YES;
}


@end
