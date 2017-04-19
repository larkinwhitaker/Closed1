//
//  AppDelegate.h
//  Closed1
//
//  Created by Nazim on 25/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "utilities.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;
@property (strong, nonatomic) id<SINService> sinchService;


@end

