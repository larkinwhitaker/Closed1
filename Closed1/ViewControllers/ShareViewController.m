//
//  ShareViewController.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ShareViewController.h"
#import "JVFloatLabeledTextView.h"
#import "ClosedResverResponce.h"
#import "UserDetails+CoreDataClass.h"
#import "MBProgressHUD.h"
#import "MagicalRecord.h"


@interface ShareViewController ()<UITextViewDelegate, ServerFailedDelegate>

@property (strong, nonatomic) IBOutlet UIButton *shareDealButton;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextView *nametextView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextView *commentTextView;
@property (strong, nonatomic) IBOutlet UILabel *timingLabel;
@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustumNavigationBar];
    
    self.commentTextView.textContainer.lineFragmentPadding = 5.0;
    self.nametextView.textContainer.lineFragmentPadding = 5.0;
    
//    textContainerInset = UIEdgeInsets.zero;
//    textContainer.lineFragmentPadding = 0;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    self.timingLabel.text = dateString;

    
}


- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Share a Deal"];
    [self.view addSubview:navBar];
    
}
- (IBAction)shareDealTapped:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([[self.nametextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        
        [self animateView:self.nametextView];
        
    }else if ([[self.commentTextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] == 0){
        
        [self animateView:self.commentTextView];

        
    }else{
        
        [self submitDatatToServer];
    }
}

-(void)submitDatatToServer
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    
    NSLog(@"%@", dateString);
   
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Posting feed";
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    [ClosedResverResponce sharedInstance].delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=sharedeal&user_id=%zd&closed=%@&comment=%@&date_recorded=%@", userDetails.userID, self.nametextView.text, self.commentTextView.text, dateString] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"%@", serverResponce);
            
            if ([serverResponce valueForKey:@"success"] != nil ) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    self.commentTextView.text = @"";
                    self.nametextView.text = @"";
                    
                    [self.tabBarController setSelectedIndex:0];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFeedsAvilable" object:nil];
                }else{
                    
                    [self serverFailedWithTitle:@"Oops!!" SubtitleString:[serverResponce valueForKey:@"data"]];

                }
            }else{
                
                [self serverFailedWithTitle:@"Oops!!" SubtitleString:@"Failed to post feed. Please try again later."];
                
            }
            
        });
    });
     
    
}

#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.nametextView ) {
        
        return textView.text.length + (text.length - range.length) <= 25;

        
    }else{
    
        return textView.text.length + (text.length - range.length) <= 125;

    }
    
    
}

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];

    });
    
}

-(void)animateView: (UIView *)textField
{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.07;
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x - 10, textField.center.y)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x + 10, textField.center.y)];
    [textField.layer addAnimation:animation forKey:@"position"];
    
}


@end
