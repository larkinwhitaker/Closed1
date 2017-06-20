//
//  ManagingJSONData.swift
//  OrientationDemo
//
//  Created by Nazim Siddiqui on 23/11/15.
//  Copyright © 2015 Kratin. All rights reserved.
//

import Foundation

protocol RecommendedScreeningDataSourceDelegate{
    func networkError()
}

    /**
 This class is used to Fetching Reccommended List and sort acoording to the requirement
 */

class RecommendedScreeningDataSource : NSObject{
    
    //dataDictionaryFromServer contains the complete data from server as a Dictionary form
    
    private var dataDictionaryFromServer = [String: AnyObject]()
    
    //URL_FOR_REQUEST_APPINTMENT_FOR_RECOMMENDED_LIST is a URL data is received from
   private let URL_FOR_REQUEST_APPINTMENT_FOR_RECOMMENDED_LIST = "http://healthfinder.gov/developer/MyHFSearch.json?api_key=gndgetxivjsalxxr&age=%.@&gender=%.@&pregnant=%.d&who=me"
    
    //Arary is used to sort the item accordingly
    private let CATEGORY_SEQUENCE_ARRAY = ["Pregnant","All","Some","Interest"]

    //creating the instance of a class
    static var instance: RecommendedScreeningDataSource!
    
    static func sharedInstance() -> RecommendedScreeningDataSource{
        instance = instance ?? RecommendedScreeningDataSource()
        return instance
    }
    
    
    
    var delegate : RecommendedScreeningDataSourceDelegate!
    /**
     
     To fetch the data from server this method is called from the Recommended Screenings class value is passes and if data is present then return true
     
     - parameter : Age, Gender, isPregnant
     
     - returns: Boolean value i.e Sucess or failure
     
     */
    
    
    func fetchDataFromServer(age age:String, gender:String, isPreganant:Int) -> Bool
    {
        
        
        if let dictionaryFromServer = fetchRecommendedScreeningDictionary(age: age, gender: gender, isPreganant: isPreganant)
        {
            
            //resultDictionary is used to create for fetching complete data from JSON in form of dictionary
            
            let resultDictionary = dictionaryFromServer["Result"] as! [String:AnyObject]
            
           let errorResult = dictionaryFromServer["Result"]!["Error"] as! String
            print(errorResult)
            
            //complete data in the form of array storing topics array
           let arrayOfTopics = resultDictionary["Topics"] as? Array<[String:AnyObject]>
           // print(arrayOfTopics)
            
            //complete data in the form iof array storing Tools array
            
            //method to divide array in the form of sections
            if arrayOfTopics != nil{
            createSectionDictionary(arrayOfTopics!)
                return true
            }
            else
            {
                return false
            }
            
        }
        else
        {
            return false
        }

    }
    
    
    
//    func alertBox(title: String, message: String, dismisstitle: String){
//        
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: dismisstitle, style: UIAlertActionStyle.Default, handler: nil))
//        //p[resentViewController(alert, animated: true, completion: nil)
//       // jumptoTableViewInstance(alert, animated: true, completion: nil)
//        
//    }

    
    
    //this method is used to get the row data
    func getDictionaryForRows() -> Array<Array<[String:AnyObject]>>
    {
        
        var rowDataArray = Array<Array<[String:AnyObject]>>()
        
        
        var dataDictionaryKeys = Array(dataDictionaryFromServer.keys)
        
        
        //Add section titles according to sequence in category sequence array ( except interest key which is in last
        //CATEGORY_SEQUENCE_ARRAY contains all the category
        for category in CATEGORY_SEQUENCE_ARRAY
        {
            //we have to place Interest Topic at Last so we checked this condition
            if category != "Interest"
            {
                //topic array will contains all the data whic belog to a single catetory
                //ex: topic array will contain all the data which belong to the "All" category
                if let topicArray = dataDictionaryFromServer[category]
                
                {
                   // print(topicArray)
                    //row data will contains all the data which belong to a specific category
                    //so now datat will be divided into the form as we neede
                    //rowdata will contains the in the sorted format
                    //rowdata is an array of dictionary
                    //as soon as data in added into rowData we remove the data fromdataDictionary
                    rowDataArray.append(topicArray as! Array<[String : AnyObject]>)
                    dataDictionaryKeys.removeAtIndex(dataDictionaryKeys.indexOf(category)!)
                }
            }
        }
        
        
        //for other ket which are oresent in it other the "Pregnant", "All", "Some", "Interest"
        
        for category in dataDictionaryKeys
        {
            if category != "Interest"
            {
                
                if let topicArray = dataDictionaryFromServer[category ]
                {
                    rowDataArray.append(topicArray as! Array<[String : AnyObject]>)
                }
            }
        }
        
        
        // to append the last data
        if let topicArray = dataDictionaryFromServer["Interest"]
        {
            rowDataArray.append(topicArray as! Array<[String : AnyObject]>)
            
        }

        return rowDataArray

    }

    
    
    /**
     
     Get the array of sections ie section header
     
*/
    func getSectionTitlesForCurrentHeader() -> Array<String>
    {
        //Create an array for section titles
        var sectionTitleArray = Array<String>()
        //contains all the keys from dataDictionaryFromServer
        var dataDictionaryKeys = Array(dataDictionaryFromServer.keys)
        
        
        //Add section titles according to sequence in category sequence array ( except interest key which is in last
        for category in CATEGORY_SEQUENCE_ARRAY
        {
            if category != "Interest"
            {
                if let topicArray = dataDictionaryFromServer[category]
                {
                    let firstDictionaryFromTopicArray = topicArray.firstObject
                    sectionTitleArray.append(firstDictionaryFromTopicArray!!["MyHFCategoryHeading"] as! String)
                    
                    dataDictionaryKeys.removeAtIndex(dataDictionaryKeys.indexOf(category)!)
                }
            }
        }
        
        
        //Add Other Sections  that are not in category seqeunce array (except interest key which is in last
        for category in dataDictionaryKeys
        {
            if category != "Interest"
            {
                
                if let topicArray = dataDictionaryFromServer[category]
                {
                    let firstDictionaryFromTopicArray = topicArray.firstObject
                    sectionTitleArray.append(firstDictionaryFromTopicArray!!["MyHFCategoryHeading"] as! String)
                }
            }
        }
        
        
        //At last add section title for interest key
        if let topicArray = dataDictionaryFromServer["Interest"]
        {
            let firstDictionaryFromTopicArray = topicArray.firstObject
            sectionTitleArray.append(firstDictionaryFromTopicArray!!["MyHFCategoryHeading"] as! String)

        }
        
        
        return sectionTitleArray
        
    }
    
    
    /**
     
     This method is used to divide the array i
     
     - parameter : Array of dictionary
     
     - returns: Boolean value i.e Sucess ao failure
     
     */
    
    
   private  func createSectionDictionary(topicArray:Array<[String:AnyObject]>)
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
        dataDictionaryFromServer = completeDictionary
        
    }
    
    
    
    /**
     
     This method is used to fetching the data from JSON
     
     - parameter : Age, gender, isPregnant
     
     - returns: Dictionary[String: AnyObject]
     
     */
    
    
    
    func fetchRecommendedScreeningDictionary(age age:String, gender:String, isPreganant:Int) -> [String:AnyObject]? {
        
         let URL_FOR_FOR_RECOMMENDED_LIST = NSString(format: URL_FOR_REQUEST_APPINTMENT_FOR_RECOMMENDED_LIST, age, gender, isPreganant)
        //print(URL_FOR_FOR_RECOMMENDED_LIST)
         let URLData = getRecommendedScreeningDataFromUrl(NSURL(string: "\(URL_FOR_FOR_RECOMMENDED_LIST)")!)
        // print(URLData)
        
        
        do
        {
                 let dictionary = try NSJSONSerialization.JSONObjectWithData(URLData!, options: NSJSONReadingOptions.AllowFragments)
            //print(dictionary)
            return dictionary as? [String : AnyObject]
//
            
        }
        catch
        {
            
            print("Cannot fech the data")
            
            
        }
        
        
        
    return nil
        

    
    }
    
    
    /**
     This method is used to managing connection with the server
     
     - parameter : URL: NSURL
     
     - returns: NSData

*/
     func getRecommendedScreeningDataFromUrl(url: NSURL) -> NSData? {
        var session = NSURLSession.sharedSession()
        

        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlconfig.timeoutIntervalForRequest = 30
        urlconfig.timeoutIntervalForResource = 30
        session = NSURLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
        
        var dataFromServer :NSData?
        let semaphore = dispatch_semaphore_create(0)
        
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let _ = error {
                //completion(data: nil, error: responseError)
                print("network error")
                if (self.delegate != nil){
                    self.delegate.networkError()
                    session.finishTasksAndInvalidate()
                }
                else
                {
                  print ("nil")
                }
                
                
            
            }
            else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    _ = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "HTTP sattus code has unexpected value"])
                    print("network error")
                 //   completion(data: nil, error: statusError)
                }
                else
                {
                    dataFromServer = data

                //    completion(data: data, error: nil)
                    
                }
                dispatch_semaphore_signal(semaphore)
            }})
        loadDataTask.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        
        return dataFromServer
    }
    

}



