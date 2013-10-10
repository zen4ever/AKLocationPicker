//
//  AKViewController.h
//  AKLocationPicker
//
//  Created by Andrew Kurinnyi on 10/8/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol AKLocationPickerSource <NSObject>

@property (strong, nonatomic) NSDictionary *currentLocation;
@property (strong, nonatomic) NSArray *items;

@end


@interface AKLocationPickerController : UIViewController<UITableViewDelegate, UISearchBarDelegate, MKAnnotation, MKMapViewDelegate>

@property (strong, nonatomic) id<AKLocationPickerSource, UITableViewDataSource, UISearchDisplayDelegate> dataSource;
- (id)initWithDataSource:(id<AKLocationPickerSource, UITableViewDataSource, UISearchDisplayDelegate>) dataSource;

@end
