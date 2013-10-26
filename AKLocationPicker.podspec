Pod::Spec.new do |s|
  s.name         = "AKLocationPicker"
  s.version      = "1.0.3"
  s.summary      = "A controller which allows user to pick location from a map."

  s.description  = <<-DESC
                   A controller which allows user to pick location from a map.

                   * Allows to plug custom datasources
                   * There is an AddressBook datasource which searches for addresses in user contacts
                   * User can drag and drop pin on the map,
                     or do a longpress gesture to put pin in a certain point
                   DESC

  s.homepage     = "https://github.com/zen4ever/AKLocationPicker"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Andrii Kurinnyi" => "andrew@marpasoft.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/zen4ever/AKLocationPicker.git", :tag => "1.0.3" }

  s.source_files  = 'AKLocationPicker/*.{h,m}'

  s.frameworks = 'AddressBook', 'AddressBookUI', 'CoreLocation', 'MapKit'

  s.requires_arc = true

  s.dependency 'RHAddressBook', '~> 1.0.2'
end
