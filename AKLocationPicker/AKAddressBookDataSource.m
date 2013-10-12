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

@property (strong, nonatomic, readonly) NSArray* addresses;
@property (strong, nonatomic, readonly) RHAddressBook* addressBook;

@end

@implementation AKAddressBookDataSource

@synthesize addresses=_addresses;
@synthesize addressBook=_addressBook;
@synthesize items=_items;

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
                    @"address": [ABCreateStringWithAddressDictionary(address, YES) stringByReplacingOccurrencesOfString:@"\n" withString:@", "],
                }];
            }
        }
        _addresses = [tempAddresses copy];
    }
    return _addresses;
}

- (void)configureCell:(UITableViewCell *)cell withItem:(NSDictionary *)item {
    cell.textLabel.text = item[@"name"];
    cell.detailTextLabel.text = item[@"address"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"search_cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    [self configureCell:cell withItem:self.items[indexPath.row]];
    return cell;
}

- (NSArray *)filteredArrayForText:(NSString *)text scope:(NSString *)scope {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(address CONTAINS[cd] $text)"];
    return [self.addresses filteredArrayUsingPredicate:[searchPredicate predicateWithSubstitutionVariables:@{@"text": text}]];
}

@end
