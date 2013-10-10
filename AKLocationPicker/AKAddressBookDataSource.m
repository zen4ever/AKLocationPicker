//
//  AKAddressBookDataSource.m
//  AKLocationPicker
//
//  Created by Andrew Kurinnyi on 10/9/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import "AKAddressBookDataSource.h"
#import <AddressBookUI/AddressBookUI.h>
#import <RHAddressBook/RHAddressBook.h>
#import <RHAddressBook/RHPerson.h>

@interface AKAddressBookDataSource()

@property (strong, nonatomic) NSArray *results;
@property (strong, nonatomic, readonly) NSArray* addresses;
@property (strong, nonatomic, readonly) RHAddressBook* addressBook;

@end

@implementation AKAddressBookDataSource

@synthesize addresses=_addresses;
@synthesize addressBook=_addressBook;

- (id)init {
    if (self = [super init]) {
        if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusNotDetermined) {
            [self.addressBook requestAuthorizationWithCompletion:nil];
        }
    }
    return self;
}

- (RHAddressBook *)addressBook {
    if (!_addressBook) {
        _addressBook = [[RHAddressBook alloc] init];
    }
    return _addressBook;
}

- (NSArray *)addresses {
    if (!_addresses) {
        NSArray* people = [self.addressBook people];
        NSMutableArray *tempAddresses = [NSMutableArray arrayWithCapacity:people.count];
        for (RHPerson *person in people) {
            RHMultiDictionaryValue* personAddresses = [person addresses];
            for (NSInteger i=0; i<personAddresses.count; i++) {
                NSDictionary *address = [personAddresses valueAtIndex:i];
                
                [tempAddresses addObject:@{
                    @"name": person.compositeName,
                    @"value": [ABCreateStringWithAddressDictionary(address, YES) stringByReplacingOccurrencesOfString:@"\n" withString:@", "],
                }];
            }
        }
        _addresses = [tempAddresses copy];
    }
    return _addresses;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"search_cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    NSDictionary *result = self.results[indexPath.row];
    cell.textLabel.text = result[@"name"];
    cell.detailTextLabel.text = result[@"value"];
    return cell;
}

- (NSArray *)filteredArrayForText:(NSString *)text scope:(NSString *)scope {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(value CONTAINS[cd] $text)"];
    return [self.addresses filteredArrayUsingPredicate:[searchPredicate predicateWithSubstitutionVariables:@{@"text": text}]];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString *searchString = controller.searchBar.text;
    self.results = [self filteredArrayForText:searchString scope:nil];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    self.results = [self filteredArrayForText:searchString scope:nil];
    return YES;
}

@end
