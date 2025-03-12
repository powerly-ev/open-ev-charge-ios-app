//
//  LocationManager.swift
//  PowerShare
//
//  Created by admin on 12/01/22.
//  
//

import CoreLocation
import Foundation

class LocationManager: NSObject {
    static let shared = LocationManager()
    var currentCountry: Country?
    var counter = 0
    var location: CLLocation?
    var locationManager = CLLocationManager()
    var currentAuthorizationStatus: CLAuthorizationStatus!
    var onLocation: ((CLLocation?) -> Void)?
    var updatedLocation: ((CLLocation?) -> Void)?
    override init() {
        super.init()
        counter = 0
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func checkLocationEnabled() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            return true
            
        case .authorizedWhenInUse:
            return true
            
        case .notDetermined:
            return false
            
        case .denied:
            return false
            
        case .restricted:
            return false
            
        default:
            return false
        }
    }
    
    func startUpdatingLocation() {
        counter = 0
        locationManager.startUpdatingLocation()
    }

    func getUserLocation() -> CLLocation? {
        return location
    }
    
    func getCenterLocation(forName placeName: String?, completion: @escaping (CLLocation?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(placeName ?? "") { placemarks, _ in
            if (placemarks?.count ?? 0) > 0 {
                let placemark = placemarks?.first as? CLPlacemark
                completion(placemark?.location)
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.denied:
            currentAuthorizationStatus = CLAuthorizationStatus.denied
            startUpdatingLocation()
            
        case CLAuthorizationStatus.restricted:
            currentAuthorizationStatus = CLAuthorizationStatus.restricted
            startUpdatingLocation()
            
        case CLAuthorizationStatus.authorizedAlways:
            currentAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
            startUpdatingLocation()
            
        case CLAuthorizationStatus.authorizedWhenInUse:
            currentAuthorizationStatus = CLAuthorizationStatus.authorizedWhenInUse
            startUpdatingLocation()
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if currentAuthorizationStatus == .denied || currentAuthorizationStatus == .restricted {
            counter = 0
            location = nil
            onLocation?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        locationManager.stopUpdatingLocation()
        if counter == 1 {
            return
        }
        updatedLocation?(location)
        onLocation?(location)
        counter += 1
        if let latitude = location?.coordinate.latitude.description, let longitude = location?.coordinate.longitude.description {
            userDefault.set(latitude, forKey: "latitude")
            userDefault.set(longitude, forKey: "longitude")
            userDefault.synchronize()
        }
    }
    
    func getCountryIdFromCurrentLocation() async -> Country? {
        guard let latitudeString = userDefault.string(forKey: "latitude"),
              let longitudeString = userDefault.string(forKey: "longitude"),
              let latitude = Double(latitudeString),
              let longitude = Double(longitudeString) else {
            return nil
        }

        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first,
                  let isoCountryCode = placemark.isoCountryCode else {
                return nil
            }
            let country = UserManager.shared.countryList.first { $0.iso == isoCountryCode }
            self.currentCountry = country
            return country
        } catch {
            print("Error in reverse geocoding: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateCurrencyCountry() async -> Bool {
        let country = await LocationManager.shared.getCountryIdFromCurrentLocation()
        if userDefault.object(forKey: UserDefaultKey.kSavedCurrency.rawValue) != nil {
            return false
        }
        if let country = country, let oldCurrency = UserManager.shared.user?.currency, country.currency != oldCurrency {
            var updateProfile = UpdateProfile()
            updateProfile.currency = country.currencyIso
            let response = try? await NetworkManager().updateProfile(updateProfile: updateProfile)
            if response?.success == 1 {
                UserManager.shared.user?.currency = country.currency
            }
            return true
        }
        return false
    }
}
