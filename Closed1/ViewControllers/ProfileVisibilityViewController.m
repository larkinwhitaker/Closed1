//
//  ProfileVisibilityViewController.m
//  Closed1
//
//  Created by Nazim on 02/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ProfileVisibilityViewController.h"
#import "FlightClassSelectionViewController.h"
#import "MBProgressHUD.h"
#import "UINavigationController+NavigationBarAttribute.h"

@interface ProfileVisibilityViewController ()<UITableViewDelegate, UITableViewDataSource, SelectedClassDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) BOOL companyTapped;
@property(nonatomic) BOOL secondaryEmailtapped;
@property(nonatomic) NSString *companyVisibility;
@property(nonatomic) NSString *emailVisibility;


@end

@implementation ProfileVisibilityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBlurView];
    [self.navigationController configureNavigationBar:self];

    _classListArray = @[@"Full name@Everyone", @"City@Everyone", @"State@Everyone", @"Country@Everyone", @"Phone Number@Everyone", @"Company@Everyone", @"Title@Everyone", @"Territory@Everyone" , @"Secondary Email@Everyone"];
    
    _emailVisibility = @"Secondary Email@Everyone";
    _companyVisibility = @"Company@Everyone";
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

-(void)saveButtonTapped: (id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Saving Profile";
    hud.dimBackground = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(profileSavesSucessFully) userInfo:nil repeats:NO];
}

-(void)profileSavesSucessFully
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _classListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 5){
        
        
        UITableViewCell *leftAlignmentCell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell"];
        
        UILabel *leftLable = (UILabel *)[leftAlignmentCell viewWithTag:1];
        
        UIButton *rightButton = (UIButton *)[leftAlignmentCell viewWithTag:2];
        
        UILabel *rightLabel = (UILabel *)[leftAlignmentCell viewWithTag:3];
        
        NSArray *twoString = [_companyVisibility componentsSeparatedByString:@"@"];
        leftLable.text = [twoString firstObject];
        [rightButton addTarget:self action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        rightButton.tag = 5;
        rightLabel.text = [twoString lastObject];
        
        return leftAlignmentCell;
        
        
        
    }else if (indexPath.row == 8){
        
        UITableViewCell *leftAlignmentCell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell"];
        
        UILabel *leftLable = (UILabel *)[leftAlignmentCell viewWithTag:1];
        
        UIButton *rightButton = (UIButton *)[leftAlignmentCell viewWithTag:2];
        
        UILabel *rightLabel = (UILabel *)[leftAlignmentCell viewWithTag:3];
        
        NSArray *twoString = [_emailVisibility componentsSeparatedByString:@"@"];
        leftLable.text = [twoString firstObject];
        [rightButton addTarget:self action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        rightButton.tag = 8;
        rightLabel.text = [twoString lastObject];
        
        return leftAlignmentCell;
        
        
    }else{
       
        UITableViewCell *leftAlignmentCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        UILabel *leftLable = (UILabel *)[leftAlignmentCell viewWithTag:1];
        
        UIButton *rightButton = (UIButton *)[leftAlignmentCell viewWithTag:2];
        
        UILabel *rightLabel = (UILabel *)[leftAlignmentCell viewWithTag:3];
        
        NSArray *twoString = [[_classListArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"@"];
        leftLable.text = [twoString firstObject];
        [rightButton addTarget:self action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        rightButton.tag = indexPath.row;
        rightLabel.text = [twoString lastObject];
        
        return leftAlignmentCell;
        
    }
    
    
    
    
    
}

-(void)rightButtonTapped: (UIButton *)sender
{
    NSLog(@"%zd", sender.tag);
    
    if (sender.tag == 5) {
        
        //compant Tapped
        
        _companyTapped = YES;
        _secondaryEmailtapped = NO;
        [self openClassSelectionScreen:nil];
        
    }else if (sender.tag == 8){
        
        //email tapped
        
        _companyTapped = NO;
        _secondaryEmailtapped = YES;
        [self openClassSelectionScreen:nil];

    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

-(void)addanimationToView:(UIView *)addToView
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [addToView.layer addAnimation:animation forKey:@"changeTextTransition"];
}



-(void)backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openClassSelectionScreen: (id)sender
{
    FlightClassSelectionViewController *classSelectionScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"FlightClassSelectionViewController"];
    classSelectionScreen.delegate = self;
    classSelectionScreen.title = @"";
    classSelectionScreen.classListArray = @[@"Everyone", @"Only Me", @"All Members", @"My Friends"];
    [self presentViewController:classSelectionScreen animated:YES completion:nil];
    
    
    
}


-(void)selectedPassengerDetails:(NSInteger)selectedrow WithSelectedDetails:(NSArray *)selectedDetails
{
    
    if (_secondaryEmailtapped) {
        
        _emailVisibility =[NSString stringWithFormat:@"Secondary Email@%@",[selectedDetails firstObject]] ;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:8 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (_companyTapped) {
        
        _companyVisibility = [NSString stringWithFormat:@"Company@%@",[selectedDetails firstObject]];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

    }
    
}




@end
