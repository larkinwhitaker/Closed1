//
//  UserDetails+CoreDataProperties.h
//  Closed1
//
//  Created by Nazim on 05/06/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "UserDetails+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserDetails (CoreDataProperties)

+ (NSFetchRequest<UserDetails *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *country;
@property (nullable, nonatomic, copy) NSString *econdaryemail;
@property (nullable, nonatomic, copy) NSString *firstName;
@property (nullable, nonatomic, copy) NSString *lastName;
@property (nullable, nonatomic, copy) NSString *phoneNumber;
@property (nullable, nonatomic, copy) NSString *profileImage;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *territory;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *userEmail;
@property (nonatomic) int64_t userID;
@property (nullable, nonatomic, copy) NSString *userLogin;
@property (nullable, nonatomic, copy) NSString *targetBuyers;

@end

NS_ASSUME_NONNULL_END
