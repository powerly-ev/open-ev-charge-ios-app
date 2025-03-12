//
//  HomeUtils.swift
//  Powerly
//
//  Created by ADMIN on 29/06/24.
//  
//
import CoreLocation

import Foundation
import GooglePlaces

class HomeUtils {
    static func distanceBetweenCoordinates(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let coordinate1 = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate2 = CLLocation(latitude: lat2, longitude: lon2)
        
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        return distanceInMeters
    }
    
    static func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadiusKm: Double = 6371.0

        let dLat = degreesToRadians(lat2 - lat1)
        let dLon = degreesToRadians(lon2 - lon1)

        let abc = sin(dLat / 2) * sin(dLat / 2) +
                cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) *
                sin(dLon / 2) * sin(dLon / 2)
        let cde = 2 * atan2(sqrt(abc), sqrt(1 - abc))

        return earthRadiusKm * cde
    }

    static func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    static func findNearestPowerSource(from powerSources: [ChargePoint], currentLocation: CLLocationCoordinate2D) -> ChargePoint? {
        guard !powerSources.isEmpty else { return nil }

        var nearestPowerSource: ChargePoint?
        var smallestDistance: Double = Double.greatestFiniteMagnitude

        for powerSource in powerSources {
            let distance = haversineDistance(
                lat1: currentLocation.latitude,
                lon1: currentLocation.longitude,
                lat2: Double(powerSource.latitude) ?? 0,
                lon2: Double(powerSource.longitude) ?? 0
            )
            if distance < smallestDistance {
                smallestDistance = distance
                nearestPowerSource = powerSource
            }
        }

        return nearestPowerSource
    }
}
