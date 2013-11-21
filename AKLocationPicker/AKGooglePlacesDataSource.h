//
//  AKGooglePlacesDataSource.h
//  AKLocationPickerExample
//
//  Created by Andrew Kurinnyi on 11/21/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKLocationPickerController.h"

@interface AKGooglePlacesDataSource : NSObject<AKLocationPickerSource>

- (instancetype)initWithAPIKey:(NSString *)googleAPIKey;

@end
