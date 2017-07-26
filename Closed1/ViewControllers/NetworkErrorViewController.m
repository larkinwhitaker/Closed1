
//
//  NetworkErrorViewController.m
//  Airhob
//
//  Created by Nazim on 29/09/16.
//  Copyright © 2016 mYwindow Inc. All rights reserved.
//

#import "NetworkErrorViewController.h"
#import "Reachability.h"

@interface NetworkErrorViewController ()
@property (strong, nonatomic) IBOutlet UILabel *internetUnavailabilityLabel;

@property (strong, nonatomic) IBOutlet UIImageView *internetUnavailibityImage;
@property (strong, nonatomic) IBOutlet UIButton *tryAgainButton;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
@property(strong)Reachability *internetReachablity;
@end

@implementation NetworkErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setReachabilityNotifier];
    self.tryAgainButton.layer.cornerRadius = 4.0f;
    self.dismissButton.layer.cornerRadius = 4.0f;
    
}

-(void)setReachabilityNotifier
{
    __weak __block typeof(self) weakself = self;
    
    _internetReachablity = [Reachability reachabilityForInternetConnection];
    self.internetReachablity.reachableBlock = ^(Reachability *rechability)
    {
     
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [weakself dismissViewControllerAnimated:YES completion:nil];
        });
        
    };
    
    [_internetReachablity startNotifier];

}

- (IBAction)dismissButtontapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)taryAgainButtonTapped:(id)sender {
    
    NetworkStatus networkStatus = [_internetReachablity currentReachabilityStatus];
    if (networkStatus != NotReachable) {
        [self dismissViewControllerAnimated:YES completion:nil];

    }
}

- (IBAction)openSettingButtonTapped:(id)sender {

    if (UIApplicationOpenSettingsURLString != NULL) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        
        [[[UIAlertView alloc]initWithTitle:@"Failed to open Settings" message:@"We are unable to open settings now would you please try it manually?" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];

    }
}

@end
