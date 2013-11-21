//
//  AKGooglePlacesPickerControllerViewController.h
//  AKLocationPickerExample
//
//  Created by Andrew Kurinnyi on 11/21/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import "AKLocationPickerController.h"
#import "AKGooglePlacesDataSource.h"

@interface AKGooglePlacesPickerControllerViewController : AKLocationPickerController

@property (nonatomic, strong) AKGooglePlacesDataSource *placesDataSource;

@end
