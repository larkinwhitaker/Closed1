//
//  SignupViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "SignupViewController.h"
#import "SignupTableViewCell.h"
#import "MBProgressHUD.h"
#import "TabBarHandler.h"
#import "CustomListViewController.h"

@interface SignupViewController ()<UITableViewDelegate, UITableViewDataSource, SelectedCountryDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) SignupTableViewCell *signupCell;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [self createCustumNavigationBar];
    

}

- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];

    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    
    navItem.leftBarButtonItem = backButton;

    
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Sign up"];
    [self.view addSubview:navBar];
    
}
-(IBAction)backButtonTapped:(UIBarButtonItem *)sender

{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 727;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _signupCell= [tableView dequeueReusableCellWithIdentifier:@"SignupTableViewCell"];
    [_signupCell.signupButton addTarget:self action:@selector(signupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [_signupCell.countrySelectionButton addTarget:self action:@selector(openCountrySelectionScreen) forControlEvents:UIControlEventTouchUpInside];
    
    return _signupCell;
}

-(void)openCountrySelectionScreen
{
    CustomListViewController  *listViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomListViewController"];
    listViewController.delegate = self;
    listViewController.heightOFRow = 40.0;
    listViewController.title = @"Search Country";
    NSArray *countryList = [self getDataFromJsonFile:@"CountryList"];
    countryList = [countryList valueForKey:@"data"];
    
    NSMutableArray *countryListArray = [[NSMutableArray alloc]init];
    
    for (NSInteger i =0; i<countryList.count; i++) {
        
        [countryListArray addObject:[[countryList objectAtIndex:i] valueForKey:@"Country"]];
    }
    
    listViewController.listArray = [[NSMutableArray alloc]initWithObjects:countryListArray, nil];
    [self presentViewController:listViewController animated:YES completion:nil];
}

-(NSArray *)getDataFromJsonFile: (NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:fileName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataFromlLocal = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return dataFromlLocal;
}

-(void)signupButtonTapped: (id)sender
{
    
    if ([[_signupCell.usenameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.usenameTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];
        
    }else if ([[_signupCell.emailtextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.emailtextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }else if ([[_signupCell.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.passwordTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }
    else if ([[_signupCell.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.confirmPasswordTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }
    else if ([[_signupCell.fullNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.fullNameTextField];
        
    }
    else if ([[_signupCell.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.cityTextField];
        
    }
    else if ([[_signupCell.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.stateTextField];
        
    }
    else if ([[_signupCell.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.phoneNumberTextField];
        
    }else if ([_signupCell.countrySelectionButton.titleLabel.text isEqualToString:@""]){
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"Please select the city first to move ahead" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }else{
     
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
        if([emailPredicate evaluateWithObject: _signupCell.emailtextField.text] == NO){
           
            [self animateView:_signupCell.emailtextField];
            [self.tableView setContentOffset:CGPointZero animated:YES];

        
        }else{
            
            if ([_signupCell.passwordTextField.text isEqualToString:_signupCell.confirmPasswordTextField.text]) {
                
                [self submitDataToServer];

            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Password not matched" message:@"Please re-enter the password. Both password must be same" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
            }
            
        }

    
    }
}


-(void)submitDataToServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Signing you up";
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(openHomeScreen) userInfo:nil repeats:NO];
}
-(void)openHomeScreen
{
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

#pragma mark - Country Selected Delegate

-(void)getSelectedIndex:(NSInteger)selectedIndex SelectedProgram:(NSString *)selectedProgram
{
    NSLog(@"%@", selectedProgram);
    [_signupCell.countrySelectionButton setTitle:selectedProgram forState:UIControlStateNormal];
    [_signupCell.countrySelectionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

@end
