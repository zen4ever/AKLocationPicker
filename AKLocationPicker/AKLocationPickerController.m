//
//  AKViewController.m
//  AKLocationPicker
//
//  Created by Andrew Kurinnyi on 10/8/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import "AKLocationPickerController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AKLocationPickerController ()

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong, readonly) CLGeocoder *geocoder;

@end

@implementation AKLocationPickerController

@synthesize geocoder=_geocoder;

- (id)initWithDataSource:(id<AKLocationPickerSource, UITableViewDataSource, UISearchDisplayDelegate>) dataSource {
    if (self = [super init]) {
        _dataSource = dataSource;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
    
    
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    self.searchController = searchDisplayController;
    
    MKMapView *mapView = [[MKMapView alloc] init];
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mapView];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [mapView addGestureRecognizer:lpgr];
    self.mapView = mapView;
    
    id<UILayoutSupport> topLayoutGuide = self.topLayoutGuide;
    id<UILayoutSupport> bottomLayoutGuide = self.bottomLayoutGuide;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(searchBar, topLayoutGuide, bottomLayoutGuide, mapView);
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[topLayoutGuide][searchBar][mapView][bottomLayoutGuide]"
                                                   options:0
                                                   metrics:nil
                                                     views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[searchBar]|"
                                                   options:0
                                                   metrics:nil
                                                     views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[mapView]|"
                                                   options:0
                                                   metrics:nil
                                                     views:views]];
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self.dataSource;
    searchDisplayController.delegate = self.dataSource;
    [mapView setShowsUserLocation:YES];
    mapView.delegate = self;
}

- (void)dropPinForLocation:(NSDictionary *)location {
    self.dataSource.currentLocation = location;
    for (id annotation in self.mapView.annotations) {
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:self];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(((CLLocation *)location[@"location"]).coordinate, span);
    [self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:self animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *currentLocation = self.dataSource.items[indexPath.row];
    if (currentLocation[@"location"]) {
        [self dropPinForLocation:currentLocation];
    } else {
        [self updateLocationFromAddress:currentLocation[@"address"]];
    }
    [self.searchController setActive:NO animated:YES];
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)updateLocationFromAddress:(NSString *)address {
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:[error description]
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
            if (placemarks.count > 0) {
                CLPlacemark *placemark = placemarks[0];
                NSDictionary *currentLocation = @{
                     @"name": placemark.thoroughfare ? placemark.thoroughfare : address,
                     @"address": [ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES) stringByReplacingOccurrencesOfString:@"\n" withString:@", "],
                     @"location": placemark.location,
                };
                [self dropPinForLocation:currentLocation];
            }
        });
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self updateLocationFromAddress:searchBar.text];
    [self.searchController setActive:NO animated:YES];
}

- (CLLocationCoordinate2D)coordinate {
    return [(CLLocation *)self.dataSource.currentLocation[@"location"] coordinate];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    NSMutableDictionary *newCurrentLocation = [self.dataSource.currentLocation mutableCopy];
    newCurrentLocation[@"location"] = newLocation;
    self.dataSource.currentLocation = [newCurrentLocation copy];
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0) {
            CLPlacemark *placemark = placemarks[0];
            NSDictionary *currentLocation = @{
                 @"name": placemark.thoroughfare ? placemark.thoroughfare : @"",
                 @"address": [ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES) stringByReplacingOccurrencesOfString:@"\n" withString:@", "],
                 @"location": newLocation,
            };
            self.dataSource.currentLocation = currentLocation;
        }
    }];
}

- (void)createNewPinFromCoordinate:(CLLocationCoordinate2D)newCoordinate {
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
   [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    if (placemarks.count > 0) {
        CLPlacemark *placemark = placemarks[0];
        NSDictionary *currentLocation = @{
             @"name": placemark.thoroughfare ? placemark.thoroughfare : @"",
             @"address": [ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES) stringByReplacingOccurrencesOfString:@"\n" withString:@", "],
             @"location": newLocation,
        };
        [self dropPinForLocation:currentLocation];
    }
   }];
    
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    NSLog(@"Long press");
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    [self createNewPinFromCoordinate:touchMapCoordinate];
}

- (NSString *)title {
    return self.dataSource.currentLocation[@"name"];
}

- (NSString *)subtitle {
    return self.dataSource.currentLocation[@"address"];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.dataSource.currentLocation) {
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
        MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
        [self.mapView setRegion:region animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == self) {
        NSString *pinID = @"location_picker_pin";
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
        if (!pin) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:self reuseIdentifier:pinID];
        } else {
            pin.annotation = self;
        }
        pin.canShowCallout = YES;
        pin.animatesDrop = YES;
        pin.draggable = YES;
        return pin;
    }
    return nil;
}

@end
