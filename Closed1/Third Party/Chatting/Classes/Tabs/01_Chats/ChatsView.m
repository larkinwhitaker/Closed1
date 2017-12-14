//
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ChatsView.h"
#import "ChatsCell.h"
#import "ChatView.h"
#import "NavigationController.h"
#import "UserDetails+CoreDataClass.h"
#import "MagicalRecord.h"
#import "ContactsViewController.h"
#import "Closed1-Swift.h"
#import "ClosedResverResponce.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatsView()<ContactsSelectedProtocol>
{
	NSTimer *timer;
	RLMResults *dbrecents;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) ContactsListViewController *contactScreen;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatsView

@synthesize searchBar;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_chats"]];
		self.tabBarItem.title = @"Chats";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
		[NotificationCenter addObserver:self selector:@selector(refreshTableView) name:NOTIFICATION_REFRESH_RECENTS];
		[NotificationCenter addObserver:self selector:@selector(refreshTabCounter) name:NOTIFICATION_REFRESH_RECENTS];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Chats";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self
																						   action:@selector(actionCompose)];
//
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismmissView:)];
    
    
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(refreshTableView) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerNib:[UINib nibWithNibName:@"ChatsCell" bundle:nil] forCellReuseIdentifier:@"ChatsCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.contactScreen = [storyboard instantiateViewControllerWithIdentifier:@"ContactsListViewController"];
    self.contactScreen.chatsDelegate = self;
    self.contactScreen.iscameFromChatScreen = YES;
    
	[self loadRecents];
}

-(void)dismmissView: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];

	//---------------------------------------------------------------------------------------------------------------------------------------------
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    
    if ([FUser currentId] != nil) {
        
        
        
        if ([FUser isOnboardOk])
        {
            
        }
        else{
            
            FUser *user = [FUser currentUser];
            //---------------------------------------------------------------------------------------------------------------------------------------------
            NSString *fullname = @"Demo User";
            NSString *phone = @"1234567890";
            
            if(userDetails.phoneNumber != nil) phone = userDetails.phoneNumber;

            if(userDetails.firstName != nil) fullname = userDetails.firstName;
            
            NSString *firstName = @"Demo";
            NSString *lastName = @"User";
            NSString *country = userDetails.country;
            NSString *location = @"Not found";
            
            if(userDetails.firstName != nil) firstName = userDetails.firstName;
            if(userDetails.firstName != nil ) lastName = [[userDetails.firstName componentsSeparatedByString:@" "] lastObject];

            
            user[FUSER_FULLNAME] = fullname;
            user[FUSER_FIRSTNAME] = firstName;
            user[FUSER_LASTNAME] = lastName;
            user[FUSER_COUNTRY] = country;
            user[FUSER_LOCATION] = location;
            user[FUSER_PHONE] = phone;
            //---------------------------------------------------------------------------------------------------------------------------------------------
            [user saveInBackground:^(NSError *error)
             {
//                 if (error != nil) [ProgressHUD showError:@"Network error."];
             }];

        }
        
        
    }else{
        
        
#pragma mark - Demo Login Code
        
        
        NSString *email = userDetails.userEmail;
        NSString *password = userDetails.userEmail;
        
        if(userDetails.userEmail != nil) email = userDetails.userEmail;
        
        //---------------------------------------------------------------------------------------------------------------------------------------------
//        if ([email length] == 0)	{  return; }
//        if ([password length] == 0)	{  return; }
        //---------------------------------------------------------------------------------------------------------------------------------------------
        LogoutUser(DEL_ACCOUNT_NONE);
        //---------------------------------------------------------------------------------------------------------------------------------------------
        [ProgressHUD show:nil Interaction:NO];
        //---------------------------------------------------------------------------------------------------------------------------------------------
        [FUser signInWithEmail:email password:password completion:^(FUser *user, NSError *error)
         {
             if (error == nil)
             {
                 [Account add:email password:password];
                     UserLoggedIn(LOGIN_EMAIL);

                 
             }
             else{
                 
#pragma mark - Sign up Code
                 
                 //---------------------------------------------------------------------------------------------------------------------------------------------
//                 if ([email length] == 0)	{ [ProgressHUD showError:@"Please enter your email."]; return; }
//                 if ([password length] == 0)	{ [ProgressHUD showError:@"Please enter your password."]; return; }
                 //---------------------------------------------------------------------------------------------------------------------------------------------
                 LogoutUser(DEL_ACCOUNT_NONE);
                 //---------------------------------------------------------------------------------------------------------------------------------------------
                 [ProgressHUD show:nil Interaction:NO];
                 //---------------------------------------------------------------------------------------------------------------------------------------------
                 [FUser createUserWithEmail:email password:password completion:^(FUser *user, NSError *error)
                  {
                      if (error == nil)
                      {
                          [Account add:email password:password];
                          UserLoggedIn(LOGIN_EMAIL);
                          
                          FUser *user = [FUser currentUser];
                          //---------------------------------------------------------------------------------------------------------------------------------------------
                          NSString *fullname = @"Demo User";
                          NSString *phone = @"1234567890";
                          
                          if(userDetails.phoneNumber != nil) phone = userDetails.phoneNumber;
                          
                          if(userDetails.firstName != nil) fullname = userDetails.firstName;
                          
                          NSString *firstName = @"Demo";
                          NSString *lastName = @"User";
                          NSString *country = userDetails.country;
                          NSString *location = userDetails.state;
                          
                          if(userDetails.firstName != nil) firstName = userDetails.firstName;
                          if(userDetails.firstName != nil ) lastName = [[userDetails.firstName componentsSeparatedByString:@" "] lastObject];
                          
                          
                          user[FUSER_FULLNAME] = fullname;
                          user[FUSER_FIRSTNAME] = firstName;
                          user[FUSER_LASTNAME] = lastName;
                          user[FUSER_COUNTRY] = country;
                          user[FUSER_LOCATION] = location;
                          user[FUSER_PHONE] = phone;
                          //---------------------------------------------------------------------------------------------------------------------------------------------
                          [user saveInBackground:^(NSError *error)
                           {
//                               if (error != nil) [ProgressHUD showError:@"Network error."];
                           }];
                          
                          
                      }
//                      else [ProgressHUD showError:[error description]];
                  }];
                 

                 
             }
         }];
         
       

    }
    

}

#pragma mark - Realm methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadRecents
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *text = searchBar.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isArchived == NO AND isDeleted == NO AND description CONTAINS[c] %@", text];
	dbrecents = [[DBRecent objectsWithPredicate:predicate] sortedResultsUsingProperty:FRECENT_LASTMESSAGEDATE ascending:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self refreshTableView];
	[self refreshTabCounter];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)archiveRecent:(DBRecent *)dbrecent
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	dbrecent.isArchived = YES;
	[realm commitWriteTransaction];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)deleteRecent:(DBRecent *)dbrecent
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RLMRealm *realm = [RLMRealm defaultRealm];
	[realm beginWriteTransaction];
	dbrecent.isDeleted = YES;
	[realm commitWriteTransaction];
}

#pragma mark - Refresh methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshTableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)refreshTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSInteger total = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (DBRecent *dbrecent in dbrecents)
		total += dbrecent.counter;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITabBarItem *item = self.tabBarController.tabBar.items[0];
	item.badgeValue = (total != 0) ? [NSString stringWithFormat:@"%ld", (long) total] : nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIUserNotificationSettings *currentUserNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
	if (currentUserNotificationSettings.types & UIUserNotificationTypeBadge)
		[UIApplication sharedApplication].applicationIconBadgeNumber = total;
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat:(NSDictionary *)dictionary
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ChatView *chatView = [[ChatView alloc] initWith:dictionary];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCompose
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self actionSelectSingle];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSelectSingle
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

    if(self.contactScreen){
        [self presentViewController:self.contactScreen animated:YES completion:nil];
    }
    
    
//	SelectSingleView *selectSingleView = [[SelectSingleView alloc] init];
//	selectSingleView.delegate = self;
//	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectSingleView];
//	[self presentViewController:navController animated:YES completion:nil];
//     
     
}

#pragma mark:- Contacts Selected Delegate

-(void)contactsSelectedEmail:(NSString *)email
{
    NSLog(@"Details are: %@", email);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", email];
    DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
    
    NSLog(@"%@", dbuser);
    
    if ([dbuser.objectId isEqualToString:[FUser currentId]] == YES)
    {
        [ProgressHUD showSuccess:@"This is you."];
        
    }else if (dbuser.objectId != nil) {
        
        [self didSelectSingleUser:dbuser];
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"The user you are messaging has not installed the \"Closed1\" App" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }
    
}



//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionArchive:(NSInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBRecent *dbrecent = dbrecents[index];
	NSString *recentId = dbrecent.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self archiveRecent:dbrecent];
	[self refreshTabCounter];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self performSelector:@selector(delayedArchive:) withObject:recentId afterDelay:0.25];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)delayedArchive:(NSString *)recentId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self refreshTableView];
	[Recent archiveItem:recentId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDelete:(NSInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DBRecent *dbrecent = dbrecents[index];
	NSString *recentId = dbrecent.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self deleteRecent:dbrecent];
	[self refreshTabCounter];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self performSelector:@selector(delayedDelete:) withObject:recentId afterDelay:0.25];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)delayedDelete:(NSString *)recentId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self refreshTableView];
	[Recent deleteItem:recentId];
}

#pragma mark - SelectSingleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSingleUser:(DBUser *)dbuser2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *dictionary = [Chat startPrivate:dbuser2];
	[self actionChat:dictionary];
}

#pragma mark - SelectMultipleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectMultipleUsers:(NSArray *)userIds
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *dictionary = [Chat startMultiple:userIds];
	[self actionChat:dictionary];
}

#pragma mark - SelectGroupDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectGroup:(DBGroup *)dbgroup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *dictionary = [Chat startGroup2:dbgroup];
	[self actionChat:dictionary];
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self refreshTableView];
	[self refreshTabCounter];
}

#pragma mark - UIScrollViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [dbrecents count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ChatsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatsCell" forIndexPath:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]],
						  [MGSwipeButton buttonWithTitle:@"Archive" backgroundColor:HEXCOLOR(0x3E70A7FF)]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cell.delegate = self;
	cell.tag = indexPath.row;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[cell bindData:dbrecents[indexPath.row]];
	[cell loadImage:dbrecents[indexPath.row] TableView:tableView IndexPath:indexPath];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return cell;
}

#pragma mark - MGSwipeTableCellDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction
		 fromExpansion:(BOOL)fromExpansion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (index == 0) [self actionDelete:cell.tag];
	if (index == 1) [self actionArchive:cell.tag];
	return YES;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	DBRecent *dbrecent = dbrecents[indexPath.row];
	NSDictionary *dictionary = [Chat restartRecent:dbrecent];
	[self actionChat:dictionary];
}

#pragma mark - UISearchBarDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self loadRecents];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar setShowsCancelButton:YES animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar setShowsCancelButton:NO animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	[self loadRecents];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar resignFirstResponder];
}

@end

