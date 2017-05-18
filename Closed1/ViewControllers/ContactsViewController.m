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
#import "ContactDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "UIImageView+WebCache.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "ClosedResverResponce.h"
#import "UserDetails+CoreDataClass.h"
#import "MBProgressHUD.h"
#import "FreindRequestViewController.h"
#import "NZTourTip.h"
#import "AddFreindsViewController.h"
#import "Closed1-Swift.h"
#import "Closed1-Bridging-Header.h"


@interface ContactsViewController ()<CNContactPickerDelegate,MFMessageComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIViewControllerTransitioningDelegate, ServerFailedDelegate, FreindsListDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViee;
@property(nonatomic) BOOL isMailContactSelected;

@property(nonatomic) NSArray *contactDetails;

@property(nonatomic) UIButton *freindRequest;
@property(nonatomic) UIButton *invitesButton;
@property(nonatomic) UIButton *addFreinds;
@property(nonatomic) AddFreindsViewController *addFreind;

@property (nonatomic , retain) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic , retain) NSFetchedResultsController * searchedFRC;
@property(nonatomic)     NSString * globalPredicateString;



@end

@implementation ContactsViewController



- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    
    [self createCustumNavigationBar];
    
    self.tableViee.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [self.tableViee registerNib:[UINib nibWithNibName:@"ContactsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactsTableViewCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ContactsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactsTableViewCell"];
    
    [ContactDetails MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    self.searchDisplayController.searchResultsTableView.estimatedRowHeight = 90;
    self.searchDisplayController.searchResultsTableView.rowHeight = 90;
   
    self.addFreind = [self.storyboard instantiateViewControllerWithIdentifier:@"AddFreindsViewController"];
}

-(void)getContactViewData
{
    UserDetails *userDetails = [UserDetails MR_findFirst];
    [ClosedResverResponce sharedInstance].delegate = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Fetching Contacts";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
#pragma mark - Remove Demo Code
        
        
        NSArray * arrayOfContacts = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=get_contacts&user_id=%lld", userDetails.userID] DictionartyToServer:@{}];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //            NSArray *arrayOfContacts = [self getDataFromLocalJSONFileForEntity:@"Contacts"];
            if ([[arrayOfContacts valueForKey:@"success"] integerValue] == 1) {
                
                
                
                NSArray *contactList = [arrayOfContacts valueForKey:@"data"];
                
                
                for (NSDictionary * entity in contactList) {
                    
                    ContactDetails *userContact = [ContactDetails MR_findFirstByAttribute:@"userID" withValue:[entity valueForKey:@"user_id"]];
                    
                    if (userContact == nil) {
                        
//                        if (![[entity valueForKey:@"company"] isEqual:[NSNull null]] && ![[entity valueForKey:@"title"] isEqual:[NSNull null]] && ![[entity valueForKey:@"profile_image_url"] isEqual:[NSNull null]] && ![[entity valueForKey:@"user_id"] isEqual:[NSNull null]] && ![[entity valueForKey:@"contact"] isEqual:[NSNull null]] && ![[entity valueForKey:@"title"] isEqual:[NSNull null]]) {
                        
                            ContactDetails *contact = [ContactDetails MR_createEntity];
                            contact.company = [entity valueForKey:@"company"];
                            contact.designation = [entity valueForKey:@"title"];
                            contact.imageURL = [entity valueForKey:@"profile_image_url"];
                            contact.userID = [[entity valueForKey:@"user_id"] integerValue];
                            contact.userName = [entity valueForKey:@"contact"];
                            contact.title = [entity valueForKey:@"title"];
                        }
                        
//                    }
            }
                
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                if (contactList.count != 0) {
                    [self.fetchedResultsController performFetch:nil];
                    [self.tableViee reloadData];

                }

            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"It seems that no contacts has been added in your account yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if(![[NSUserDefaults standardUserDefaults]boolForKey:@"FirstTimeExperienceContacts"])
            {
                NZTourTip * jgTourTip = [[NZTourTip alloc]initWithViews:@[_freindRequest, _invitesButton, _addFreinds] withMessages:@[@"Tap this to display the pending freind request", @"Tap this to send invites to people to use Closed1 app", @"Tap this to add freinds which are using closed1"] onScreen:self.view];
                [jgTourTip showTourTip];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"FirstTimeExperienceContacts"];
            }

            
        });
        
    });
    
    
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
    
    _invitesButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_invitesButton setImage:[UIImage imageNamed:@"InviteFreinds"] forState:UIControlStateNormal];
    [_invitesButton addTarget:self action:@selector(pickContactMethod) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *contact = [[UIBarButtonItem alloc]initWithCustomView:_invitesButton];;
    
    self.addFreinds = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_addFreinds setImage:[UIImage imageNamed:@"AddIndivisual"] forState:UIControlStateNormal];
    [_addFreinds addTarget:self action:@selector(addFreindList) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *adddFreind = [[UIBarButtonItem alloc]initWithCustomView:self.addFreinds];
    
    
    navItem.rightBarButtonItems = @[contact, adddFreind];
    
    _freindRequest = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_freindRequest setImage:[UIImage imageNamed:@"FreinfReuest"] forState:UIControlStateNormal];
    [_freindRequest addTarget:self action:@selector(openFreingRequestScreen) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *freinds = [[UIBarButtonItem alloc]initWithCustomView:_freindRequest];
    navItem.leftBarButtonItem = freinds;
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Contacts"];
    [self.view addSubview:navBar];
    
//    [self.navigationController setNavigationBarHidden:NO];
//    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"DEMO" style:UIBarButtonItemStylePlain target:self action:@selector(pickContactMethod)];
    
    
    
}
    
     
-(void)addFreindList
{
    
    [self.navigationController pushViewController:_addFreind animated:YES];
}

-(void)openFreingRequestScreen
{
    FreindRequestViewController  *freinds = [self.storyboard instantiateViewControllerWithIdentifier:@"FreindRequestViewController"];
    freinds.delegate = self;
    [self.navigationController pushViewController:freinds animated:YES];
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
    
    OpenAdressBook *addressBook = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenAdressBook"];
    [self.navigationController pushViewController:addressBook animated:YES];
    

    
    
    
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc]init];
    
    //    NSArray *propertyKeys = @[CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactOrganizationNameKey];
    NSPredicate *enablePredicate = [NSPredicate predicateWithFormat:@"(phoneNumbers.@count > 0)"];
    //    NSPredicate *contactSelectionPredicate = [NSPredicate predicateWithFormat:@"phoneNumbers.@count == 1"];
    
    //    contactPicker.displayedPropertyKeys = propertyKeys;
    contactPicker.predicateForEnablingContact = enablePredicate;
    //    contactPicker.predicateForSelectionOfContact = contactSelectionPredicate;
    
    contactPicker.delegate = self;
    _isMailContactSelected = NO;
    //[self presentViewController:contactPicker animated:NO completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self createCustumNavigationBar];
    
    [self tableViewReloadDataWithAnimation:YES];
    
    _contactDetails = [ContactDetails MR_findAll];
    
    if (_contactDetails.count == 0) {
        
        [self getContactViewData];
        
        
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO];

}


-(void)tableViewReloadDataWithAnimation:(BOOL)animate
{
    CATransition *transition;
    if(animate)
    {
        transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.fillMode = kCAFillModeForwards;
        transition.duration = 0.3;
        transition.subtype = kCATransitionFromTop;
        
        [self.tableViee.layer addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
    }
    
    [self.tableViee reloadData];
    
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
        controller.body = @"Hi, I would like to invite you to join me on Closed1 to help each other close more deals! Please see the link below to join";
        controller.recipients = filteredContacts;
        controller.messageComposeDelegate = self;
        [controller didMoveToParentViewController:self];
        [self presentViewController:controller animated:YES completion:nil];
        
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"Sorry you cannot send message" message:@"It seems that you haven't installed sim in your device or Airplone maode is turn ON." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
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
        [mailCont setMessageBody:@"Hi, I would like to invite you to join me on Closed1 to help each other close more deals! Please see the link below to join" isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
        
    }else{
        [[[UIAlertView alloc]initWithTitle:@"Sorry you cannot send mail" message:@"It seems the mail is not setup im your device Please configure your mail ." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];

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
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Tableview delegate

#pragma mark - TableView DataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
#ifdef DEBUG
        
        NSLog(@"%lu",(unsigned long)[[_searchedFRC sections]count]);
#endif
        return [[_searchedFRC sections] count];
    }
    else
    {
#ifdef DEBUG
        
        NSLog(@"%lu",(unsigned long)[[_fetchedResultsController sections]count]);
#endif
        return [[_fetchedResultsController sections]count];
    }
    
}


- (NSArray *) sectionIndexTitlesForTableView: (UITableView *) tableView
{
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
#ifdef DEBUG
        
        NSLog(@"%lu",(unsigned long)[[self.searchedFRC sectionIndexTitles] count]);
#endif
        return [self.searchedFRC sectionIndexTitles];
    }
    else
    {
#ifdef DEBUG
        
        NSLog(@"%lu",(unsigned long)[[self.fetchedResultsController sectionIndexTitles] count]);
#endif
        return [self.fetchedResultsController sectionIndexTitles];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchedFRC sectionForSectionIndexTitle:title atIndex:index];
        
    }
    else
    {
        return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        NSArray * titleArray = [self.searchedFRC sectionIndexTitles];
        return [titleArray objectAtIndex:section];
        
    }
    else
    {
        NSArray * titleArray = [self.fetchedResultsController sectionIndexTitles];
        return [titleArray objectAtIndex:section];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        id sectionInfo = [[_searchedFRC sections] objectAtIndex:section];
#ifdef DEBUG
        
        NSLog(@"Number of Rows in SearchDisplayController.tableview : %lu",(unsigned long)[sectionInfo numberOfObjects]);
#endif
        return [sectionInfo numberOfObjects];
    }
    else
    {
        id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
#ifdef DEBUG
        
        NSLog(@"%lu",(unsigned long)[sectionInfo numberOfObjects]);
#endif
        return [sectionInfo numberOfObjects];
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ContactDetails * contact;
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        contact = [_searchedFRC objectAtIndexPath:indexPath];
    }
    else
    {
        contact = [_fetchedResultsController objectAtIndexPath:indexPath];
        
    }
    
    
    ContactsTableViewCell *contactsCell = [tableView dequeueReusableCellWithIdentifier:@"ContactsTableViewCell"];
    NSString *imageURL = contact.imageURL;
    NSString* urlEncoded = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [contactsCell.profileImage sd_setImageWithURL:[NSURL URLWithString:urlEncoded] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    contactsCell.nameLabel.text = contact.userName;
    contactsCell.companyLabel.text = contact.company;
    contactsCell.titleLabel.text = contact.designation;
    
    return contactsCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ProfileDetailViewController *profileDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileDetailViewController"];
    
    ContactDetails * contact;
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        contact = [_searchedFRC objectAtIndexPath:indexPath];
    }
    else
    {
        contact = [_fetchedResultsController objectAtIndexPath:indexPath];
        
    }
    
    //    profileDetail.singleContact = contact;
    profileDetail.userid = contact.userID;
    
    
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


-(NSArray *)getDataFromLocalJSONFileForEntity:(NSString *)entityName
{
    NSString * filePath = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@",entityName] ofType:@"json"];
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataFromlLocal = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    return dataFromlLocal;
}



#pragma mark - NSFetchedResultControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableViee beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    //    if(YES)
    //    {
    //        return;
    //    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableViee insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableViee deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case  NSFetchedResultsChangeUpdate:
            //TODOURGENT change the cell only
            //     [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViee deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableViee insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableViee;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
            
        case NSFetchedResultsChangeMove:
            
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableViee endUpdates];
}


#pragma mark - Initialize Fetchresult Controller
- (NSFetchedResultsController *)fetchedResultsController {
    return [self configureFetchedResultsControllerForProvider];
}


//Get fetched Result controller for Providers
-(NSFetchedResultsController *)configureFetchedResultsControllerForProvider
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userName" ascending:NO];
    NSFetchRequest *fetchRequest = [ContactDetails MR_requestAll];
    [fetchRequest setSortDescriptors:@[nameSortDescriptor]];
    
    //[fetchRequest setFetchLimit:100];         // Let's say limit fetch to 100
    [fetchRequest setFetchBatchSize:20];      // After 20 are faulted
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:@"firstLetter" cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    self.fetchedResultsController.delegate = (id)self;
    return _fetchedResultsController;
}



#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _searchedFRC = nil;
    NSString * predicateString = @"";
    NSArray * searchStringArray = [searchString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    searchStringArray = [searchStringArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ' '"]];
    for(NSString *searchStringComponent in searchStringArray)
    {
        //On filtering array on blank string is there in one of the component
        if(searchStringComponent.length > 0)
            predicateString = [NSString stringWithFormat:@" %@ (userName beginswith[c] \"%@\" || company beginswith[c] \"%@\" || designation beginswith[c] \"%@\")  &&",predicateString,searchStringComponent,searchStringComponent,searchStringComponent];
    }
    
    
    
    
    
    
    if(_globalPredicateString.length > 0)
    {
        //Predicatestring already has && operator in the end from above code
        predicateString = [NSString stringWithFormat:@"%@ %@",predicateString,_globalPredicateString];
    }
    else if (predicateString.length > 0)
        predicateString = [predicateString substringToIndex:predicateString.length - 3];
    else
        predicateString = nil;
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    NSFetchRequest * fetchRequestForSearchString = [ContactDetails MR_requestAllSortedBy:@"userName" ascending:YES withPredicate:predicate];
    //    NSArray * array = [Provider findAllWithPredicate:predicate];
    
    [fetchRequestForSearchString setFetchBatchSize:20];
    NSFetchedResultsController *searchedFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequestForSearchString managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:@"firstLetter" cacheName:nil];
    _searchedFRC = searchedFetchedResultsController;
    _searchedFRC.delegate = (id)self;
    [_searchedFRC performFetch:nil];
    
    
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Server Failed Dlegates
-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    });}

#pragma mark - Freind List Delegate

-(void)freindListAddedSucessFully
{
    [ContactDetails MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [self getContactViewData];
}

@end
