//
//  StationViewModel.swift
//  PowerShare
//
//  Created by ADMIN on 15/06/23.
//  
//

import Foundation
import RxSwift

class StationViewModel {
    var connectors = [Connector]()
    var filterConnectors = BehaviorSubject(value: [Connector]())
    var selectedConnectors: [Connector] = []
    
    var amenities = BehaviorSubject(value: [Amenity]())
    var selectedAmenities: [Amenity] = []
    
    var chargerTypes = [ChargerType]()
    var filterChargerTypes = BehaviorSubject(value: [ChargerType]())
    var selectedType: ChargerType?
    var isForExternal = false
    
    func getConnectors() -> [Connector] {
        if let connectors = try? filterConnectors.value() {
            return connectors
        }
        return []
    }
    
    func getAmenities() -> [Amenity] {
        do {
            return try self.amenities.value()
        } catch {
            return [Amenity]()
        }
    }
    
    func updateCurrentType(currentType: String) {
        let filter = chargerTypes.filter({ $0.currentType == currentType })
        self.filterChargerTypes.onNext(filter)
    }
    
    func getEvConnectors(category: String) {
        NetworkManager().getEvConnectors(category: category) { _, _, connectors in
            self.filterConnectors.onNext(connectors)
            self.connectors = connectors
        }
    }
    
    func getEvAmenities(selectedAmenity: [Amenity]? = nil) {
        let selectedAmenityIDs = Set(selectedAmenity?.map { $0.id } ?? [])

        NetworkManager().getEvAmenities { [weak self] _, _, amenities in
            guard let self = self else { return }
            let updatedAmenities = amenities.map { amenity -> Amenity in
                var updatedAmenity = amenity
                if selectedAmenityIDs.contains(updatedAmenity.id) {
                    updatedAmenity.isSelected = true
                }
                return updatedAmenity
            }
            self.amenities.onNext(updatedAmenities)
        }
    }

    func updateEvConnectors(connector: Connector, index: Int) {
        do {
            var connectors = try filterConnectors.value()
            if connectors.indices.contains(index) {
                connectors[index] = connector
                self.filterConnectors.onNext(connectors)
            }
        } catch {
        }
    }
    
    func updateEvAmenities(amenity: Amenity, index: Int) {
        do {
            var amenities = try amenities.value()
            if amenities.indices.contains(index) {
                amenities[index] = amenity
                self.amenities.onNext(amenities)
            }
        } catch {
        }
    }
}

enum CurrentType: String {
    case ac = "AC"
    case dc = "DC"
}
