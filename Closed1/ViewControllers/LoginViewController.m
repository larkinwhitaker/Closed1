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


@interface LoginViewController ()<LinkedInLoginDelegate>
@property (strong, nonatomic) IBOutlet UIButton *linkedinButton;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *emailtextField;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *passwordTextField;
@property(atomic) NSString *acessToken;
@property (strong, nonatomic) IBOutlet UIView *loginView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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

    
    [self openHomeScreen];
    
    
    
    
    
        
}



- (IBAction)loginViaLinkedIn:(id)sender {
    
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.delegate = self;
    //[self presentViewController:webView animated:YES completion:nil];
    
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
    
}

-(void)submitDataToServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Loggin you in";
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(openHomeScreen) userInfo:nil repeats:NO];
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
        NSString *targetURLString = [NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,maiden-name,email-address)?oauth2_access_token=%@&format=json", acessToken] ;
        
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
                    
                    [self submitDataToServer];
                    
                });
            }
            
        }];
        
        [task resume];
        
    
        
        
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"oopss!!" message:@"Failed to login with linkedin. Please try again or login manually" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }
}

@end
