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

@interface UserProfileViewController ()<UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic)  ProfileCell *profileCell;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetails *userDetails = [UserDetails MR_findFirst];

    ProfileCell *profileCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    
    profileCell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", userDetails.firstName, userDetails.lastName];
    profileCell.emailLabel.text = userDetails.userEmail;
    profileCell.phoneLabel.text = @"Not Found";
    profileCell.companyLabel.text = userDetails.company;
    profileCell.roleLabel.text = userDetails.title;
    profileCell.userBildName.text = [NSString stringWithFormat:@"%@ %@", userDetails.firstName, userDetails.lastName];
    [profileCell.changeProfileButton addTarget:self action:@selector(displayAlertForChoosingCamera) forControlEvents:UIControlEventTouchUpInside];
    [profileCell.profileImage sd_setImageWithURL:[NSURL URLWithString:userDetails.profileImage] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    return profileCell;
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
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"Camera Fucntionality is avilable with your device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
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

#pragma mark - Image Picker Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *pickerImage = info[UIImagePickerControllerOriginalImage] ;
    _profileCell.profileImage.image = pickerImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self.tableView reloadData];
    
}


@end
