//
//  ContactDetails+CoreDataProperties.h
//  Closed1
//
//  Created by Nazim on 19/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ContactDetails+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ContactDetails (CoreDataProperties)

+ (NSFetchRequest<ContactDetails *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *designation;
@property (nullable, nonatomic, copy) NSString *imageURL;
@property (nullable, nonatomic, copy) NSString *title;
@property (nonatomic) int64_t userID;
@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *userEmail;

@end

NS_ASSUME_NONNULL_END
