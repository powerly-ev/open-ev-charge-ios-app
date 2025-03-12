//
//  LocationUtils.swift
//  Powerly
//
//  Created by ADMIN on 20/06/24.
//  
//

import CoreLocation
import UIKit

class LocationUtils {
    
    static func handleLocationAuthorization() {
        let url = URL(string: UIApplication.openSettingsURLString)
        
        guard CLLocationManager.locationServicesEnabled() else {
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        case .authorizedAlways, .authorizedWhenInUse:
            // Location services are enabled and authorized
            break
            
        case .notDetermined:
            LocationManager.shared.startUpdatingLocation()
            
        @unknown default:
            // Handle future cases
            break
        }
    }
}

