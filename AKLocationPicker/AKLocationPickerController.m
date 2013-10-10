//
//  AKViewController.m
//  AKLocationPicker
//
//  Created by Andrew Kurinnyi on 10/8/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import "AKLocationPickerController.h"
#import "AKAddressBookDataSource.h"
#import <MapKit/MapKit.h>

@interface AKLocationPickerController ()

@property (strong, nonatomic) id dataSource;
@property (nonatomic, strong) UISearchDisplayController *searchController;

@end

@implementation AKLocationPickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:searchBar];
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    self.searchController = searchDisplayController;
    
    MKMapView *mapView = [[MKMapView alloc] init];
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mapView];
    
    id<UILayoutSupport> topLayoutGuide = self.topLayoutGuide;
    id<UILayoutSupport> bottomLayoutGuide = self.bottomLayoutGuide;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(searchBar, topLayoutGuide, bottomLayoutGuide, mapView);
    NSString *verticalConstraint = @"V:[topLayoutGuide][searchBar][mapView][bottomLayoutGuide]";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraint options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchBar]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:0 metrics:nil views:views]];
    

    self.dataSource = [[AKAddressBookDataSource alloc] init];
    
    searchDisplayController.searchResultsDataSource = self.dataSource;
    searchDisplayController.delegate = self.dataSource;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
