//
//  SplashScreenViewController.m
//  Closed1
//
//  Created by Nazim on 12/02/18.
//  Copyright © 2018 Alkurn. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "SKSplashIcon.h"
#import "SKSplashView.h"
#import "LoginViewController.h"

@interface SplashScreenViewController ()<SKSplashDelegate>

@property (strong, nonatomic) SKSplashView *splashView;


@end

@implementation SplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated

{
    [self.navigationController setNavigationBarHidden:YES];
    
    [self createAnimationSplashScreen];
}


- (void) createAnimationSplashScreen
{
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"AppLogoImage"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = [UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0];
    _splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon animationType:SKSplashAnimationTypeZoom];
    _splashView.delegate = self; //Optional -> if you want to receive updates on animation beginning/end
    _splashView.backgroundColor = twitterColor;
    _splashView.animationDuration = 2.5; //Optional -> set animation duration. Default: 1s
    [self.view addSubview:_splashView];
    [_splashView startAnimation];
}

#pragma mark - Delegate methods (Optional)

- (void) splashView:(SKSplashView *)splashView didBeginAnimatingWithDuration:(float)duration
{
    NSLog(@"Started animating from delegate");
}

- (void) splashViewDidEndAnimating:(SKSplashView *)splashView
{
    NSLog(@"Stopped animating from delegate");
    
    LoginViewController *loginScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController pushViewController:loginScreen animated:NO];

}

@end
