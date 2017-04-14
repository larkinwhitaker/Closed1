//
//  ContactDetails+CoreDataProperties.h
//  Closed1
//
//  Created by Nazim on 14/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ContactDetails+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ContactDetails (CoreDataProperties)

+ (NSFetchRequest<ContactDetails *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *designation;
@property (nullable, nonatomic, copy) NSString *imageURL;
@property (nonatomic) int64_t userID;
@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *country;
@property (nullable, nonatomic, copy) NSString *secondaryemail;
@property (nullable, nonatomic, copy) NSString *territory;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *userEmail;
@property (nullable, nonatomic, copy) NSString *userLogin;

@end

NS_ASSUME_NONNULL_END
