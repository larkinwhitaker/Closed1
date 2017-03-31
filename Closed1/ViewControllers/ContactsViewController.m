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
#import "ProfileDetailViewController.h"

@interface ContactsViewController ()<CNContactPickerDelegate,MFMessageComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViee;
@property(nonatomic) BOOL isMailContactSelected;

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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    UIBarButtonItem *contacts = [[UIBarButtonItem alloc]initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(pickContactMethod)];
    
    navItem.rightBarButtonItem = contacts;
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Contacts"];
    [self.view addSubview:navBar];
    
}

-(void)pickContactMethod
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select method" message:@"Please select one method via you want to sent invitations" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Mail" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [self openContactScreenFroMail];
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Message" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [self openContactsScreenForContacts];

    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)openContactScreenFroMail
{
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc]init];
    NSPredicate *enablePredicate = [NSPredicate predicateWithFormat:@"(emailAddresses.@count > 0)"];
    contactPicker.predicateForEnablingContact = enablePredicate;
    contactPicker.delegate = self;
    _isMailContactSelected = YES;
    [self presentViewController:contactPicker animated:NO completion:nil];
}


-(void)openContactsScreenForContacts
{
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc]init];
    
//    NSArray *propertyKeys = @[CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactOrganizationNameKey];
    NSPredicate *enablePredicate = [NSPredicate predicateWithFormat:@"(phoneNumbers.@count > 0)"];
//    NSPredicate *contactSelectionPredicate = [NSPredicate predicateWithFormat:@"phoneNumbers.@count == 1"];
    
//    contactPicker.displayedPropertyKeys = propertyKeys;
    contactPicker.predicateForEnablingContact = enablePredicate;
//    contactPicker.predicateForSelectionOfContact = contactSelectionPredicate;

    contactPicker.delegate = self;
    _isMailContactSelected = NO;
    [self presentViewController:contactPicker animated:NO completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
//    self.tableViee.estimatedRowHeight = 70.0;
//    self.tableViee.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Conatact picker Delegate

-(void)contactPickerDidCancel:(CNContactPickerViewController *)picker
{
    
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *phoneList = [[NSMutableArray alloc]init];
    
    
    if (_isMailContactSelected) {
        
        if ([contact isKeyAvailable:CNContactEmailAddressesKey]) {
            
            for (NSInteger i =0; i<contact.emailAddresses.count; i++) {
                
                [phoneList addObject:[[contact.emailAddresses objectAtIndex:i] value]];
                
            }
            
            
        }
    }else{
        
        if ([contact isKeyAvailable:CNContactPhoneNumbersKey]) {
            
            NSLog(@"%@", [[[contact.phoneNumbers objectAtIndex:0] value] valueForKey:@"digits"]);
            
            for (NSInteger i =0; i<contact.phoneNumbers.count; i++) {
                
                [phoneList addObject:[[[contact.phoneNumbers objectAtIndex:i] value] valueForKey:@"digits"]];
                
            }
            
        }
        
        
    }

    
    if (phoneList.count != 0) {
        
        if (_isMailContactSelected) {
            
            [self sendMails:phoneList];
        }else{
            
            [self sendMessages:phoneList];

        }
        
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"No contacts selected" message:@"Please select atleast one contact to send invites" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }
    
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *phoneList = [[NSMutableArray alloc]init];
    
    
    if (_isMailContactSelected) {
        
        for (CNContact *contact in contacts) {
            
                if ([contact isKeyAvailable:CNContactEmailAddressesKey]) {
                    
                    for (NSInteger i =0; i<contact.emailAddresses.count; i++) {
                        
                        [phoneList addObject:[[contact.emailAddresses objectAtIndex:i] value]];
                        
                    }
                    
                }
                
            }
    }else{
        
        
        
        for (CNContact *contact in contacts) {
            
            if ([contact isKeyAvailable:CNContactPhoneNumbersKey]) {
                
                for (NSInteger i =0; i<contact.phoneNumbers.count; i++) {
                    
                    [phoneList addObject:[[[contact.phoneNumbers objectAtIndex:i] value] valueForKey:@"digits"]];
                    
                }
                
            }
        }
    }
    
    if (phoneList.count != 0) {
        
        if (_isMailContactSelected) {
            
            [self sendMails:phoneList];
        }else{
            
            [self sendMessages:phoneList];
            
        }

        
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
        [controller didMoveToParentViewController:self];
        [self presentModalViewController:controller animated:YES];

    }

}

-(void)sendMails: (NSArray *)contactList
{
    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:@"Invitations for Closed1"];
        [mailCont setToRecipients:contactList];
        [mailCont setMessageBody:@"Please install the app by clicking on below link." isHTML:NO];
        
        [self presentModalViewController:mailCont animated:YES];
        
    }

}

#pragma mark - Message Delegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultCancelled){
        NSLog(@"Message cancelled");
    }
    else if (result == MessageComposeResultSent){
        NSLog(@"Message sent");
    }
    else{
        NSLog(@"Message failed");
    }
    [self dismissViewControllerAnimated:YES completion:nil];

}
#pragma mark - Mail composer Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ContactsTableViewCell *contactsCell = [tableView dequeueReusableCellWithIdentifier:@"ContactsTableViewCell"];
    contactsCell.profileImage.image = [UIImage imageNamed:@"male-circle-128.png"];
    contactsCell.nameLabel.text = @"John Doe";
    contactsCell.companyLabel.text = @"Google LLC";
    contactsCell.titleLabel.text = @"iOS Developer";
    
    return contactsCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ProfileDetailViewController *profileDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileDetailViewController"];
    
    [self.navigationController pushViewController:profileDetail animated:YES];
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Block" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
                                        NSLog(@"Action to perform with Button 1");
        
        
        
        
                                    }];
    button.backgroundColor = [UIColor yellowColor]; //arbitrary color
    UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
                                         NSLog(@"Action to perform with Button2!");
        
                                     }];
    button2.backgroundColor = [UIColor redColor];
    
    return @[button, button2];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma mark - Set as YES to add swipe Functionality
    return NO;
}





@end
