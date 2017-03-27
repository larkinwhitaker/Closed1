//
//  ContactsViewController.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ContactsViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface ContactsViewController ()<CNContactPickerDelegate>

@end

@implementation ContactsViewController



- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    CNContactStore *store = [[CNContactStore alloc]init];
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
        
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error){
            
            if (granted) {
                
                [self retrieveContactsWithStore:store];
                
            }
        }];
        
    }else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized)
    {
        [self retrieveContactsWithStore:store];
        
    }
    
    

}

- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    UIBarButtonItem *contacts = [[UIBarButtonItem alloc]initWithTitle:@"Contacts" style:UIBarButtonItemStylePlain target:self action:@selector(openContactsScreen)];
    
    navItem.rightBarButtonItem = contacts;
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:107.0/255.0 green:225.0/255.0 blue:211.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Closed1"];
    [self.view addSubview:navBar];
    
}

-(void)openContactsScreen
{
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc]init];
    contactPicker.delegate = self;
    [self presentViewController:contactPicker animated:NO completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
}


-(void) retrieveContactsWithStore: (CNContactStore *)store
{
    
}

#pragma mark - Conatact picker Delegate

-(void)contactPickerDidCancel:(CNContactPickerViewController *)picker
{
    
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts
{
    
}




@end
