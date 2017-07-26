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
#import "ClosedResverResponce.h"
#import "MBProgressHUD.h"

@interface CommentListViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) NSString *commnetText;
@property(nonatomic) NSMutableArray *messageArray;
@property(atomic) BOOL isApiCalled;

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 120;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    _messageArray = [[NSMutableArray alloc]init];
    [_messageArray addObject:@""];
    [_messageArray addObject:@""];
    NSArray *messsages = [self.feedsDetails  valueForKey:@"message_array"];
    
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
    [navBar setBarTintColor:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0]];
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
    if (_isApiCalled){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFeedsAvilable" object:nil];
    }

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
        commnetLabel.text = [_feedsDetails  valueForKey:@"content"];
        
        UILabel *userName = (UILabel *)[feedsCell viewWithTag:3]
        ;
        
        
        NSString *titile = @"Not present";
        
        if (![[_feedsDetails  valueForKey:@"closed"] isEqual:@""] && ![[_feedsDetails  valueForKey:@"closed"] isEqual:[NSNull null]]) {
            
            titile = [_feedsDetails  valueForKey:@"closed"];
        }
        
        userName.text = titile;
        
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
        UILabel *dataTime = (UILabel *)[commentCell viewWithTag:4];
        UIImageView *userImage = (UIImageView *)[commentCell viewWithTag:1];
        
        userName.text = [[_messageArray objectAtIndex:indexPath.row] valueForKey:@"full name"];
        comment.text = [[_messageArray objectAtIndex:indexPath.row] valueForKey:@"content"];
        dataTime.text = [[_messageArray objectAtIndex:indexPath.row] valueForKey:@"date_recorded"];
        
        
        NSString *imageURL = @"";
        
        if([[_messageArray objectAtIndex:indexPath.row] objectForKey: @"profile_image_url"]){
            
            if (![[[_messageArray objectAtIndex:indexPath.row] valueForKey:@"profile_image_url"] isEqual:[NSNull null]]) {
                
                imageURL = [[_messageArray objectAtIndex:indexPath.row] valueForKey:@"profile_image_url"];
            }
        }
        
        [userImage sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
        
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
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.dimBackground = YES;
        hud.labelText = @"Posting Comment";
        
        NSString *URL = [NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=feed_comment&user_id=%zd&activity_id=%@&comment=%@", user.userID,[self.feedsDetails  valueForKey:@"activity_id"], _commnetText];
        
        NSLog(@"%@", URL);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer: URL DictionartyToServer:@{} IsEncodingRequires:NO];
            
            NSLog(@"%@", serverResponce);
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    _isApiCalled = YES;
                    
                    NSString *image = @"";
                    if (user.profileImage != nil) {
                        
                        image = user.profileImage;
                    }
                    
                    [self.messageArray addObject:@{@"profile_image_url": image, @"content": _commnetText, @"full name":user.firstName}];
                    
                    [self.tableView reloadData];

                    
                }else{
                    
                }
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
            
        });
        
        
        
        
    }
}


@end
