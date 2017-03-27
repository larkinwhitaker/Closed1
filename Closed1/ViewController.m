//
//  ViewController.m
//  Closed1
//
//  Created by Nazim on 25/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ViewController.h"
#import <linkedin-sdk/LISDK.h>

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *btnSignIn;
@property (strong, nonatomic) IBOutlet UIButton *btnGetProfileInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnOpenProfile;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _btnSignIn.enabled = true;
    _btnGetProfileInfo.enabled = false;
    _btnOpenProfile.hidden = true;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkForExistingAccessToken];
}

-(void)checkForExistingAccessToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LIAccessToken"] != nil) {
        
        _btnSignIn.enabled = false;
        _btnGetProfileInfo.enabled = true;
        
    }
}
- (IBAction)getProfileInfo:(id)sender {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LIAccessToken"]) {
        
        NSString *acessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"LIAccessToken"];
        
        // Specify the URL string that we'll get the profile info from.
        NSString *targetURLString = @"https://api.linkedin.com/v1/people/~:(public-profile-url)?format=json";
        
        // Initialize a mutable URL request object.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:targetURLString]];
        
        // Indicate that this is a GET request.
        request.HTTPMethod = @"GET";
        
        // Add the access token as an HTTP header field.
        [request addValue:[NSString stringWithFormat:@"Bearer %@",acessToken] forHTTPHeaderField:@"Authorization"];
        
        NSURLSession *seesion = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDataTask *task = [seesion dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *responce,NSError *error){
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
            
            if (httpResponse.statusCode == 200) {
                
                NSArray * arrayOfDictionaryFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                NSLog(@"%@", arrayOfDictionaryFromServer);
                

                
                
            }
            
        }];
        
        [task resume];
    
    }
        

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
