//
//  PowerResourceDetailViewModel.swift
//  PowerShare
//
//  Created by ADMIN on 07/07/23.
//  
//

import Foundation
import GooglePlaces
import RxSwift

struct SelectTime {
    var isFull = false
    let time: Int
}

class ChargePointDetailViewModel: Sendable {
    var times = [SelectTime]()
    var selectedIndex = 0
    var selectedConnectors = [Connector]()
    var powerSource = BehaviorSubject<ChargePoint?>(value: nil)
    var medias = BehaviorSubject(value: [Media]())
    var mediaPlaces = BehaviorSubject(value: [GMSPlacePhotoMetadata]())
    var bookingDateTime: String?
    var reservations: [Reservation] = []
    var isOpenStartCharging = false
    init(chargePoint: ChargePoint) {
        self.powerSource.onNext(chargePoint)
    }
    
    func startTransaction(id: String, quantity: String, connectors: [Connector]) async -> (Int, String, ActiveSession?)? {
        do {
            CommonUtils.showProgressHud()
            let response = try await NetworkManager().startTransaction(id: id, quantity: quantity, connectors: connectors)
            CommonUtils.hideProgressHud()
            if response.success == 1 {
                let decoder = JSONDecoder()
                if let jsonData = try? response.json["results"].rawData(),
                   let activeSession = try? decoder.decode(ActiveSession.self, from: jsonData) {
                    return (response.success, response.message, activeSession)
                }
            }
            return (response.success, response.message, nil)
        } catch {
        }
        return nil
    }
    
    func setUpTimeSlot(chargePoint: ChargePoint) {
        if let limitType = PriceUnit(rawValue: chargePoint.sessionLimitType),
           chargePoint.sessionLimitValue > 0,
            limitType == .minutes {
            times = generateTimeSlots(limit: Int(chargePoint.sessionLimitValue))
        } else {
            times = generateDefaultTimeSlots()
        }
    }

    private func generateDefaultTimeSlots() -> [SelectTime] {
        var times = [SelectTime]()
        times.append(contentsOf: [SelectTime(isFull: true, time: 0), SelectTime(time: 10), SelectTime(time: 15)])
        times.append(contentsOf: (1...24).map { SelectTime(time: 30 * $0) })
        return times
    }
    
    private func generateTimeSlots(limit: Int) -> [SelectTime] {
        var times = [SelectTime]()
        
        if limit <= 60 {
            let slots = (limit / 10)
            if slots > 0 {
                times.append(contentsOf: (1...slots).map { SelectTime(time: 10 * $0) })
            }
        } else {
            times.append(contentsOf: [SelectTime(time: 10), SelectTime(time: 15)])
            times.append(contentsOf: (1...(limit / 30)).map { SelectTime(time: 30 * $0) })
        }
        
        if !times.contains(where: { $0.time >= limit }) {
            times.append(SelectTime(time: limit))
        }

        return times
    }

    func retrieveCards(completed: @escaping (([Card]) -> Void)) {
        CommonUtils.showProgressHud()
        NetworkManager().getCards { _, _, cards in
            CommonUtils.hideProgressHud()
            completed(cards)
        }
    }
    
    func getPowerSource() -> ChargePoint? {
        return try? powerSource.value()
    }
    
    func getPowerSourceDetail() {
        guard let powerSource = getPowerSource() else {
            return
        }
        NetworkManager().getPowerSource(id: powerSource.id) { success, _, powerSource in
            if success == 1 {
                self.powerSource.onNext(powerSource)
            }
        }
    }
    
    func getMediaOfStation() {
        if let powerSource = getPowerSource(), !powerSource.isGoogle {
            MediaService().getPowerSourceMediaList(id: powerSource.id) { _, _, medias in
                self.medias.onNext(medias)
            }
        }
    }
}

struct OpeningHours: Codable {
    let weekdays: [String]
    let periods: [String]

    enum CodingKeys: String, CodingKey {
        case weekdays = "Weekdays"
        case periods = "Periods"
    }
}
