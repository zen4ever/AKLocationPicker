//
//  AKViewController.h
//  AKLocationPicker
//
//  Created by Andrew Kurinnyi on 10/8/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol AKLocationPickerSource <NSObject, UITableViewDataSource>

@property (strong, nonatomic) NSArray *items;
- (NSArray *)filteredArrayForText:(NSString *)text scope:(NSString *)scope;
@end


@interface AKLocationPickerController : UIViewController<UITableViewDelegate, UISearchBarDelegate, MKAnnotation, MKMapViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) id<AKLocationPickerSource> dataSource;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSDictionary *currentLocation;

- (id)initWithDataSource:(id<AKLocationPickerSource>) dataSource;

@end
