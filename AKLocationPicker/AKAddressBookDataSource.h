//
//  AKAddressBookDataSource.h
//  AKLocationPicker
//
//  Created by Andrew Kurinnyi on 10/9/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//
#if __has_include("RHAddressBook/RHAddressBook.h")
#import <Foundation/Foundation.h>
#import "AKLocationPickerController.h"

@interface AKAddressBookDataSource : NSObject<AKLocationPickerSource>
@end
#endif