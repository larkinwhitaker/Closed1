//
//  ShareViewController.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ShareViewController.h"
#import "JVFloatLabeledTextView.h"

@interface ShareViewController ()<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *shareDealButton;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextView *nametextView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextView *commentTextView;
@property (strong, nonatomic) IBOutlet UILabel *timingLabel;
@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustumNavigationBar];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    self.timingLabel.text = dateString;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
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
    [navItem setTitle:@"Closed1"];
    [self.view addSubview:navBar];
    
}

#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 125;
}

@end
