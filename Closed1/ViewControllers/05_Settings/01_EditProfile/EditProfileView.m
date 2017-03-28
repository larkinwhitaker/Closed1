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

#import "EditProfileView.h"
#import "CountriesView.h"
#import "NavigationController.h"
#include <CoreFoundation/CoreFoundation.h>



#define		FUSER_FIRSTNAME						@"John"			//	String
#define		FUSER_LASTNAME						@"Doe"				//	String
#define		FUSER_FULLNAME						@"John Doe"				//	String
#define		FUSER_COUNTRY						@"India"				//	String
#define		FUSER_LOCATION						@"Nagpur"				//	String
#define		FUSER_PHONE							@"1234567890"				//	String
@interface EditProfileView()
{
	BOOL isOnboard;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellFirstname;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLastname;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCountry;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLocation;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPhone;

@property (strong, nonatomic) IBOutlet UITextField *fieldFirstname;
@property (strong, nonatomic) IBOutlet UITextField *fieldLastname;
@property (strong, nonatomic) IBOutlet UILabel *labelPlaceholder;
@property (strong, nonatomic) IBOutlet UILabel *labelCountry;
@property (strong, nonatomic) IBOutlet UITextField *fieldLocation;
@property (strong, nonatomic) IBOutlet UITextField *fieldPhone;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation EditProfileView

@synthesize viewHeader, imageUser, labelInitials;
@synthesize cellFirstname, cellLastname, cellCountry, cellLocation, cellPhone;
@synthesize fieldFirstname, fieldLastname, labelPlaceholder, labelCountry, fieldLocation, fieldPhone;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(BOOL)isOnboard_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	isOnboard = isOnboard_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Edit Profile";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
																						   action:@selector(actionDone)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	[self.tableView addGestureRecognizer:gestureRecognizer];
	gestureRecognizer.cancelsTouchesInView = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
    fieldFirstname.text = FUSER_FIRSTNAME;
    fieldLastname.text = FUSER_LASTNAME;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    labelCountry.text = FUSER_COUNTRY;
    fieldLocation.text = FUSER_LOCATION;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    fieldPhone.text = FUSER_PHONE;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self updateViewDetails];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	[self dismissKeyboard];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
	[self updateViewDetails];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveUserPictures:(NSDictionary *)links
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self dismissViewControllerAnimated:YES completion:nil];
	
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Open camera" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) {
                                                    
                                                    }];
	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Photo library" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) {
                                                    
                                                    }];
	UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:action1]; [alert addAction:action2]; [alert addAction:action3];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void)openImageGallery
{
    
}

-(void)openCamera
{
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) return NO;
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//    NSString *type = (NSString *)kUTTypeImage;
//    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
//        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:type])
//    {
//        imagePicker.mediaTypes = @[type];
//        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        
//        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
//        {
//            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
//        }
//        else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
//        {
//            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//        }
//    }
//    else return NO;
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//    imagePicker.allowsEditing = canEdit;
//    imagePicker.showsCameraControls = YES;
//    imagePicker.delegate = target;
//    [target presentViewController:imagePicker animated:YES completion:nil];

    //    return YES;

}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCountries
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CountriesView *countriesView = [[CountriesView alloc] init];
	countriesView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:countriesView];
	[self presentViewController:navController animated:YES completion:nil];
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
	//---------------------------------------------------------------------------------------------------------------------------------------------
//	NSData *dataPicture = UIImageJPEGRepresentation(imagePicture, 0.6);
//	NSData *dataThumbnail = UIImageJPEGRepresentation(imageThumbnail, 0.6);
	//---------------------------------------------------------------------------------------------------------------------------------------------
//	FIRStorage *storage = [FIRStorage storage];
//	FIRStorageReference *reference1 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_picture", @"jpg")];
//	FIRStorageReference *reference2 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_thumbnail", @"jpg")];
	//---------------------------------------------------------------------------------------------------------------------------------------------
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

#pragma mark - CountriesDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectCountry:(NSString *)country CountryCode:(NSString *)countryCode
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelCountry.text = country;
	[fieldLocation becomeFirstResponder];
	[self updateViewDetails];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 2;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return 4;
	if (section == 1) return 1;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellFirstname;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellLastname;
	if ((indexPath.section == 0) && (indexPath.row == 2)) return cellCountry;
	if ((indexPath.section == 0) && (indexPath.row == 3)) return cellLocation;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellPhone;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 2)) [self actionCountries];
}

#pragma mark - UITextField delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldFirstname)	[fieldLastname becomeFirstResponder];
	if (textField == fieldLastname)		[self actionCountries];
	if (textField == fieldLocation)		[fieldPhone becomeFirstResponder];
	if (textField == fieldPhone)		[self actionDone];
	return YES;
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateViewDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelPlaceholder.hidden = (labelCountry.text != nil);
}

@end
