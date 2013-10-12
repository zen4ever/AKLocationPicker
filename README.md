AKLocationPicker
================

A controller which allows user to pick a location from MKMapView.

* User can drag and drop pin on the map
* User can do a longpress gesture to put a pin in a certain point

![Map](https://github.com/zen4ever/AKLocationPicker/raw/master/screenshots/screenshot_1.png)

* There is an AddressBook datasource which searches for addresses in the user contacts

![AddressBook Search](https://github.com/zen4ever/AKLocationPicker/raw/master/screenshots/screenshot_2.png)

* You can also create custom datasources 

Usage
=====

Just create a AKLocationPickerController with your data source. Optionally, you
can specify initial location.

```objective-c
AKLocationPickerController *locationPicker = [[AKLocationPickerController alloc] initWithDataSource:[[AKAddressBookDataSource alloc] init]]
locationPicker.currentLocation = @{
    @"name": @"Farmers Market",
    @"address": @"6333 W 3rd St  Los Angeles, CA 90036",
}
```
