//
//  AppDelegate.m
//  Closed1
//
//  Created by Nazim on 25/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "AppDelegate.h"
#import <linkedin-sdk/LISDK.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "MagicalRecord.h"
#import "utilities.h"

@interface AppDelegate ()<SINServiceDelegate, SINCallClientDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [Fabric with:@[[Crashlytics class]]];
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Closed1"];
    
#pragma mark - Chatting View
    
    
    // Firebase initialization
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [FIRApp configure];
    [FIRDatabase database].persistenceEnabled = NO;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    // Google login initialization
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    // Facebook login initialization
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    // Push notification initialization
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0"))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError *error)
         {
             if (error == nil) [[UIApplication sharedApplication] registerForRemoteNotifications];
         }];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
    {
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationType userNotificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
            [application registerUserNotificationSettings:settings];
            [application registerForRemoteNotifications];
        }
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    // OneSignal initialization
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [OneSignal initWithLaunchOptions:launchOptions appId:ONESIGNAL_APPID handleNotificationReceived:nil handleNotificationAction:nil
                            settings:@{kOSSettingsKeyInAppAlerts:@NO}];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [OneSignal setLogLevel:ONE_S_LL_NONE visualLevel:ONE_S_LL_NONE];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    // This can be removed once Firebase auth issue is resolved
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([UserDefaults boolForKey:@"Initialized"] == NO)
    {
        [UserDefaults setObject:@YES forKey:@"Initialized"];
        [FUser logOut];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    // Connection, Location initialization
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [Connection shared];
    [Location shared];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    // Realm initialization
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [CallHistories shared];
    [Groups shared];
    [Recents shared];
    [Users shared];
    [UserStatuses shared];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [Location stop];
    UpdateLastTerminate(YES);

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [Location start];
    UpdateLastActive();
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [FBSDKAppEvents activateApp];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [OneSignal IdsAvailable:^(NSString *userId, NSString *pushToken)
     {
         if (pushToken != nil)
             [UserDefaults setObject:userId forKey:ONESIGNALID];
         else [UserDefaults removeObjectForKey:ONESIGNALID];
         UpdateOneSignalId();
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [CacheManager cleanupExpired];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [NotificationCenter post:NOTIFICATION_APP_STARTED];

    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Closed1"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}




#pragma mark - CoreSpotlight methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return NO;
}

#pragma mark - Google and Facebook login methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
    if ([LISDKCallbackHandler shouldHandleUrl:url]) {
        return [LISDKCallbackHandler application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    
    if ([url.absoluteString containsString:@"google"])
        return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}


#pragma mark - Push notification methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if ([[[userInfo objectForKey:@"aps"] valueForKey:@"alert"] containsString:@"sent you a freind request"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Notificationrecived" object:userInfo];
        
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    if ([[[userInfo objectForKey:@"aps"] valueForKey:@"alert"] containsString:@"sent you a freind request"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Notificationrecived" object:userInfo];

    }
    
        // custom code to handle notification content
        
        if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
        {
            NSLog( @"INACTIVE" );
            completionHandler( UIBackgroundFetchResultNewData );
        }
        else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
        {
            NSLog( @"BACKGROUND" );
            completionHandler( UIBackgroundFetchResultNewData );
        }
        else
        {
            NSLog( @"FOREGROUND" );
            completionHandler( UIBackgroundFetchResultNewData );
        }
    
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  {
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"%@", userInfo);
    if ([[[userInfo objectForKey:@"aps"] valueForKey:@"alert"] containsString:@"sent you a freind request"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Notificationrecived" object:userInfo];
        
    }
    if ([userInfo objectForKey:@"aps"]) {
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = ([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        
    }
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
    
    
}

    
@end
