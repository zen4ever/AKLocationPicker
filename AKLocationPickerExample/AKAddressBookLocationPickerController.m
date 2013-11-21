//
//  AKAddressBookLocationPickerController.m
//  AKLocationPickerExample
//
//  Created by Andrew Kurinnyi on 10/10/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import "AKAddressBookLocationPickerController.h"

@interface AKAddressBookLocationPickerController ()

@end

@implementation AKAddressBookLocationPickerController

- (void)awakeFromNib {
    self.addressBookDataSource = [[AKAddressBookDataSource alloc] init];
    self.dataSource = self.addressBookDataSource;
    self.currentLocation = @{
        @"address": @"6333 W 3rd St Los Angeles, CA 90036",
        @"name": @"Farmers market",
    };
}

@end
