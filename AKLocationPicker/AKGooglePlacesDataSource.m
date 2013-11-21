//
//  AKGooglePlacesDataSource.m
//  AKLocationPickerExample
//
//  Created by Andrew Kurinnyi on 11/21/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import "AKGooglePlacesDataSource.h"
#import "NSString+URLEncoding.h"

@interface AKGooglePlacesDataSource()

@property (nonatomic, strong) NSString *googleAPIKey;
@property (nonatomic, retain) NSOperationQueue *searchQueue;

@end

@implementation AKGooglePlacesDataSource

@synthesize items=_items;

- (instancetype)initWithAPIKey:(NSString *)googleAPIKey {
    if (self = [super init]) {
        self.googleAPIKey = googleAPIKey;
        self.searchQueue = [NSOperationQueue new];
        [self.searchQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)searchWithString:(NSString *)searchString completion:(void (^)(NSArray *))completionHandler {
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&sensor=true&key=%@",
         [searchString urlEncodeUsingEncoding:NSUTF8StringEncoding],
         [self.googleAPIKey urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    [self.searchQueue cancelAllOperations];
    [self.searchQueue addOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                                error:&error];
        NSLog(@"JSON: %@", json);
        NSArray* places = json[@"predictions"];
        NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:places.count];
        for (NSDictionary *place in places) {
            NSString *address = place[@"description"];
            NSString *name = place[@"description"];
            if ([place[@"terms"] count] > 0){
                name = place[@"terms"][0][@"value"];
            }
            [results addObject:@{
                @"name": name,
                @"address": address,
            }];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionHandler([results copy]);
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (void)configureCell:(UITableViewCell *)cell withItem:(NSDictionary *)item {
    cell.textLabel.text = item[@"name"];
    cell.detailTextLabel.text = item[@"address"];
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

@end
