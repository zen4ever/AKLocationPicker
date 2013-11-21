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
@required
@property (strong, nonatomic) NSArray *items;
@optional
- (NSArray *)filteredArrayForText:(NSString *)text;
- (void)searchWithString:(NSString *)searchString completion:(void(^)(NSArray *results))completionHandler;
@end

@protocol AKLocationPickerDelegate <NSObject>
@required

- (void)selectedNewLocation:(NSDictionary *)location;

@end


@interface AKLocationPickerController : UIViewController<UITableViewDelegate, UISearchBarDelegate, MKAnnotation, MKMapViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) id<AKLocationPickerSource> dataSource;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSDictionary *currentLocation;
@property (nonatomic, weak) id<AKLocationPickerDelegate> delegate;

- (id)initWithDataSource:(id<AKLocationPickerSource>) dataSource;

@end
