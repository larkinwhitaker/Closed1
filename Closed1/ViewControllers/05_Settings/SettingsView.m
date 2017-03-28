//
// Copyright (c) 2016 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SettingsView.h"
#import "EditProfileView.h"
#import "PasswordView.h"
#import "StatusView.h"
#import "ArchiveView.h"
#import "CacheView.h"
#import "MediaView.h"
#import "WallpapersView.h"
#import "PrivacyView.h"
#import "TermsView.h"
#import "AddAccountView.h"
#import "SwitchAccountView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SettingsView()
{
	BOOL skipLoading;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellProfile;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellStatus;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellArchive;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCache;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellMedia;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellAutoSave;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellWallpapers;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellPrivacy;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellTerms;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellAddAccount;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellSwitchAccount;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellLogout;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLogoutAll;

@property (strong, nonatomic) IBOutlet UISwitch *switchAutoSave;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SettingsView

@synthesize viewHeader, imageUser, labelInitials, labelName;
@synthesize cellProfile, cellPassword;
@synthesize cellStatus;
@synthesize cellArchive, cellCache, cellMedia, cellAutoSave, cellWallpapers;
@synthesize cellPrivacy, cellTerms;
@synthesize cellAddAccount, cellSwitchAccount;
@synthesize cellLogout, cellLogoutAll;
@synthesize switchAutoSave;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_settings"]];
		self.tabBarItem.title = @"Settings";
		//-----------------------------------------------------------------------------------------------------------------------------------------
    }
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Settings";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[switchAutoSave addTarget:self action:@selector(actionAutoSaveSwitch) forControlEvents:UIControlEventValueChanged];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
		[self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUserPictures:(NSDictionary *)links
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUserAutoSaveMedia:(BOOL)autoSaveMedia
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	skipLoading = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

//	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Open camera" style:UIAlertActionStyleDefault
//													handler:^(UIAlertAction *action) { PresentPhotoCamera(self, YES); }];
//	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Photo library" style:UIAlertActionStyleDefault
//													handler:^(UIAlertAction *action) { PresentPhotoLibrary(self, YES); }];
//	UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//
//	[alert addAction:action1]; [alert addAction:action2]; [alert addAction:action3];
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionProfile
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	EditProfileView *editProfileView = [[EditProfileView alloc] initWith:NO];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:editProfileView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPassword
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PasswordView *passwordView = [[PasswordView alloc] init];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:passwordView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionStatus
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	StatusView *statusView = [[StatusView alloc] init];
	statusView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:statusView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionArchive
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ArchiveView *archiveView = [[ArchiveView alloc] init];
	archiveView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:archiveView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCache
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CacheView *cacheView = [[CacheView alloc] init];
	cacheView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:cacheView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMedia
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	MediaView *mediaView = [[MediaView alloc] init];
	mediaView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:mediaView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAutoSave
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAutoSaveSwitch
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionWallpapers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	WallpapersView *wallpapersView = [[WallpapersView alloc] init];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:wallpapersView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPrivacy
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PrivacyView *privacyView = [[PrivacyView alloc] init];
	privacyView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:privacyView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTerms
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	TermsView *termsView = [[TermsView alloc] init];
	termsView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:termsView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAddAccount
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSwitchAccount
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Log out" style:UIAlertActionStyleDestructive
													handler:^(UIAlertAction *action) { [self actionLogoutUser]; }];
	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:action1]; [alert addAction:action2];
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogoutAll
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Log out all accounts" style:UIAlertActionStyleDestructive
													handler:^(UIAlertAction *action) { [self actionLogoutAllUser]; }];
	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:action1]; [alert addAction:action2];
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogoutUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSwitchNextUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogoutAllUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

#pragma mark - Cleanup methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	imageUser.image = [UIImage imageNamed:@"settings_blank"];
	labelName.text = nil;
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *image = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
//	UIImage *imagePicture = [Image square:image size:140];
//	UIImage *imageThumbnail = [Image square:image size:60];
//	//---------------------------------------------------------------------------------------------------------------------------------------------
//	NSData *dataPicture = UIImageJPEGRepresentation(imagePicture, 0.6);
//	NSData *dataThumbnail = UIImageJPEGRepresentation(imageThumbnail, 0.6);
//	//---------------------------------------------------------------------------------------------------------------------------------------------
//	FIRStorage *storage = [FIRStorage storage];
//	FIRStorageReference *reference1 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_picture", @"jpg")];
//	FIRStorageReference *reference2 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_thumbnail", @"jpg")];
//	//---------------------------------------------------------------------------------------------------------------------------------------------
//	[reference1 putData:dataPicture metadata:nil completion:^(FIRStorageMetadata *metadata1, NSError *error)
//	{
//		if (error == nil)
//		{
//			[reference2 putData:dataThumbnail metadata:nil completion:^(FIRStorageMetadata *metadata2, NSError *error)
//			{
//				if (error == nil)
//				{
//					labelInitials.text = nil;
//					imageUser.image = imagePicture;
//					NSString *linkPicture = metadata1.downloadURL.absoluteString;
//					NSString *linkThumbnail = metadata2.downloadURL.absoluteString;
//					[self saveUserPictures:@{@"linkPicture":linkPicture, @"linkThumbnail":linkThumbnail}];
//				}
//				else [ProgressHUD showError:@"Network error."];
//			}];
//		}
//		else [ProgressHUD showError:@"Network error."];
//	}];
//	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 6;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (section == 0) return  1;
	if (section == 1) return 1;
	if (section == 2) return 5;
	if (section == 3) return 2;
	if (section == 4) return 2;
	if (section == 5) return   2;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 1) return @"Status";
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellProfile;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellPassword;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellStatus;
	if ((indexPath.section == 2) && (indexPath.row == 0)) return cellArchive;
	if ((indexPath.section == 2) && (indexPath.row == 1)) return cellCache;
	if ((indexPath.section == 2) && (indexPath.row == 2)) return cellMedia;
	if ((indexPath.section == 2) && (indexPath.row == 3)) return cellAutoSave;
	if ((indexPath.section == 2) && (indexPath.row == 4)) return cellWallpapers;
	if ((indexPath.section == 3) && (indexPath.row == 0)) return cellPrivacy;
	if ((indexPath.section == 3) && (indexPath.row == 1)) return cellTerms;
	if ((indexPath.section == 4) && (indexPath.row == 0)) return cellAddAccount;
	if ((indexPath.section == 4) && (indexPath.row == 1)) return cellSwitchAccount;
	if ((indexPath.section == 5) && (indexPath.row == 0)) return cellLogout;
	if ((indexPath.section == 5) && (indexPath.row == 1)) return cellLogoutAll;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionProfile];
	if ((indexPath.section == 0) && (indexPath.row == 1)) [self actionPassword];
	if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionStatus];
	if ((indexPath.section == 2) && (indexPath.row == 0)) [self actionArchive];
	if ((indexPath.section == 2) && (indexPath.row == 1)) [self actionCache];
	if ((indexPath.section == 2) && (indexPath.row == 2)) [self actionMedia];
	if ((indexPath.section == 2) && (indexPath.row == 3)) [self actionAutoSave];
	if ((indexPath.section == 2) && (indexPath.row == 4)) [self actionWallpapers];
	if ((indexPath.section == 3) && (indexPath.row == 0)) [self actionPrivacy];
	if ((indexPath.section == 3) && (indexPath.row == 1)) [self actionTerms];
	if ((indexPath.section == 4) && (indexPath.row == 0)) [self actionAddAccount];
	if ((indexPath.section == 4) && (indexPath.row == 1)) [self actionSwitchAccount];
	if ((indexPath.section == 5) && (indexPath.row == 0)) [self actionLogout];
	if ((indexPath.section == 5) && (indexPath.row == 1)) [self actionLogoutAll];
}

@end

