//
//  AKAddressBookLocationPickerController.h
//  AKLocationPickerExample
//
//  Created by Andrew Kurinnyi on 10/10/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import "AKLocationPickerController.h"
#import "AKAddressBookDataSource.h"

@interface AKAddressBookLocationPickerController : AKLocationPickerController

@property (nonatomic, strong) AKAddressBookDataSource *addressBookDataSource;

@end
