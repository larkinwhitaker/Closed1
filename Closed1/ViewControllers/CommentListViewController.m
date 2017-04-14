//
//  CommentListViewController.m
//  Closed1
//
//  Created by Nazim on 14/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "CommentListViewController.h"
#import "UIImageView+WebCache.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"

@interface CommentListViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) NSString *commnetText;
@property(nonatomic) NSMutableArray *messageArray;

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 120;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    _messageArray = [[NSMutableArray alloc]init];
    [_messageArray addObject:@""];
    [_messageArray addObject:@""];
    NSArray *messsages = [self.feedsDetails valueForKey:@"message_array"];
    
    if (messsages.count != 0) {
        
        for (NSInteger i =0; i<messsages.count; i++) {
            [_messageArray addObject:[messsages objectAtIndex:i]];
        }
        
    }
    
    
    
    
    NSLog(@"%@", self.feedsDetails);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped)];
    
    navItem.leftBarButtonItem = backButton;
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Comments"];
    [self.view addSubview:navBar];
    
}

-(void)backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView Delegates

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messageArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        UITableViewCell *feedsCell = [tableView dequeueReusableCellWithIdentifier:@"FeedsViewCell"];
        
        
        UILabel *commnetLabel = (UILabel *)[feedsCell viewWithTag:2];
        commnetLabel.text = [_feedsDetails valueForKey:@"content"];
        
        UILabel *userName = (UILabel *)[feedsCell viewWithTag:3]
        ;
        userName.text = [_feedsDetails valueForKey:@"closed"];
        
        UIImageView *profileImage = (UIImageView *)[feedsCell viewWithTag:1];
        [profileImage sd_setImageWithURL:[NSURL URLWithString:[self.feedsDetails valueForKey:@"profile_image_url"]] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
        
        return feedsCell;
    }else if (indexPath.row == 1){
        
        UITableViewCell *postCommnetCell = [tableView dequeueReusableCellWithIdentifier:@"CommentTextFiedlCell"];
        
        UITextView *commnetTextView = (UITextView *)[postCommnetCell viewWithTag:2];
        commnetTextView.text = @"";
        
        
        UIButton *postButton = (UIButton *)[postCommnetCell viewWithTag:1];
        [postButton addTarget:self action:@selector(postButtontapped:) forControlEvents:UIControlEventTouchUpInside];
        
        return postCommnetCell;
    }else{
        
        UITableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        
        UILabel *userName = (UILabel *)[commentCell viewWithTag:2];
        UILabel *comment = (UILabel *)[commentCell viewWithTag:3];
        UIImageView *userImage = (UIImageView *)[commentCell viewWithTag:1];
        
        userName.text = [[_messageArray objectAtIndex:indexPath.row] valueForKey:@"full name"];
        comment.text = [[_messageArray objectAtIndex:indexPath.row] valueForKey:@"content"];
        [userImage sd_setImageWithURL:[NSURL URLWithString:[[[self.feedsDetails valueForKey:@""] objectAtIndex:indexPath.row] valueForKey:@"profile_image_url"]] placeholderImage: [UIImage imageNamed:@"male-circle-128.png"]];

        
        return commentCell;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.commnetText = textView.text;
}

-(void)postButtontapped: (id)sender
{
    [self.view endEditing:YES];
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    if ([[_commnetText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"Please Enter the comment" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }else{
        
        [self.messageArray insertObject:@{@"profile_image_url": user.profileImage, @"content": _commnetText, @"full name":[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]} atIndex:2];
        
        [self.tableView reloadData];
    }
}


@end
