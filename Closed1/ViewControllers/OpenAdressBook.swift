//  ViewController.swift
//  ASCStatus8.0
//
//  Created by Nazim Siddiqui on 29/01/16.
//  Copyright © 2016 Kratin. All rights reserved.
//

protocol setDataInTableViewDelegate
{
    func selectedData(_ name: [String], number: [String], image: [Data])
}




import UIKit
import AddressBookUI
import ContactsUI

public var selectedName: [String] = []
public var selectedNumber: [String] = []
public var selectedIndex: [Int] = []
var count = 0
//public var selectedRow: [NSIndexPath] = []


/// class to open address book fetch data sort them and display on tableview
@objc class OpenAdressBook: UIViewController, ABPeoplePickerNavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, UIScrollViewDelegate{
    
   
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var nameArray:[String] = []
    var numberArray: [String] = []
    var allPeople: NSArray!
    var isvisible = false
    var contactDictionary = Array<[String:AnyObject]>()
    var delegate: setDataInTableViewDelegate!
    var nameOfSeacrhBar: [String] = []
    var filterednameSecarh =  Array<[String:AnyObject]>()
    var titleForTableView = Array<String>()
    var countForSection = Array<Int>()
    
    public var isMailContactSelected: Bool = false
    
    
    let contactAccessPermissionAlertTitle = "Cannot Access Contacts"
    let contactAccessPermissionAlertMessage = "You must give the app permission to access the contacts."
    let contactAccessPermissionAlertActionLabel = "Change Settings"
    
    
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nib2 = UINib(nibName: "ShortDescription", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "cell1")
        
        self.searchDisplayController?.searchResultsTableView.estimatedRowHeight = 90;
        self.searchDisplayController?.searchResultsTableView.rowHeight = 90;
        self.searchDisplayController?.searchResultsTableView.register(nib2, forCellReuseIdentifier: "cell1")
        
        tableView.setEditing(true, animated: false)
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        
//        [self.theTableView setContentInset:UIEdgeInsetsMake(0, self.theTableView.contentInset.left, self.theTableView.contentInset.bottom, self.theTableView.contentInset.right)];
        
//        self.tableView.contentInset = UIEdgeInsets(top: 0, left:  self.tableView.contentInset.left, bottom:  self.tableView.contentInset.bottom, right:  self.tableView.contentInset.right)
        
        
    }
    
    
    /**
     Function to close the currrent view controller ie on tapping submit button this function is called
     */
    func dismissModal()
    {
        
        
        
//
            let selectedRows = tableView.indexPathsForSelectedRows!;
        
        if selectedRows.count != 0 {
            for rows in selectedRows{
                
                selectedName.append((filterednameSecarh[rows.row]["Name"] as? String)!)
                selectedNumber.append((filterednameSecarh[rows.row]["Number"] as? String)!)
                
                
            }
            
            print("%@",selectedName)
            print("%@",selectedNumber)

        
            
            
                    if self.delegate != nil{
                        
                        
                    }
            
            self.navigationController?.popViewController(animated: true)
            
        }else
        {
            UIAlertView(title: "Cannot send empty records", message: "", delegate: nil, cancelButtonTitle: "Ok").show()
            
        }
    }
    
    
    /**
     checking permission of contacts and assigning data to filter array for searching
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
       createCustumNavigationBar()
    
    
        
        checkABPermission()

        //Refresh addressbook
        if(ABAddressBookGetAuthorizationStatus() == .authorized){
            allPeople = AdressBookAscStatus.sharedInstance().getAllContacts(true)
            configureSeracgBar()
            sortFilteredContacts()
            getTableViewSectionTitle()
            tableView.reloadData()
            
            
        }
        
      
    }
    
    func createCustumNavigationBar()
    {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let navBar = UINavigationBar(frame: CGRect(x: self.view.bounds.origin.x-10, y: self.view.bounds.origin.y , width: self.view.frame.size.width + 10, height: 60))
        let navItem = UINavigationItem()
        
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(dismissModal))
            navItem.rightBarButtonItem = addButton
        navBar.items = [navItem]
        navBar.barTintColor = UIColor(red: 38.0/255.0, green: 166.0/255.0, blue: 154.0/255.0, alpha: 1.0)
        navBar.tintColor = UIColor.white
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navItem.title = "Contacts"
        self.view.addSubview(navBar)
        
    }
    
    func backTapped()
    {
 self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addContactsTapped(_ sender: Any) {
        
        dismissModal()
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        
    }
    
    
    /**
     Filter contacts according to name
     */
    func sortFilteredContacts()
    {
        filterednameSecarh.sort { (firstObject, secondObject) -> Bool in
            return (firstObject["Name"] as! String) < (secondObject["Name"] as! String)
        }
    }
    
    
    /**
     to get section header ie alphabets on the header of tableview
     */
    func getTableViewSectionTitle()
    {
        
        titleForTableView = Array<String>()
        countForSection = Array<Int>()
        for contactDictionary in filterednameSecarh
        {
            let firstCharacterOfArray =     (contactDictionary["Name"] as! String).substring(to: (contactDictionary["Name"] as! String).characters.index(after: (contactDictionary["Name"] as! String).startIndex))
            
            if !titleForTableView.contains(firstCharacterOfArray)
            {
                countForSection.append(1)
                titleForTableView.append(firstCharacterOfArray)
            }
            else
            {
                let lastValue = countForSection.last! + 1
                countForSection.removeLast()
                countForSection.append(lastValue)
            }
            
            
        }
        
    }
    
    /**
     configure seacrch bar
     */
    func configureSeracgBar()
    {
//        contactDictionary =  Array<[String:AnyObject]>()
        filterednameSecarh = Array<[String:AnyObject]>()
        searchBar.delegate = self
        
        
        self.filterednameSecarh = self.contactDictionary
        
        searchBar.placeholder = "Search Name"
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    
    /**
     deleting the data when this view controller is not displayed
     */
    override func viewDidDisappear(_ animated: Bool) {
        self.searchBar.text = ""
        contactDictionary.removeAll()
        filterednameSecarh.removeAll()
        tableView.reloadData()
        searchBar.resignFirstResponder()
        self.navigationController?.popoverPresentationController
        
    }
    
    
    /**
     Checking the calendar acess permission
     */
    func checkABPermission(){
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authorizationStatus {
        case .denied, .restricted:
            displayContactAccessAlert()
            
        case .authorized:
            
            print("AB Access Authorized")
            allPeople = AdressBookAscStatus.sharedInstance().getAllContacts(false)
            manageContacts()
            tableView.reloadData()
            
            
        case .notDetermined:
            
            print("Not Determined")
            promptForAddressBookRequestAccess()
        }
        
        
        
    }
    
    
    /**
     Display our custon alert when permission is denied and to open the settings for allowing permission
     */
    func displayContactAccessAlert() {
        let cantAccessContactAlert = UIAlertController(title: GlobalConstant.calendarAccessPermissionAlertTitle,
            message: GlobalConstant.calendarAccessPermissionAlertMessage,
            preferredStyle: .alert)
        
        let addBuutonInAlert = UIAlertAction(title: GlobalConstant.calendarAccessPermissionAlertActionButton, style: .default, handler: { (action: UIAlertAction) -> Void in
            
            AdressBookAscStatus.sharedInstance().openSettings()
            self.dismiss(animated: true, completion: nil)
        })
        let cancelBuutonInAlert = UIAlertAction(title: GlobalConstant.calendarDeniedPermissionAlertActionButton, style: .default, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        cantAccessContactAlert.addAction(cancelBuutonInAlert)
        cantAccessContactAlert.addAction(addBuutonInAlert)
        present(cantAccessContactAlert, animated: true, completion: nil)
    }
    
    
    
    /**
     To display first time alert message provided by iOS for accessing the calendar
     */
    func promptForAddressBookRequestAccess(){
        
        ABAddressBookRequestAccessWithCompletion(AdressBookAscStatus.getSingleAddressBookReference()) {
            (granted: Bool, error: CFError!) in
            DispatchQueue.main.async {
                if !granted {
                    // print("Just denied")
                } else {
                    // print("Just authorized")
                    //Get all contacts from the list as now we have access
                    //  self.getAllContacts(AddressBookHandler.getSingleAddressBookReference())
                    self.allPeople = AdressBookAscStatus.sharedInstance().getAllContacts(true)
                    self.manageContacts()
                    
                }
            }
        }
    }
    
    
    /**
     To open setting for allowing calendar acess permission
     */
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    
   
    
    
    
    //MARK:- Tableview delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return countForSection[section]
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return titleForTableView.count
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForTableView[section]
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 35))
//        headerView.backgroundColor = UIColor(red: 247 / 255.0, green: 247 / 255.0, blue: 247 / 255.0, alpha: 1.0)
//        let labelText = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 35))
//        labelText.backgroundColor = UIColor(red: 247 / 255.0, green: 247 / 255.0, blue: 247 / 255.0, alpha: 1.0)
//        labelText.text = titleForTableView[section];
//        
//        headerView.addSubview(labelText)
//        
//        return headerView;
//        
//    }
//    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        count += 1
        /// To remove the selected tableview default blue color
        let cell = tableView.cellForRow(at: indexPath)
        let backGroundView = UIView()
        backGroundView.backgroundColor = UIColor.clear
        cell!.selectedBackgroundView = backGroundView
        
        
       
//            var indexOfContact:Int = 0
//            
//            for i in 0  ..< indexPath.section 
//            {
//                indexOfContact += countForSection[i]
//            }
//            
//            indexOfContact += indexPath.row == 0 ? 0 : indexPath.row - 1
//            
//            
//            selectedName.append((filterednameSecarh[indexOfContact]["Name"] as? String)!)
//            
//            selectedNumber.append((filterednameSecarh[indexOfContact]["Number"] as? String)!)
//            
//            print(indexOfContact)
//            selectedIndex.append(indexOfContact)
//            print(selectedIndex)
//            
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        count -= 1
        
//            var indexOfContact:Int = 0
//            
//            for i in 0  ..< indexPath.section 
//            {
//                indexOfContact += countForSection[i]
//            }
//            
//            indexOfContact += indexPath.row == 0 ? 0 : indexPath.row - 1
//            
////            for count in 0 ..< allContacts.count+1
//            
//            for count in 0 ..< selectedIndex.count
//            {
//                if selectedIndex[count] == indexOfContact
//                {
//                    selectedIndex.remove(at: count)
//                }
//            }
//            
//            for count in 0 ..< selectedNumber.count
//            {
//                if filterednameSecarh[indexOfContact]["Number"] as? String == selectedNumber[count]
//                {
//                    selectedNumber.remove(at: count)
//                    selectedName.remove(at: count)
//                    
//                }
//            }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! ShortDescription
        
        cell.accessoryType = .none
        
        
        //
        //        self.tableView.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        
        
        // let person: ABRecordRef = allPeople[indexPath.row]
        
        // cell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        //        let firstNameOfContact = AddressBookHandler.getNameOfPersonForContactsTable(person).fristName
        //        let lastNameOfContact = AddressBookHandler.getNameOfPersonForContactsTable(person).lastName
        //
        //        let numberOfContact = AddressBookHandler.getAllNumbersOfContact(person)
        //
        //        var emailOfContact = AddressBookHandler.getAllEmailsOfContacts(person)
        //
        //        if emailOfContact != [""]
        //        {
        //            emailOfContact.append("No email")
        //        }
        //        var numbers: String = ""
        //
        //        for  number in numberOfContact{
        //            numbers.appendContentsOf(number)
        //
        //        }
        
        //        print(numberOfContact)
        
        
        cell.tintColor = self.view.tintColor
        
        
        
        var indexOfContact:Int = 0
        
        for i in 0  ..< indexPath.section 
        {
            indexOfContact += countForSection[i]
        }
        
        indexOfContact += indexPath.row == 0 ? 0 : indexPath.row - 1
        
        
        cell.nameLabel.text = filterednameSecarh[indexOfContact]["Name"] as? String
        cell.emailLabel.text = filterednameSecarh[indexOfContact]["Number"] as? String
        
        //        cell.imageLabel.image = UIImage(data: (filterednameSecarh[indexPath.row]["Image"] as? NSData)!)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return titleForTableView.index(of: title)!
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return titleForTableView
    }
    
    
    
    
    
    //MARk:- Seacgbar delegate method
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filterTableViewForEnteredText(searchText)
        sortFilteredContacts()
        
        getTableViewSectionTitle()
        tableView.reloadData()
    }
    
    /**
     To search the elments from the given array
     
     - parameter searchText: entered text by user
     */
    func filterTableViewForEnteredText(_ searchText:String)
    {
        if searchText.isEmpty
        {
            filterednameSecarh = contactDictionary
            return
        }
        
        filterednameSecarh = contactDictionary.filter({ (contact) -> Bool in
            
            let contactName = contact["Name"] as! String
            let contactNumber = contact["Number"] as! String
            return contactName.lowercased().contains(searchText.lowercased()) || self.removeSpecialSymbolFromPhoneNumberString(contactNumber).contains(searchText) || contactNumber.contains(searchText)
        })
    }
    
    /**
     remove special symbol from phone number while seaching ie +91, or - containing in number
     
     - parameter number: phone number
     
     - returns: pure number format digits withour any symbol in it
     */
    func removeSpecialSymbolFromPhoneNumberString(_ number:String) -> String
    {
        //        NSCharacterSet *setToRemove =
        //            [NSCharacterSet characterSetWithCharactersInString:@"0123456789 "];
        //        NSCharacterSet *setToKeep = [setToRemove invertedSet];
        //
        //        NSString *newString =
        //        [[someString componentsSeparatedByCharactersInSet:setToKeep]
        //        componentsJoinedByString:@""];
        
        let characterSetToRemove = CharacterSet(charactersIn: "0123456789")
        let characterSetToKeep = characterSetToRemove.inverted
        let phoneNumberWithoutSpecialCharacters = number.components(separatedBy: characterSetToKeep).joined(separator: "")
        return phoneNumberWithoutSpecialCharacters
    }
    
    
    /**
     To sort the contacts fetched from contact database
     */
    func manageContacts()
    {
        for count in 0 ..< allPeople.count{
            
            
            var singleDictionary = [String: AnyObject]()
            
            let contact = allPeople[count]
            
            let firstNameOfContact = AdressBookAscStatus.getNameOfPersonForContactsTable(contact as ABRecord).fristName
            let lastNameOfContact = AdressBookAscStatus.getNameOfPersonForContactsTable(contact as ABRecord).lastName
            
            let numberOfContact = AdressBookAscStatus.getAllNumbersOfContact(contact as ABRecord)
            
            
            let numberOfEmails = AdressBookAscStatus.getAllEmailsOfContacts(contact as ABRecord)
            
            
            if isMailContactSelected {
                
                if  numberOfEmails.count != 0{
                                if numberOfEmails[0] != ""{
                    
                                    singleDictionary["Name"] = (firstNameOfContact + " "+lastNameOfContact as AnyObject)
                    
                                    singleDictionary["Number"] = numberOfEmails[0] as AnyObject
                    
                                    contactDictionary.append(singleDictionary)
                                }
                            }
                
            }else{
                
                if numberOfContact[0] != ""{
                    
                    singleDictionary["Name"] = (firstNameOfContact + " "+lastNameOfContact as AnyObject)
                    singleDictionary["Number"] = numberOfContact[0] as AnyObject
                    
                    contactDictionary.append(singleDictionary)
                    
                }

            }
            
//
            
            
            
        }
        
        tableView.reloadData()
        
    }
    
    
    func attributedText(_ originalString: NSString, stringToBebold: NSString)->NSAttributedString{
        
        
        
        let attributedString = NSMutableAttributedString(string: originalString as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15.0)])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)]
        
        attributedString.addAttributes(boldFontAttribute, range: originalString.range(of: stringToBebold as String))
        
        return attributedString
        
        
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .insert
    }
    
    
    
  
    
}
