//
//  AKGooglePlacesPickerControllerViewController.m
//  AKLocationPickerExample
//
//  Created by Andrew Kurinnyi on 11/21/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import "AKGooglePlacesPickerControllerViewController.h"

static NSString *kGoogleAPIKey = @""; // Insert your own API key

@interface AKGooglePlacesPickerControllerViewController ()

@end

@implementation AKGooglePlacesPickerControllerViewController

- (void)awakeFromNib {
    self.placesDataSource = [[AKGooglePlacesDataSource alloc] initWithAPIKey:kGoogleAPIKey];
    self.dataSource = self.placesDataSource;
    self.currentLocation = @{
        @"address": @"6333 W 3rd St Los Angeles, CA 90036",
        @"name": @"Farmers market",
    };
}

@end
