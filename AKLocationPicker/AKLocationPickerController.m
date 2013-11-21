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

@property (nonatomic, strong, readonly) CLGeocoder *geocoder;

@end

@implementation AKLocationPickerController

@synthesize geocoder=_geocoder;
@synthesize currentLocation=_currentLocation;

- (id)initWithDataSource:(id<AKLocationPickerSource>) dataSource {
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
    searchDisplayController.delegate = self;
    [mapView setShowsUserLocation:YES];
    mapView.delegate = self;
    [self displayCurrentLocation];
}

- (void)dropPinForLocation:(NSDictionary *)location {
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
    self.currentLocation = self.dataSource.items[indexPath.row];
    [self displayCurrentLocation];
    [self.searchController setActive:NO animated:YES];
}

- (void)displayCurrentLocation {
    if (self.currentLocation) {
        if (self.currentLocation[@"location"]) {
            [self dropPinForLocation:self.currentLocation];
        } else {
            [self updateLocationFromAddress:self.currentLocation[@"address"] name:self.currentLocation[@"name"]];
        }
    }
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)updateLocationFromAddress:(NSString *)address name:(NSString *)name {
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
                NSString *newName = name ? name : (placemark.thoroughfare ? placemark.thoroughfare : address);
                self.currentLocation = @{
                     @"name": newName,
                     @"address": [ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES) stringByReplacingOccurrencesOfString:@"\n" withString:@", "],
                     @"location": placemark.location,
                };
                [self dropPinForLocation:self.currentLocation];
            }
        });
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self updateLocationFromAddress:searchBar.text name:nil];
    [self.searchController setActive:NO animated:YES];
}

- (CLLocationCoordinate2D)coordinate {
    return [(CLLocation *)self.currentLocation[@"location"] coordinate];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    NSMutableDictionary *newCurrentLocation = [self.currentLocation mutableCopy];
    newCurrentLocation[@"location"] = newLocation;
    self.currentLocation = [newCurrentLocation copy];
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0) {
            CLPlacemark *placemark = placemarks[0];
            NSDictionary *currentLocation = @{
                 @"name": placemark.thoroughfare ? placemark.thoroughfare : @"",
                 @"address": [ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES) stringByReplacingOccurrencesOfString:@"\n" withString:@", "],
                 @"location": newLocation,
            };
            self.currentLocation = currentLocation;
        }
    }];
}

- (void)createNewPinFromCoordinate:(CLLocationCoordinate2D)newCoordinate {
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
   [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    if (placemarks.count > 0) {
        CLPlacemark *placemark = placemarks[0];
        self.currentLocation = @{
             @"name": placemark.thoroughfare ? placemark.thoroughfare : @"",
             @"address": [ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES) stringByReplacingOccurrencesOfString:@"\n" withString:@", "],
             @"location": newLocation,
        };
        [self dropPinForLocation:self.currentLocation];
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
    return self.currentLocation[@"name"];
}

- (NSString *)subtitle {
    return self.currentLocation[@"address"];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.currentLocation) {
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

- (NSArray *)updateWithCurrentLocation:(NSArray *)items {
    NSArray *newItems = [NSArray array];
    if (self.currentLocation) {
        newItems = @[self.currentLocation];
    }
    return [newItems arrayByAddingObjectsFromArray:items];
}

- (BOOL)searchWithString:(NSString *)searchString {
    if (searchString.length > 0) {
        if ([self.dataSource respondsToSelector:@selector(filteredArrayForText:)]) {
            self.dataSource.items = [self updateWithCurrentLocation:[self.dataSource filteredArrayForText:searchString]];
            return YES;
        } else {
            [self.dataSource searchWithString:searchString completion:^(NSArray *results){
                self.dataSource.items = [self updateWithCurrentLocation:results];
                [self.searchController.searchResultsTableView reloadData];
            }];
            return NO;
        }
    } else {
        if (self.currentLocation) {
            self.dataSource.items = @[self.currentLocation];
        } else {
            self.dataSource.items = @[];
        }
        return YES;
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString *searchString = controller.searchBar.text;
    return [self searchWithString:searchString];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return [self searchWithString:searchString];
}

- (void)setCurrentLocation:(NSDictionary *)currentLocation {
    _currentLocation = currentLocation;
    [self.delegate selectedNewLocation:currentLocation];
}

// Fixes for UISearchDisplayController when displayed in UIPopoverController
// Taken from article by Peter Steinberger
// http://petersteinberger.com/blog/2013/fixing-uisearchdisplaycontroller-on-ios-7/

- (void)setAllViewsExceptSearchHidden:(BOOL)hidden animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.25f : 0.f animations:^{
        for (UIView *view in self.view.subviews) {
            if (view != self.searchDisplayController.searchResultsTableView &&
                view != self.searchDisplayController.searchBar) {
                view.alpha = hidden ? 0.f : 1.f;
            }
        }
    }];
}

- (void)correctFramesForSearchDisplayControllerBeginSearch:(BOOL)beginSearch {
    [self.navigationController setNavigationBarHidden:beginSearch animated:YES];
    [self setAllViewsExceptSearchHidden:beginSearch animated:YES];
    [UIView animateWithDuration:0.25f animations:^{
        self.searchDisplayController.searchResultsTableView.alpha = beginSearch ? 1.f : 0.f;
    }];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self correctFramesForSearchDisplayControllerBeginSearch:YES];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self correctFramesForSearchDisplayControllerBeginSearch:NO];
}

@end
