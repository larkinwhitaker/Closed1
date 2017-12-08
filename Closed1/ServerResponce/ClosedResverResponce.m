//
//  WebViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ClosedResverResponce.h"

@implementation ClosedResverResponce
{
    NSData *serverData;
    NSString *authentizationToken;
    BOOL isEncodedzdataSend;
    //    NSURLSession *session;
}

+(ClosedResverResponce *)sharedInstance
{
    static ClosedResverResponce *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ClosedResverResponce alloc] init];
    });
    return _sharedInstance;
    
}
-(void)invalidateCurrentRunningTask
{
    //    [session invalidateAndCancel];
}

-(NSArray *)getResponceFromServer: (NSString *)URLName  DictionartyToServer:(NSDictionary *)dictionaryToServer IsEncodingRequires: (BOOL) isEncoding
{
    isEncodedzdataSend = isEncoding;

    NSData * dataFromServer = [self dataFromServerWithURL:URLName WithApiName:@"" DictionaryToServer:dictionaryToServer];
    
    
    if (dataFromServer != nil)
    {
        NSArray * arrayOfDictionaryFromServer = [NSJSONSerialization JSONObjectWithData:dataFromServer options:kNilOptions error:nil];
        //        NSLog(@"%@", arrayOfDictionaryFromServer);
        
        return arrayOfDictionaryFromServer;
    }
    return nil;
    
}


-(NSData *)dataFromServerWithURL:(NSString *)url WithApiName:(NSString *)apiName DictionaryToServer:(NSDictionary *)dictionaryToServer
{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
//    NSURL *URL = [NSURL URLWithString:url];
    
    NSString *myUnencodedString = url;
    NSString *encodedString = [myUnencodedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [[NSURL alloc] initWithString:encodedString];
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:URL];
    
    urlRequest.HTTPMethod = @"POST";
    NSData *postData = [[NSData alloc]init];
    
    if (isEncodedzdataSend)
    {
        [urlRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //postData = [self encodeDictionary:dictionaryToServer];
        
        urlRequest.HTTPBody = postData;
        
    }else
    {
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        postData = [NSJSONSerialization dataWithJSONObject:dictionaryToServer options:kNilOptions error:nil];
        urlRequest.HTTPBody = postData;
        
    }
    
    NSString *string = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
#if DEBUG
    //    NSLog(@"JSON OBJECT IS: %@", string);
#endif
    
    if (authentizationToken != nil)
    {
        [urlRequest addValue:authentizationToken forHTTPHeaderField:@"Authorization"];
        
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
#pragma mark - Set the standard time for fetching data
    configuration.timeoutIntervalForRequest = 240; //ie For 2 min it will wait for responce from server
    configuration.timeoutIntervalForResource = 240;
    session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    
    NSURLSessionDataTask *loadDataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
#pragma mark - Write Delegate code for netwoek failure
            NSLog(@"Server Failed");
            if (self.delegate!=nil) {
                [self.delegate serverFailedWithTitle:@"Server Failed" SubtitleString:@"Sorry Something went wrong.Please try again later."];
                [session finishTasksAndInvalidate];
            }else{
                NSLog(@"Delegate Not Working");
            }
            
            
        }else{
            
            serverData = data;
            
        }
        dispatch_semaphore_signal(semaphore);
        
    }];
    [loadDataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return serverData;
    
}


- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    
    if (dictionary != nil) {
        for (NSString *key in dictionary) {
            NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
            [parts addObject:part];
        }
        NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
        return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [[NSData alloc]init];
}

@end
