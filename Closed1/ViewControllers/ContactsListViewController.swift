//
//  ContactsListViewController.swift
//  Closed1
//
//  Created by Nazim on 19/05/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

import UIKit
import MessageUI

extension String {
    var first: String {
        return String(characters.prefix(1))
    }
    var last: String {
        return String(characters.suffix(1))
    }
    var uppercaseFirst: String {
        return first.uppercased() + String(characters.dropFirst())
    }
}

@objc protocol ContactsSelectedProtocol: class {
    func contactsSelectedEmail(_ email: String)
}

@objc class ContactsListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,UISearchDisplayDelegate,UISearchBarDelegate,MFMailComposeViewControllerDelegate,UIViewControllerTransitioningDelegate,ServerFailedDelegate,FreindsListDelegate,setDataInTableViewDelegate,MailSendDelegates {
    

   
    @IBOutlet weak var tableViewTopConstarint: NSLayoutConstraint!
    @IBOutlet weak var freinfReeustCountLabel: UILabel!

    @IBOutlet weak var freindRequestCountView: UIView!

    @IBOutlet weak var canceButton: UIButton!
    
    var contactDictionary = Array<[String:AnyObject]>()
    var delegate: setDataInTableViewDelegate!
    var nameOfSeacrhBar: [String] = []
    var filterednameSecarh =  Array<[String:AnyObject]>()
    var titleForTableView = Array<String>()
    var countForSection = Array<Int>()
    var refreshControl: UIRefreshControl!

    
    @IBOutlet weak var  freindRequest: UIButton!
    @IBOutlet weak var  invitesButton: UIButton!
    @IBOutlet weak var  addFreinds: UIButton!
    var ismailSelected: Bool!

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var iscameFromChatScreen : Bool = false
    weak var chatsDelegate: ContactsSelectedProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib2 = UINib(nibName: "ContactsTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "ContactsTableViewCell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.getFriendListFromServer),
            name: NSNotification.Name(rawValue: "BlockingUserNotification"),
            object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FreindRequestCountRecivedFromServer), name: NSNotification.Name(rawValue: ""), object: nil)
        
        
        
        if(self.iscameFromChatScreen){

            self.tableViewTopConstarint.constant = 0;
        }else{
            self.tableViewTopConstarint.constant = -20;

        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.getFriendListFromServer), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl) // not required when using UITableViewController
        
        getFriendListFromServer()
    }
    
    
    func FreindRequestCountRecivedFromServer() -> Void {
        
        if(iscameFromChatScreen){
            
            self.freindRequest.isHidden = true;
            self.freindRequestCountView.isHidden = true;
            self.addFreinds.isHidden = true;
            self.invitesButton.isHidden = true;
            self.canceButton.isHidden = false;
            
        }else{
            createCustumNavigationBar()
            self.freindRequest.isHidden = false;
            self.freindRequestCountView.isHidden = false;
            self.addFreinds.isHidden = false;
            self.invitesButton.isHidden = false;
            self.canceButton.isHidden = true;
            
            let freingRequestCount = UserDefaults.standard.integer(forKey: "FreindRequestCount")
            
            
            if freingRequestCount>0 {
                
                self.freinfReeustCountLabel.text = "\(freingRequestCount)";
                self.freindRequestCountView.isHidden = false;
                self.freinfReeustCountLabel.isHidden = false;
                self.tabBarItem.badgeValue = "\(freingRequestCount)";
                
            }else{
                
                self.freindRequestCountView.isHidden = true;
                self.freinfReeustCountLabel.isHidden = true;
                self.tabBarItem.badgeValue = nil;
                
                
            }
            
            UIApplication.shared.applicationIconBadgeNumber = freingRequestCount;
        }
        
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
   func getFriendListFromServer()
    {
        self.contactDictionary.removeAll();
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.dimBackground = true;
        hud.labelText = "Fetching Contacts";
        
        DispatchQueue.global(qos: .default).async{
            var dataFromServer:[String:AnyObject]?
            dataFromServer = self.getDataFromServer()
            
            print("%@", dataFromServer!)
            
            if dataFromServer != nil {
                
                if dataFromServer?["success"] as! NSInteger == 1{
                    
                    var contactListArray: Array<[String:AnyObject]>
                    contactListArray = (dataFromServer?["data"] as? Array<[String: AnyObject]>)!
                    
                    print(contactListArray)
                    
                    for entity in contactListArray {
                        
                        var singleDictionary = [String: AnyObject]()
                        
                        print(entity);
                        
                        var nameOFContact = entity["contact"] as! String;
                        
                        print("Before Name was: \(nameOFContact)");
                        
                        nameOFContact =  nameOFContact.uppercaseFirst;
                        
                        print(nameOFContact.uppercaseFirst);
                        
                        singleDictionary["Name"] = nameOFContact.uppercaseFirst as AnyObject
                        
                        singleDictionary["Number"] = entity["company"]
                        
                        singleDictionary["title"] = entity["title"]
                        
                        singleDictionary["imageURL"] = entity["profile_image_url"]
                        singleDictionary["user_id"] = entity["user_id"];
                        singleDictionary["user_email"] = entity["user_email"];

                        
                        self.contactDictionary.append(singleDictionary)
                    }
                    
                    DispatchQueue.main.async() {
                        self.configureSeracgBar()
                        self.sortFilteredContacts()
                        self.getTableViewSectionTitle()
                        self.tableView.reloadData()
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        self.tableView.setContentOffset(CGPoint.zero, animated: true)
                        
                        if(!self.iscameFromChatScreen){
                            
                            if  !(UserDefaults.standard.bool(forKey: "FirstTimeExperienceContacts")){
                                
                                let tourTip = NZTourTip.init(views: [self.freindRequest, self.invitesButton, self.addFreinds], withMessages: ["Tap this to display the pending friend request","Tap this to send invites to people to use Closed1 app","Tap this to add friends which are using closed1"], onScreen: self.view)
                                tourTip?.show()
                                UserDefaults.standard.set(true, forKey: "FirstTimeExperienceContacts")
                            }
                            
                        }
                        
                        self.hidereshControl();
                    }
                    
                }else{
                    
                     DispatchQueue.main.async() {
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)

                        UIAlertView(title: "It seems there are no contacts in your list", message: "", delegate: nil, cancelButtonTitle: "Okay").show()
                        self.hidereshControl();

                    }
                }
            }else{
                DispatchQueue.main.async() {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    UIAlertView(title: "It seems there are no contacts in your list", message: "", delegate: nil, cancelButtonTitle: "Okay").show()
                    
                    self.hidereshControl();
                    
                }
            }
        }
    }
    
    func hidereshControl() -> Void {
        
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MMM d, h:mm a";
        let titleOfRefresh: String = String(format: "Last update: %@", dateFormatter.string(from: Date()));
        self.refreshControl.attributedTitle = NSAttributedString(string: titleOfRefresh)
        self.refreshControl.endRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        LoginViewController().getFreindListCount()
        FreindRequestCountRecivedFromServer()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        
    }
    func sortFilteredContacts()
    {
        filterednameSecarh.sort { (firstObject, secondObject) -> Bool in
            return (firstObject["Name"] as! String) < (secondObject["Name"] as! String)
        }
    }
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
    
    
    func createCustumNavigationBar()
    {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        let navBar = UINavigationBar(frame: CGRect(x: self.view.bounds.origin.x-10, y: self.view.bounds.origin.y , width: self.view.frame.size.width + 10, height: 60))
//        let navItem = UINavigationItem()
//        
//        invitesButton = UIButton(frame: CGRect (x: 0, y: 0, width: 44, height: 44))
        invitesButton.setImage(UIImage.init(named: "InviteFreinds"), for: .normal)
        invitesButton.addTarget(self, action: #selector(pickContactMethod), for: .touchDown)
//
//        let contact = UIBarButtonItem(customView: invitesButton)
//        
//        addFreinds = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        addFreinds.setImage(UIImage.init(named: "AddIndivisual"), for: .normal)
        addFreinds.addTarget(self, action: #selector(addFreindList), for: .touchDown)
//
//        let adddFreind = UIBarButtonItem(customView: addFreinds)
//            
//        navItem.rightBarButtonItems = [contact, adddFreind]
//        
//        freindRequest = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        freindRequest.setImage(UIImage.init(named: "FreinfReuest"), for: .normal)
        freindRequest.addTarget(self, action: #selector(openFreingRequestScreen), for: .touchDown)
//        
//        let freinds = UIBarButtonItem(customView: freindRequest)
//        navItem.leftBarButtonItem  = freinds
//        
//        
//        navBar.items = [navItem]
//        navBar.barTintColor = UIColor(red: 38.0/255.0, green: 166.0/255.0, blue: 154.0/255.0, alpha: 1.0)
//        navBar.tintColor = UIColor.white
//        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
//        navItem.title = "Contacts"
//        self.view.addSubview(navBar)
        
    }
    
    func pickContactMethod() {
        
        let alertController = UIAlertController(title: "Select method", message: "Please select one method via you want to sent invitations", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.init(title: "Mail", style: .default, handler: { action in
            
            self.openContactScreenFroMail()
            
        }))
        
        alertController.addAction(UIAlertAction.init(title: "Message", style: .default, handler: { action in
            
            self.openContactsScreenForContacts()
            
        }))
        
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func openContactScreenFroMail(){
        
        let adressBook = self.storyboard?.instantiateViewController(withIdentifier: "OpenAdressBook") as! OpenAdressBook
        adressBook.isMailContactSelected = true
        ismailSelected = true
        adressBook.delegate = self
        self.navigationController?.pushViewController(adressBook, animated: true)
    }
    
    func openContactsScreenForContacts(){
        
        let adressBook = self.storyboard?.instantiateViewController(withIdentifier: "OpenAdressBook") as! OpenAdressBook
        adressBook.isMailContactSelected = false
        ismailSelected = false
        adressBook.delegate = self
        self.navigationController?.pushViewController(adressBook, animated: true)
    }
    
    func isMailSendingSuccess(_ isSuccess: Bool, withMesssage message: String!) {
        
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        
        if isSuccess {
            UIAlertView(title: message, message: "", delegate: nil, cancelButtonTitle: "Okay").show()
            
        }else{
            
            UIAlertView(title: "Failed to send emails", message: "Sorry we are unable to send emails right now. Please try again later", delegate: nil, cancelButtonTitle: "Okay").show()
        }
    }
    
    func selectedData(_ name: [String], number: [String]) {
        
        print("%@", name)
        print("%@", number)
        
        if ismailSelected {
            
           let mailSending = GetMailDictionary()
            mailSending.delegate = self
            mailSending.getMailCOmposerDictionary(number, withNameArray: name, with: self.view);
            

//            if MFMailComposeViewController.canSendMail() {
//                
//                let composeVC = MFMailComposeViewController()
//                composeVC.setToRecipients(number)
//                composeVC.mailComposeDelegate = self;
//                composeVC.setSubject("Invitations for Closed1 app")
//                composeVC.setMessageBody("Hi, I would like to invite you to join me on Closed1 to help each other close more deals! Please see the link below to join", isHTML: false)
//                self.present(composeVC, animated: true, completion: nil)
//                
//            }else{
//                
//                UIAlertView(title: "Sorry you cannot send mail", message: "It seems the mail is not setup im your device Please configure your mail .", delegate: nil, cancelButtonTitle: "Okay").show()
//            }
            
        }else{
            
            if MFMessageComposeViewController.canSendText() {
                
                let messageController = MFMessageComposeViewController()
                messageController.messageComposeDelegate = self;
                messageController.recipients = number
                messageController.body = "Hi, I would like to invite you to join me on Closed1 to help each other close more deals! Please see the link below to join\n\nhttps://itunes.apple.com/app/id1292742901"
                self.present(messageController, animated: true, completion: nil)
                
                
            }else{
                UIAlertView(title: "Sorry you cannot send message", message: "It seems that you haven't installed sim in your device or Airplone maode is turn ON.", delegate: nil, cancelButtonTitle: "Okay").show()
            }
            
        }
        
    }
   
    
        
    
    func addFreindList() {
        
        let  addFreind = self.storyboard?.instantiateViewController(withIdentifier: "AddFreindsViewController") as! AddFreindsViewController

        self.navigationController?.pushViewController(addFreind, animated: true)
    }
    
    func openFreingRequestScreen()  {
        
        let freinds = self.storyboard?.instantiateViewController(withIdentifier: "FreindRequestViewController") as! FreindRequestViewController
        freinds.delegate = self;
        self.navigationController?.pushViewController(freinds, animated: true)
        
    }

    func getDataFromServer() -> [String:AnyObject]?
    {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let user: UserDetails! = UserDetails.mr_findFirst();
        
        
        
        let url: String = String(format: "https://closed1app.com/api-mobile/?function=get_contacts&user_id=%lld", (user!.userID))

        
        
        var dictionaryFromServer:[String:AnyObject]? = nil
        let session = URLSession.shared
        let sessionTask = session.dataTask(with: NSURL(string: url as String)! as URL, completionHandler: { (dataFromServer, response, error) -> Void in
            if dataFromServer != nil
            {
                dictionaryFromServer = self.parseData(data: dataFromServer! as NSData)
                
            }
            else  if let _ = error {
                //completion(data: nil, error: responseError)
                print("network error")
                session.finishTasksAndInvalidate()
                
            }
            else
            {
                #if Debug
                    print("Error in fetching HealthCare apps : \(error)")
                #endif
            }
            semaphore.signal()
        })
        sessionTask.resume()
        
        
         semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return dictionaryFromServer
    }
    
    
    func parseData(data:NSData) -> [String:AnyObject]?
    {
        
        do{
            let dictionary = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [String:AnyObject]
            return dictionary
        }
        catch{
            return nil
        }
        
    }
    

    // MARK: - TableVieW Delegates
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        var indexOfContact:Int = 0
//        
//        for i in 0  ..< indexPath.section
//        {
//            indexOfContact += countForSection[i]
//        }
//        
        
        var indexOfContact:Int = 0
        
        for i in 0  ..< indexPath.section
        {
            indexOfContact += countForSection[i]
        }
        
        indexOfContact += indexPath.row == 0 ? 0 : indexPath.row
        

        
        if(iscameFromChatScreen){
            
            if chatsDelegate != nil {
                
                if((filterednameSecarh[indexOfContact]["user_email"] != nil)){
                    
                    chatsDelegate?.contactsSelectedEmail(filterednameSecarh[indexOfContact]["user_email"] as! String)
                    
                }else{
                    
                    chatsDelegate?.contactsSelectedEmail("demo@gmail.com")
                }
                
            }
            
            self.dismiss(animated: true, completion: nil)
            
        }else{
            
            /// To remove the selected tableview default blue color
//            let cell = tableView.cellForRow(at: indexPath)
//            let backGroundView = UIView()
//            backGroundView.backgroundColor = UIColor.clear
//            cell!.selectedBackgroundView = backGroundView
            
            
            indexOfContact += indexPath.row == 0 ? 0 : indexPath.row
            
            let profileScreen: ProfileDetailViewController = self.storyboard!.instantiateViewController(withIdentifier: "ProfileDetailViewController") as! ProfileDetailViewController
            profileScreen.userid = (filterednameSecarh[indexOfContact]["user_id"] as? NSInteger)!
            self.navigationController?.pushViewController(profileScreen, animated: true)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell: ContactsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell") as! ContactsTableViewCell
        
        var indexOfContact:Int = 0
        
        for i in 0  ..< indexPath.section
        {
            indexOfContact += countForSection[i]
        }
        
        indexOfContact += indexPath.row == 0 ? 0 : indexPath.row 

        let imageName = filterednameSecarh[indexOfContact]["imageURL"] as? String
        
        cell.profileImage.sd_setImage(with: URL(string: imageName!), placeholderImage: UIImage(named: "male-circle-128.png"))
        

        print(filterednameSecarh[indexOfContact]);
        
        cell.nameLabel.text = filterednameSecarh[indexOfContact]["Name"] as? String
        cell.companyLabel.text = filterednameSecarh[indexOfContact]["Number"] as? String
        cell.titleLabel.text = filterednameSecarh[indexOfContact]["title"] as? String
        
        return  cell
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

    //MARK: - Mail Delegates
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
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

    //MARK: - Freind List Delegate
    
    func freindListAddedSucessFully() -> Void {
        
        self.contactDictionary = Array<[String:AnyObject]>()
        self.getFriendListFromServer()
        
        var freindRequestCount = UserDefaults.standard.integer(forKey: "FreindRequestCount")
        
        if(freindRequestCount>0)
        {
            freindRequestCount = freindRequestCount - 1;
        }
        
        UserDefaults.standard.set(freindRequestCount, forKey: "FreindRequestCount")
        
        if freindRequestCount>0 {
            
            self.freinfReeustCountLabel.text = "\(freindRequestCount)";
            self.freindRequestCountView.isHidden = false;
            self.freinfReeustCountLabel.isHidden = false;
            
        }else{
            
            self.freindRequestCountView.isHidden = true;
            self.freinfReeustCountLabel.isHidden = true;
            
        }
        
    }
    
    func serverFailed(withTitle title: String!, subtitleString subtitle: String!) {
        
        DispatchQueue.main.async() {
       UIAlertView(title: title, message: subtitle, delegate: nil, cancelButtonTitle: "Okay").show()
        
        }
        
    }

}
