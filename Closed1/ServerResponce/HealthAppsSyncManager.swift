//
//  HealthAppsSyncManager.swift
//  mySC
//
//  Created by jay on 11/9/15.
//  Copyright (c) 2015 kratin. All rights reserved.
//

import UIKit

 let kLastModifiedDateUserDefaultKey = "LastModifiedDataUserDefaultKey"
let kRefreshTimeInterval:NSTimeInterval = 60 * 60 * 24

//let kHealthCareAppURL = "http://providerdirectorydev.springfieldclinic.com//api/HealthcareApplications/?status=true&all=false"
var kHealthCareAppURL: String!


//Server Dictionary Keys
let kApplicationListKey = "AppList"
let kApplicationID = "ApplicationId"
let kApplicationName = "Title"
let kApplicationDateAdded = "DateAdded"
let kRating = "Rating"
let kCost = "Cost"
let kApplicationIcon = "Icon"
let kApplicationLink = "MarketUrl"
let kApplicationDeveloper = "Developer"
let kApplicationStoreDetail = "StoreDetails"
let kApplicationDateModified = "LastModifiedDate"
let kApplicationCategoryID = "CategoryId"
let kSpringfieldApplicationID = "Id"
let kApplicationDescription = "ShortDescription"
let kApplicationCategoryName = "CategoryName"


@objc class HealthAppsSyncManager: NSOperation {
   
    static var instance:HealthAppsSyncManager?
    var healthCareAppsLocalDictionary = [String:AnyObject]()

    
    class func syncHealthApps(force force:Bool)->HealthAppsSyncManager!
    {
        //MARK:- do server changes code here
        
        if let lastModifiedDate = NSUserDefaults.standardUserDefaults().objectForKey(kLastModifiedDateUserDefaultKey) as? NSDate
        {
            if (NSDate().timeIntervalSinceDate(lastModifiedDate) > kRefreshTimeInterval || force)
            {

                instance = HealthAppsSyncManager()

                let synchorizationOperationQueue = NSOperationQueue()
                synchorizationOperationQueue.addOperation(instance!)
            }

        }
        else
        {
            instance = HealthAppsSyncManager()
            let synchorizationOperationQueue = NSOperationQueue()
            synchorizationOperationQueue.addOperation(instance!)
            

        }
        

        return instance
    }
    
    
    
    func configureApplicationDictionary()
    {
        if let healthCareApps = HealthApps.findAll() as? Array<HealthApps>
        {
            for healthCareApp in healthCareApps
            {
                
                healthCareAppsLocalDictionary[healthCareApp.scAppID] = healthCareApp
                
            }
        }
    }
    
    
    
    override func main() {
        
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: kLastModifiedDateUserDefaultKey)
        
        let baseUrl = ServerConfig.sharedServerConfig().getBaseUrl()
        kHealthCareAppURL = baseUrl + "//api/HealthcareApplications/?status=true&all=false"

        configureApplicationDictionary()

        /**
        *  to get data from local json
        */
        if healthCareAppsLocalDictionary.count == 0
        {
            syncData(fromServer: false)
            configureApplicationDictionary()

        }
        /**
        to get data from server
        
        - parameter fromServer: true if load data from server
        */
        syncData(fromServer: true)
        
    }
    
    
    func syncData(fromServer fromServer:Bool)
    {
        var dataFromServer:[String:AnyObject]?
        if fromServer
        {
            //Download json from server
            dataFromServer = getDataFromServer()
        
        }
        else if !NetworkConnectivity.isConnectedToNetwork()
        {
            //Get data from local json file
            dataFromServer = getDataFromLocalFile()
        }
        
        
        storeDataInDatabaseFromJson(dataFromServer)
        
        
    }
    

    func getDataFromLocalFile() -> [String:AnyObject]?
    {
        let healthAppsFile = NSBundle.mainBundle().pathForResource("HealthApp", ofType: "json")!
        let dataFromFile = NSData(contentsOfFile: healthAppsFile)

        return parseData(dataFromFile!)
    }


/**

    Stores data in database

*/
func storeDataInDatabaseFromJson(dataFromServer:[String:AnyObject]?)
{
    if let dataFromServerLocal = dataFromServer
    {
        if(dataFromServerLocal[kApplicationListKey] != nil)
        {
        
        let appListDictionary = dataFromServerLocal[kApplicationListKey] as! [String:Array<[String:AnyObject]>]
        
        var iOSAppListArray: Array<[String:AnyObject]>
       
        if appListDictionary["iOS"] != nil{
        iOSAppListArray = appListDictionary["iOS"]!
            
            let managedObjectContext: NSManagedObjectContext = NSManagedObjectContext.MR_contextForCurrentThread()
            
            let healthApps: NSFetchRequest = NSFetchRequest()
            healthApps.entity = NSEntityDescription.entityForName("HealthApps", inManagedObjectContext: managedObjectContext)
            healthApps.includesPropertyValues = false
            
        
            
            var healthApp: [AnyObject]?
            
            do {
                healthApp = try managedObjectContext.executeFetchRequest(healthApps)
                for app in healthApp! {
                    #if DEBUG
                    print(app.valueForKey(kApplicationID) as? String)
                    print(app.valueForKey(kApplicationName) as? String)
                    #endif
                    
                    for application in iOSAppListArray
                    {
                        let applicationID: AnyObject = (application[kApplicationID])!
                        let appID: String  = "\(applicationID)"
                        let StringID: String! = appID
                        let lastUpdatedValue = application[kApplicationDateModified] as? String
                        let databaseLastUpatedValue = app.valueForKey("dataModified") as? String
                   
                    
                    if StringID == app.valueForKey("applicationID") as? String && NSUserDefaults.standardUserDefaults().boolForKey("isFirstTimeLauncedHealthApp")
                    {
                        
                    }else if lastUpdatedValue != databaseLastUpatedValue {
                        managedObjectContext.deleteObject(app as! NSManagedObject)

                        }else
                        
                    {
                        managedObjectContext.deleteObject(app as! NSManagedObject)

                        
                    }
                    syncApplicationInDatabase(application, scID: String(application[kSpringfieldApplicationID]))
                }
                    
                }
            } catch let error as NSError  {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        
        
        for application in iOSAppListArray
        {
            syncApplicationInDatabase(application, scID: String(application[kSpringfieldApplicationID]))
        }
        
        
        var error:NSError?
        NSManagedObjectContext.contextForCurrentThread().save(&error)
        
        
        if error == nil
        {
            print("Health apps saved successfully")
        }
        else
        {
            print("Failed to save health application : \(error)")
        }
    }
        else
        {
           deleteDataBaseEntity()
        }
    }
    }
    }



    func syncApplicationInDatabase(application:[String:AnyObject], scID:String)
    {
        if let healthCareApp = healthCareAppsLocalDictionary[scID] as? HealthApps
        {
            if !application[kApplicationDateModified]!.isEqualToString(healthCareApp.dataModified)
            {
                 createHealthCareAppEntity(application,scID: scID)
            }
            healthCareAppsLocalDictionary.removeValueForKey(scID)
        }
        else
        {
            createHealthCareAppEntity(application,scID: scID)
        }
        
 
        
        
    }


/**
     
    Get data from server
     
*/
    func getDataFromServer() -> [String:AnyObject]?
    {
        
        let semaphore = dispatch_semaphore_create(0)
        
        var dictionaryFromServer:[String:AnyObject]? = nil
        let session = NSURLSession.sharedSession()
        let sessionTask = session.dataTaskWithURL(NSURL(string: kHealthCareAppURL)!, completionHandler: { (dataFromServer, response, error) -> Void in
            if dataFromServer != nil
            {
                dictionaryFromServer = self.parseData(dataFromServer!)
                
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
            dispatch_semaphore_signal(semaphore)
        })
        sessionTask.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return dictionaryFromServer
    }

    
    func parseData(data:NSData) -> [String:AnyObject]?
    {

        do{
            let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String:AnyObject]
            return dictionary
        }
        catch{
            return nil
        }
        
    }


    func createHealthCareAppEntity(application:[String:AnyObject],scID:String)
    {
        let managedObjectContext: NSManagedObjectContext = NSManagedObjectContext.MR_contextForCurrentThread()
        
        let entityDescription = NSEntityDescription.entityForName("HealthApps", inManagedObjectContext: managedObjectContext)
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        let applicationID: AnyObject = (application[kApplicationID])!
        let appID: String  = "\(applicationID)"
        let StringID: String! = appID 
        
        
        let predicate = NSPredicate(format: "(applicationID = %@)", StringID)
        request.predicate = predicate
        var objects: AnyObject?
        
        do {
            objects = try managedObjectContext.executeFetchRequest(request)
            //5
        } catch let error as NSError  {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if let result = objects{
            
            if result.count > 0
            {
                let match = result[0] as! NSManagedObject
                
                #if DEBUG
                print(match.valueForKey(kApplicationID) as? String)
                print(match.valueForKey(kApplicationName) as? String)
                #endif
            
            }
            else
            {
                let healthApp = HealthApps.createEntity() as! HealthApps
                updateHealthCareAppEntity(healthApp,application: application,scID: scID)
            }
        }
        
        
       

    }


    func updateHealthCareAppEntity(healthApp:HealthApps,application:[String:AnyObject], scID :String)
{
    healthApp.applicationName = application[kApplicationName] as! String
    let applicationID: AnyObject = (application[kApplicationID])!
    healthApp.applicationID = "\(applicationID)" as String
    healthApp.appLink = application[kApplicationLink] as! String
    healthApp.dateAdded = application[kApplicationDateAdded] as! String
    healthApp.appIcon = application[kApplicationIcon] as! String
    healthApp.cost = application[kCost] as! NSNumber
    healthApp.developerName = application[kApplicationDeveloper] as! String
    healthApp.dataModified = application[kApplicationDateModified] as! String
    healthApp.scAppID = scID
    healthApp.appDetail = application[kApplicationDescription] as! String
    healthApp.categoryName = application[kApplicationCategoryName] as! String
}
    
   
   
     func deleteDataBaseEntity()
    {
        let managedObjectContext: NSManagedObjectContext = NSManagedObjectContext.MR_contextForCurrentThread()
        
        let healthApps: NSFetchRequest = NSFetchRequest()
        healthApps.entity = NSEntityDescription.entityForName("HealthApps", inManagedObjectContext: managedObjectContext)
        healthApps.includesPropertyValues = false
        
        var healthApp: [AnyObject]?
        
        do {
            healthApp = try managedObjectContext.executeFetchRequest(healthApps)
            for app in healthApp! {
                managedObjectContext.deleteObject(app as! NSManagedObject)
            }
            //5
        } catch let error as NSError  {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        var error:NSError?
        NSManagedObjectContext.contextForCurrentThread().save(&error)
    }

   

}
