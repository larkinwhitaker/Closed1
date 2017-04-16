//
//  FlightClassSelectionViewController.m
//  Airhob
//
//  Created by mYwindow on 25/08/16.
//  Copyright © 2016 mYwindow Inc. All rights reserved.
//

#import "FlightClassSelectionViewController.h"
#import "LeftAlignmentCell.h"

@interface FlightClassSelectionViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
@implementation FlightClassSelectionViewController


static NSInteger const  totalNumberOfPassenger = 9;
static NSString * const cellIdentifier = @"PassengerViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustumNavigationBar];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [self setTableViewHeader];
    
    if (_isPassengerSelectionScreen)
    {
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.allowsSelection = NO;
        
        
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.allowsSelection= YES;
    }
    [self setupBlurView];
    
    self.tableView.bounces = NO;
}

-(void)setupBlurView
{
    UIImageView *backendImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.tableView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [backendImage addSubview:blurEffectView];
    } else {
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    backendImage.image = self.backgrounTableViewImage;
    self.tableView.backgroundView = backendImage;
    
}

-(void)doneButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"Removed viewcontoller");
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTableViewHeader
{
    UIView *tableHeaderView =[[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = tableHeaderView;
    
}

-(void)createCustumNavigationBar
{
    
    UINavigationBar *custumNavigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    [custumNavigationBar  setTintColor:[UIColor whiteColor]];
    [custumNavigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [custumNavigationBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]];
    custumNavigationBar.translucent = NO;
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    navigationItem.rightBarButtonItem = doneButton;
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CloseNavigationImage"] style:UIBarButtonItemStylePlain  target:self action:@selector(dismissViewController)];
    navigationItem.leftBarButtonItem = leftButton;
    [navigationItem setTitle:@""];
    custumNavigationBar.items = @[navigationItem];
    
    [self.view addSubview:custumNavigationBar];
}

-(void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _classListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (_shouldDisplayLeftAlignment){
        
        LeftAlignmentCell *leftAlignmentCell = [tableView dequeueReusableCellWithIdentifier:@"LeftAlignmentCell"];
        NSArray *twoString = [[_classListArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"@"];
        leftAlignmentCell.leftLable.text = [twoString firstObject];
        leftAlignmentCell.rightLabel.text = [twoString lastObject];
        
        return leftAlignmentCell;
        
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [_classListArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor colorWithRed:118.0/255.0 green:118.0/255.0 blue:118.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
    return cell;
    
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.delegate selectedPassengerDetails:indexPath.row WithSelectedDetails:@[[_classListArray objectAtIndex:indexPath.row]]];
    [self dismissViewController];
    
}

-(void)addanimationToView:(UIView *)addToView
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [addToView.layer addAnimation:animation forKey:@"changeTextTransition"];
}

@end
