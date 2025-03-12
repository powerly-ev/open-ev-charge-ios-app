//
//  HomeViewModel.swift
//  PowerShare
//
//  Created by admin on 24/01/23.
//  
//
import CoreLocation
import Foundation
import GoogleMaps
import GooglePlaces
import RxSwift

class HomeViewModel {
    var sliders = BehaviorSubject(value: [HomeSlider]())
    var powerSources = BehaviorSubject(value: [ChargePoint]())
    var googlePowerSources: [ChargePoint] = []
    var updateUserData = PublishSubject<Bool>()
    var visitedPowerSources = BehaviorSubject(value: [ChargePoint]())
    var connectors = BehaviorSubject(value: [Connector]())
    var amenities = BehaviorSubject(value: [Amenity]())
    var stations = ["Any", "2+", "4+", "6+"]
    
    var loadUserDetailAPI = false
    var autoScrollTimer: Timer?
    var currentIndex = 0
    let adWidth = screenWidth
    var isLastOrder = false
    var isLoadedMap: Bool = false
    var selectedConnectorFilter = [Connector]()
    var selectedAmenityFilter = [Amenity]()
    var selectedStationCountFilter = ""
    var oldLocation: CLLocationCoordinate2D?
    var selectedChargePoint: ChargePoint?
    var markers = [GMSMarker]()
    
    func setUpSliderData() {
        let referValue = CommonUtils.isUserLoggedIn() ? HomeSlider(type: .refer, title: NSLocalizedString("refer_and_earn", comment: ""), description: NSLocalizedString("refer_earn_desc", comment: ""), image: "club_electric", buttonName: NSLocalizedString("refer_now", comment: "")):
        HomeSlider(type: .refer, title: NSLocalizedString("refer_and_earn_guest", comment: ""), description: NSLocalizedString("refer_earn_desc_guest", comment: ""), image: "club_electric", buttonName: NSLocalizedString("refer_now_guest", comment: ""))
        let data = [HomeSlider(type: .club, title: NSLocalizedString("club_electric", comment: ""), description: NSLocalizedString("club_electric_desc", comment: ""), image: "share_earn", buttonName: NSLocalizedString("join_now", comment: "")),
                    referValue,
                    HomeSlider(type: .buyEV, title: NSLocalizedString("buy_ev_charger", comment: ""), description: NSLocalizedString("buy_ev_charger_desc", comment: ""), image: "buy_ev", buttonName: NSLocalizedString("buy_now", comment: ""))
        ]
        self.sliders.onNext(data)
    }
    
    func getPowerSources() -> [ChargePoint] {
        do {
            return try powerSources.value()
        } catch {
            return []
        }
    }
    
    func getVisitedPowerSources() -> [ChargePoint] {
        do {
            return try visitedPowerSources.value()
        } catch {
            return []
        }
    }
    
    func getUserDetailApi(completion: @escaping (() -> Void)) {
        if CommonUtils.isUserLoggedIn() {
            Task.detached {
                let isSuccess = try? await UserManager.webserviceCallForUserDetails()
                completion()
                self.loadUserDetailAPI = true
                if (isSuccess ?? false) == true, UserManager.shared.user != nil {
                    self.updateUserData.onNext(true)
                }
            }
        } else {
            completion()
        }
    }
    
    func getNearByPowerSource(latitude: Double, longitude: Double, callVisited: Bool, callExternalAPI: Bool) {
        guard CommonUtils.isUserLoggedIn() else { return }
        
        let strLatitude = String(format: "%.9f", latitude)
        let strLongitude = String(format: "%.9f", longitude)
        
        let networkManager = NetworkManager()
        networkManager.getPowerSourcesNearest(latitude: strLatitude, longitude: strLongitude, limit: 100) { [weak self] success, _, chargePoints in
            guard let self = self, success == 1 else { return }
            
            var existedPowerSources = self.getPowerSources()
            self.updatePowerSources(&existedPowerSources, with: chargePoints)
            self.powerSources.onNext(existedPowerSources)
        }
    }

    func updatePowerSources(_ existedPowerSources: inout [ChargePoint], with newChargePoints: [ChargePoint]) {
        for newChargePoint in newChargePoints {
            if let index = existedPowerSources.firstIndex(where: { $0.id == newChargePoint.id }) {
                existedPowerSources[index] = newChargePoint
            } else {
                existedPowerSources.append(newChargePoint)
            }
        }
    }

    func getConnectors() -> [Connector] {
        do {
            return try self.connectors.value()
        } catch {
            return [Connector]()
        }
    }
    
    func getAmenities() -> [Amenity] {
        do {
            return try self.amenities.value()
        } catch {
            return [Amenity]()
        }
    }
    
    func getEvConnectors(category: String) {
        NetworkManager().getEvConnectors(category: category) { _, _, connectors in
            self.connectors.onNext(connectors)
        }
    }
    
    func getEvAmenities() {
        NetworkManager().getEvAmenities { _, _, amenities in
            self.amenities.onNext(amenities)
        }
    }
}
