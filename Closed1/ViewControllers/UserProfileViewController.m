//
//  UserProfileViewController.m
//  Closed1
//
//  Created by Nazim on 13/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "UserProfileViewController.h"
#import "ProfileCell.h"
#import "MagicalRecord.h"
#import "UserDetails+CoreDataClass.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "ClosedResverResponce.h"
#import "utilities.h"
#import "JobProfile+CoreDataProperties.h"
#import "CardDetails+CoreDataProperties.h"
#import "AFNetworking.h"

@interface UserProfileViewController ()<UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ServerFailedDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic)  ProfileCell *profileCell;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}

-(void)saveUserProfileImageForChattingView: (UIImage *)profileImage
{
    
    UIImage *image = profileImage;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UIImage *imagePicture = [Image square:image size:140];
    UIImage *imageThumbnail = [Image square:image size:60];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSData *dataPicture = UIImageJPEGRepresentation(imagePicture, 0.6);
    NSData *dataThumbnail = UIImageJPEGRepresentation(imageThumbnail, 0.6);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *reference1 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_picture", @"jpg")];
    FIRStorageReference *reference2 = [[storage referenceForURL:FIREBASE_STORAGE] child:Filename(@"profile_thumbnail", @"jpg")];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [reference1 putData:dataPicture metadata:nil completion:^(FIRStorageMetadata *metadata1, NSError *error)
     {
         if (error == nil)
         {
             [reference2 putData:dataThumbnail metadata:nil completion:^(FIRStorageMetadata *metadata2, NSError *error)
              {
                  if (error == nil)
                  {
                      NSString *linkPicture = metadata1.downloadURL.absoluteString;
                      NSString *linkThumbnail = metadata2.downloadURL.absoluteString;
                      [self saveUserPictures:@{@"linkPicture":linkPicture, @"linkThumbnail":linkThumbnail}];
                  }
                  else [ProgressHUD showError:@"Network error."];
              }];
         }
         else [ProgressHUD showError:@"Network error."];
     }];
    
    
}

- (void)saveUserPictures:(NSDictionary *)links
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    FUser *user = [FUser currentUser];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    user[FUSER_PICTURE] = links[@"linkPicture"];
    user[FUSER_THUMBNAIL] = links[@"linkThumbnail"];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [user saveInBackground:^(NSError *error)
     {
         NSLog(@"Error while saving profile image in Cahtting DB");
     }];
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.navigationController.navigationBar.hidden = YES;
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButonTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetails *userDetails = [UserDetails MR_findFirst];

     _profileCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    
    _profileCell.nameLabel.text = userDetails.firstName;
    _profileCell.emailLabel.text = userDetails.userEmail;
    
    if (userDetails.phoneNumber == nil) {
        _profileCell.phoneLabel.text = @"Not Found";

    }else{
        _profileCell.phoneLabel.text = userDetails.phoneNumber;

    }
    _profileCell.companyLabel.text = userDetails.company;
    _profileCell.roleLabel.text = userDetails.title;
    _profileCell.userBildName.text = userDetails.firstName;
    [_profileCell.saveButton addTarget:self action:@selector(saveProfile:) forControlEvents:UIControlEventTouchUpInside];
    [_profileCell.changeProfileButton addTarget:self action:@selector(displayAlertForChoosingCamera) forControlEvents:UIControlEventTouchUpInside];
    [_profileCell.profileImage sd_setImageWithURL:[NSURL URLWithString:userDetails.profileImage] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
        
    return _profileCell;
}

-(void)saveProfile: (id)sender
{
   
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to logout?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        [UserDetails MR_truncateAll];
        [JobProfile MR_truncateAll];
        LogoutUser(DEL_ACCOUNT_ALL);
        [CardDetails MR_truncateAll];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FirstTimeExperienceHome"];

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FirstTimeExperienceContacts"];

        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [self.navigationController popToRootViewControllerAnimated:YES];

        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)profileSavesSucessFully
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)displayAlertForChoosingCamera
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose image from:" message:@"Please choose image from one of these options" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [self openGalleryFunctionality];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *Action){
        
        [self openCameraFunctionality];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(void)openCameraFunctionality
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        
        UIImagePickerController *cameraPicker = [[UIImagePickerController alloc]init];
        cameraPicker.delegate = self;
        cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraPicker.allowsEditing = YES;
        
        [self presentViewController:cameraPicker animated:YES completion:nil];
        
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"Camera Fucntionality is not available with your device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}

-(void)openGalleryFunctionality
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        
        UIImagePickerController *galleryPicker = [[UIImagePickerController alloc]init];
        galleryPicker.delegate = self;
        //        galleryPicker.mediaTypes
        galleryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        galleryPicker.allowsEditing = YES;
        
        [self presentViewController:galleryPicker animated:YES completion:nil];
        
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"Camera Fucntionality is avilable with your device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
}

-(IBAction)deleteButtonTapped:(id)sender
{
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete?" message:@"Deleting your account will delete all of the content you have created. It will be completely irrecoverable." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.dimBackground = YES;
        hud.labelText = @"Deleting..";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *responce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=deleteUser&ID=%zd", userDetails.userID] DictionartyToServer:@{} IsEncodingRequires:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if ([[responce valueForKey:@"success"] integerValue] == 1) {
                    
                    [UserDetails MR_truncateAll];
                    [JobProfile MR_truncateAll];

                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                }else{
                    
                    [[[UIAlertView alloc]initWithTitle:@"Failed to Delete Profile" message:@"We are getting some issu while deleting your profile. Please try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
                }
                
                
                
            });
        });
        
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - Image Picker Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    //---------------------------------------------------------------------------------------------------------------------------------------------
//    UIImage *imagePicture = [Image square:image size:140];
    UIImage *imageThumbnail = [Image square:image size:160];
    
    [self submitImageToServer:imageThumbnail];
    
    [self saveUserProfileImageForChattingView:image];
    

//    NSData *dataPicture = UIImageJPEGRepresentation(imagePicture, 0.6);
//    NSData *dataThumbnail = UIImageJPEGRepresentation(imageThumbnail, 0.6);
    
    [picker dismissViewControllerAnimated:YES completion:nil];

    
}


-(void)submitImageToServer: (UIImage *)imagetoSend
{
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Saving Image";
    
    NSDictionary *dictToServer = @{@"picture_code": [self encodeToBase64String:imagetoSend], @"user_id":[NSNumber numberWithInteger:userDetails.userID]};

    NSString *apiURL = @"https://closed1app.com/API/buddypressread/profile_upload_photo/";

    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];

    
    [manager POST:apiURL parameters:dictToServer progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSArray *serverData = responseObject;
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        
        if ([[serverData valueForKey:@"error"] isEqual:[NSNull null]]) {
            self.profileCell.profileImage.image = imagetoSend;
            UserDetails *newUserDetails = [UserDetails MR_findFirst];
            newUserDetails.profileImage = [serverData valueForKey:@"imageurl"];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFeedsAvilable" object:nil];

            
            [ProgressHUD showSuccess:@"Image Uploaded"];
        }else{
            [self serverFailedWithTitle:@"Failed to Upload Profile Picture" SubtitleString:nil];
            [ProgressHUD showError:@"Failed to Upload image"];
        }

        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self serverFailedWithTitle:@"Failed to Upload Profile Picture" SubtitleString:nil];
;
            
        });
    }];
    
    
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:apiURL DictionartyToServer:dictToServer IsEncodingRequires:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"%@", serverResponce);
            
            if ([serverResponce valueForKey:@"success"] != nil) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    UserDetails *newUserDetails = [UserDetails MR_findFirst];
                    newUserDetails.profileImage = [[[serverResponce valueForKey:@"data"] firstObject] valueForKey:@"profile_picture"];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }else{
                    [self serverFailedWithTitle:@"Failed to Upload Profile Picture" SubtitleString:nil];
                }
            }else{
                [self serverFailedWithTitle:@"Failed to Upload Profile Picture" SubtitleString:nil];

            }
            
           
        });
        
    });
     
     */
}

- (NSString *)encodeToBase64String:(UIImage *)image {
//    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSData *data = UIImagePNGRepresentation(image);
    NSString *byteArray  = [data base64Encoding];
    
    return byteArray;
}

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    });
}


@end
