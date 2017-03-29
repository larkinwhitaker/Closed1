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
#import <MessageUI/MessageUI.h>
#import "ContactsTableViewCell.h"

@interface ContactsViewController ()<CNContactPickerDelegate,MFMessageComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableViee;
@end

@implementation ContactsViewController



- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    [self createCustumNavigationBar];
    [self.tableViee registerNib:[UINib nibWithNibName:@"ContactsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactsTableViewCell"];

    
//    CNContactStore *store = [[CNContactStore alloc]init];
//    
//    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
//        
//        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error){
//            
//            if (granted) {
//                
//                [self retrieveContactsWithStore:store];
//                
//            }
//        }];
//        
//    }else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized)
//    {
//        [self retrieveContactsWithStore:store];
//        
//    }
    

}

- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    UIBarButtonItem *contacts = [[UIBarButtonItem alloc]initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(openContactsScreen)];
    
    navItem.rightBarButtonItem = contacts;
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:107.0/255.0 green:225.0/255.0 blue:211.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Contacts"];
    [self.view addSubview:navBar];
    
}

-(void)openContactsScreen
{
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc]init];
    
//    NSArray *propertyKeys = @[CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactOrganizationNameKey];
    NSPredicate *enablePredicate = [NSPredicate predicateWithFormat:@"(phoneNumbers.@count > 0)"];
//    NSPredicate *contactSelectionPredicate = [NSPredicate predicateWithFormat:@"phoneNumbers.@count == 1"];
    
//    contactPicker.displayedPropertyKeys = propertyKeys;
    contactPicker.predicateForEnablingContact = enablePredicate;
//    contactPicker.predicateForSelectionOfContact = contactSelectionPredicate;

    contactPicker.delegate = self;
    [self presentViewController:contactPicker animated:NO completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.tableViee.estimatedRowHeight = 70.0;
    self.tableViee.rowHeight = UITableViewAutomaticDimension;
    
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
    NSMutableArray *phoneList = [[NSMutableArray alloc]init];

    if ([contact isKeyAvailable:CNContactPhoneNumbersKey]) {
        
        NSArray *contactPhone = contact.phoneNumbers;
        
        if ([contact isKeyAvailable:CNContactPhoneNumbersKey]) {
            
            NSLog(@"%@", [[[contact.phoneNumbers objectAtIndex:0] value] valueForKey:@"digits"]);
            
            for (NSInteger i =0; i<contact.phoneNumbers.count; i++) {
                
                [phoneList addObject:[[[contact.phoneNumbers objectAtIndex:i] value] valueForKey:@"digits"]];
                
            }
            
        }
    }
    
    if (phoneList.count != 0) {
        
        [self sendMessages:phoneList];
        
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"No contacts selected" message:@"Please select atleast one contact to send invites" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }
    
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts
{
    NSMutableArray *phoneList = [[NSMutableArray alloc]init];
    
    for (CNContact *contact in contacts) {
        
        if ([contact isKeyAvailable:CNContactPhoneNumbersKey]) {
            
            NSLog(@"%@", [[[contact.phoneNumbers objectAtIndex:0] value] valueForKey:@"digits"]);
            
            for (NSInteger i =0; i<contact.phoneNumbers.count; i++) {
                
                [phoneList addObject:[[[contact.phoneNumbers objectAtIndex:i] value] valueForKey:@"digits"]];
                
            }
            
        }
    }
    
    if (phoneList.count != 0) {
        
        [self sendMessages:phoneList];
        
    }else{
        
       [[[UIAlertView alloc]initWithTitle:@"No contacts selected" message:@"Please select atleast one contact to send invites" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }

}

-(void)sendMessages: (NSArray *)contactsList
{
    
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:contactsList];
    NSArray *filteredContacts = [orderedSet array];
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"Hey i would you like to invite for using Closed 1 app. Please find a below link to install.";
        controller.recipients = filteredContacts;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
//        [self presentModalViewController:controller animated:YES];
    }

}

#pragma mark - Message Delegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSLog(@"%ld", (long)result);
}

#pragma mark - Tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ContactsTableViewCell *contactsCell = [tableView dequeueReusableCellWithIdentifier:@"ContactsTableViewCell"];
    contactsCell.profileImage.image = [UIImage imageNamed:@"male-circle-128.png"];
    contactsCell.nameLabel.text = @"Nazim Siddiqui";
    contactsCell.companyLabel.text = @"Kratin LLC";
    
    return contactsCell;
}




@end
