//
//  WebViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

import Foundation
import AddressBook

/*
* AddressBookAscStatus class is used for managing all the operations related to user's addressbook.
* In this class we have methods for managing the address book and ABAddressBook reference.
* We also have methods for retrieving the name and numbers and other data of a particular contact from user's address book or contacts.
*/

import UIKit
import Foundation

class AdressBookAscStatus{
    static var addressBook: ABAddressBook!
    
    fileprivate var allContacts: NSArray!
    fileprivate var dataDictionaryFromServer = [String: AnyObject]()
    //Singleton Instance
    static var instance:AdressBookAscStatus!
    static func sharedInstance() -> AdressBookAscStatus {
        instance = instance ?? AdressBookAscStatus()
        return instance
    }
    
    static func isAccessPermitted() -> Bool {
        return ABAddressBookGetAuthorizationStatus() == .authorized
    }
    
    
    // Static method for creating addressbook. Refer this method if you want to get access to the addressBook
    static func getSingleAddressBookReference() -> ABAddressBook{
        
        if(addressBook != nil){
            return addressBook
        }
        else{
            addressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            return addressBook
        }
    }
    
    //USE THIS METHOD VERY CAREFULLY
    static func refreshAddressBookReference(){
        addressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    }
    
    
    /*
    Method for returning all the contacts from device addressbook.
    */
    func getAllContacts(_ isRefreshedContactArrayRequired: Bool) -> NSArray{
        if(ABAddressBookGetAuthorizationStatus() == .authorized){
            if(isRefreshedContactArrayRequired || (allContacts == nil)){
                /* Get all the people in the address book */
                
                //  allContacts = ABAddressBookCopyArrayOfAllPeople(AddressBookAscstatus.getSingleAddressBookReference()).takeRetainedValue() as NSArray
                
                let abRef : ABAddressBook = AdressBookAscStatus.getSingleAddressBookReference()
                
                
                
                allContacts = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(abRef, nil /* ABAddressBookCopyDefaultSource(abRef).takeRetainedValue() */, ABPersonGetSortOrdering()).takeRetainedValue() as NSArray
                
                
                //Predicate for getting only those contacts having atleast one phone number
                let predicate: NSPredicate = NSPredicate { (person, bindings) -> Bool in
                    
                    let phones: ABMultiValue? = ABRecordCopyValue(person as ABRecord,
                        kABPersonPhoneProperty).takeRetainedValue()
                    
                    return (ABMultiValueGetCount(phones) > 0)
                }
                allContacts = allContacts.filtered(using: predicate) as NSArray
                
            }
            else{
                // Refreshed contacts not required
            }
            // print("allContacts count is  \(allContacts.count)")
            return allContacts
        }
        return NSArray()
    }
    
    static func getNameOfPersonForContactsTable(_ person: ABRecord) -> (fristName: String, lastName: String){
        var firstName = ""
        var lastName = ""
        
        if let first = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String {
            firstName += first
        }
        else{
            // First name empty
        }
        
        if let last = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String {
            
            
            //  var attributedString = NSMutableAttributedString(string: name)
            
            //  var attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(UIFont.systemFontSize())]
            
            //  var boldLast = NSMutableAttributedString(string: lastName, attributes: attrs)
            lastName = last
            
        }
        else{
            // print("Last Name not found")
        }
        
        return (firstName, lastName)
    }
    
    
    
    //Method for getting first and last name of the person with record
    //Returns "" if name is not present
    
    static func getNameOfContact(_ person: ABRecord) -> String{
        var name:String = ""
        if let first = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String {
            name += first
        }
        else{
            // print("First Name not found")
        }
        
        if let last  = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String {
            name += " "
            name += last
        }
        else{
            // print("Last Name not found")
        }
        
        return name
    }
    
    static func getAllNumbersOfContact(_ person: ABRecord) -> [String]{
        var allPhones = [String]()
        let phones: ABMultiValue? = ABRecordCopyValue(person,
            kABPersonPhoneProperty).takeRetainedValue()
        if(phones != nil){
            for count in 0..<ABMultiValueGetCount(phones){
                let phone = ABMultiValueCopyValueAtIndex(phones, count).takeRetainedValue() as! String
                if(phone != ""){
                    allPhones.append(phone)
                }
            }
        }
        return allPhones
    }
    
    
    
    static func getAllEmailsOfContacts(_ person: ABRecord) ->[String]{
        var allEmail = [String]()
        let email: ABMultiValue? = ABRecordCopyValue(person,
            kABPersonEmailProperty).takeRetainedValue()
        if(email != nil){
            for count in 0..<ABMultiValueGetCount(email){
                let phone = ABMultiValueCopyValueAtIndex(email, count).takeRetainedValue() as! String
                if(phone != ""){
                    allEmail.append(phone)
                }
            }
        }
        return allEmail
    }
    
    
    
    
    static func getPhoneTypeLabelFromContactWithNumber(_ person: ABRecord, number: String) -> String{
        let label = ""
        let phones: ABMultiValue? = ABRecordCopyValue(person,
            kABPersonPhoneProperty).takeRetainedValue()
        
        if(phones != nil){
            for count in 0..<ABMultiValueGetCount(phones){
                
                let currentPhone = ABMultiValueCopyValueAtIndex(phones, count).takeRetainedValue() as! String
                
                if(currentPhone == number){
                    let currentLabel: String? = ABMultiValueCopyLabelAtIndex(phones, count).takeRetainedValue() as String
                    if(currentLabel != nil){
                        
                        return ABAddressBookCopyLocalizedLabel(currentLabel! as CFString).takeRetainedValue() as String
                    }
                }
            }
        }
        
        return label
    }
    
    
    
    /*
    * Use this method very carefully as ABAddressBookGetPersonWithrecordID method behaves weird sometimes for some unknow reason
    */
    static func getPersonRecordFromContactID(contactId: Int32) -> ABRecord{
        let person : ABRecord = ABAddressBookGetPersonWithRecordID(AdressBookAscStatus.getSingleAddressBookReference(), contactId).takeUnretainedValue()
        
        return person
        
    }
    
    
    fileprivate  func createSectionDictionary(_ topicArray:Array<[String:AnyObject]>)
    {
        //creating an another dictionay with the key as "MyHFCategory" i.e the element by which data has to be divided
        var completeDictionary = [String:Array<[String:AnyObject]>]()
        
        for dictionary in topicArray
        {
            //topicArray contains the complete data of Topics Array
            //dictionary contains the individual array element of topics array
            // print(topicArray.count)
            //initially the completeDictionary doesnot contains the key so this block is never executed first time
            if completeDictionary.keys.contains(dictionary["MyHFCategory"] as! String)
            {
                // we are adding the dictionary into the completeDictionary with key as "MyHFCategory"
                completeDictionary[(dictionary["MyHFCategory"] as! String)]?.append(dictionary)
            }
            else
            {
                //This method is always going to execute first time since completeDictionary doesnot contains the key so we are creating a tempdictionaryArray and add it to the completeDictionary
                var tempdictionaryArray = Array<[String:AnyObject]>()
                tempdictionaryArray.append(dictionary)
                completeDictionary[(dictionary["MyHFCategory"] as! String)] = tempdictionaryArray
                
            }
        }
        //completeDictionary will be asssigned to the dataDictionaryFromServer
        //dataDictionaryFromServer contains all the data in the form of key as "MyHFCategory" and data as an AnyObject
        dataDictionaryFromServer = completeDictionary as [String : AnyObject]
        
    }
    
    
    func manageContacts(_ allContacts: NSArray) -> Array<[String:AnyObject]>
    {
        var contactDictionary = Array<[String:AnyObject]>()
        
        
        for count in 0 ..< allContacts.count{
        
            var singleDictionary = [String: AnyObject]()
            let contact = allContacts[count]
            let firstNameOfContact = AdressBookAscStatus.getNameOfPersonForContactsTable(contact as ABRecord).fristName
            let lastNameOfContact = AdressBookAscStatus.getNameOfPersonForContactsTable(contact as ABRecord).lastName
            let emailOfContact = AdressBookAscStatus.getAllEmailsOfContacts(contact as ABRecord)
            let numberOfContact = AdressBookAscStatus.getAllNumbersOfContact(contact as ABRecord)
            
            let fullname = firstNameOfContact + lastNameOfContact
            
            for count in 0 ..< numberOfContact.count{
                
                if numberOfContact[count] != "" && fullname != ""{
                    
                    singleDictionary["Name"] = (firstNameOfContact + " "+lastNameOfContact as AnyObject)
                    singleDictionary["Number"] = numberOfContact[count] as AnyObject
                    
                    contactDictionary.append(singleDictionary)
                    
                }
            }
        }
        
        return contactDictionary
        
    }
    
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }

    
}
