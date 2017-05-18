//
//  ContactsListViewController.swift
//  Closed1
//
//  Created by Nazim on 19/05/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

import UIKit
import MessageUI

@objc class ContactsListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UIViewControllerTransitioningDelegate,ServerFailedDelegate,FreindsListDelegate {

    var contactList =  Array<[String:AnyObject]>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user: UserDetails! = UserDetails.mr_findFirst();

        let url: NSString = NSString(format: "http://socialmedia.alkurn.info/api-mobile/?function=get_contacts&user_id=%lld", (user!.userID))
        
        print("%@", url)
        
        var serverResponce: NSArray = ClosedResverResponce.sharedInstance().getFromServer(url as String!, dictionartyToServer: nil) as! NSArray;
        
        print("%@", serverResponce)
//        serverResponce = serverResponce?[""];
        
        for entity in serverResponce {
            
             var singleDictionary = [String: AnyObject]()
//            singleDictionary["Name"] = entity[""] as! String
//            
//            singleDictionary["Number"] = entity[""] as! String
            
            contactList.append(singleDictionary)
            
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - TableVieW Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "")
        return  cell!
    }

    //MARK: - Mail Delegates
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: - Freind List Delegate
    
    func freindListAddedSucessFully() -> Void {
        
        
    }
    
    func serverFailed(withTitle title: String!, subtitleString subtitle: String!) {
        
        
        
    }

}
