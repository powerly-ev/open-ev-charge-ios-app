//
//  AddVehicleViewModel.swift
//  PowerShare
//
//  Created by ADMIN on 20/05/23.
//  
//

import Foundation
import RxCocoa
import RxSwift

class AddVehicleViewModel {
    var data = BehaviorSubject<AddVehicle>(value: AddVehicle(details: [VehicleDetail(type: .manufacturer, title: NSLocalizedString("manufacturer", comment: "")),
                                                                      VehicleDetail(type: .model, title: NSLocalizedString("model", comment: "")),
                                                                      VehicleDetail(type: .details, title: NSLocalizedString("details", comment: ""))]))
    var makeSection = BehaviorSubject(value: [MakeSection]())
    var filteredMakeSection: [MakeSection] = []
    var filteredModelSection = BehaviorSubject(value: [VehicleModel]())
    var modelList: [VehicleModel] = []
    let addVehicleResponse = PublishSubject<Response>()
    var fuelTypes = ["Fuel", "Hybrid", "Plug-In Hybrid", "Electric", "Other"]
    var years: [Int] = []
    var selectedIndex = -1
    var topCarColors: [CarColor] = []
    var vehicle: Vehicle?
    
    func updateDataFromVehicle(vehicle: Vehicle) {
        if var addVehicle = self.getData() {
            addVehicle.manufacturer = vehicle.make
            addVehicle.model = vehicle.model
            addVehicle.title = vehicle.title
            addVehicle.year = vehicle.year
            addVehicle.color = vehicle.color
            addVehicle.fuelType = vehicle.fuelType
            addVehicle.connector = vehicle.chargingConnector
            
            updateData(model: addVehicle)
        }
    }
    
    func setupColor() {
        topCarColors = Array(CommonUtils.allCarColors().prefix(upTo: 5))
    }
    
    func updateColor(color: CarColor) {
        if topCarColors.count > 0 {
            topCarColors[0] = color
        }
    }
    
    func setupYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        for year in stride(from: currentYear, through: 1990, by: -1) {
            years.append(year)
        }
    }
    
    func getMakeSections() -> [MakeSection] {
        return (try? makeSection.value()) ?? []
    }
    
    func getData() -> AddVehicle? {
        return  try? data.value()
    }
    
    func updateData(model: AddVehicle) {
        self.data.onNext(model)
    }
    
    func callMakeListAPI() {
        NetworkManager().getMakeList { _, _, makeList in
//            let sortedItems = makeList.sorted { $0.name < $1.name }
            let sortedItems = makeList.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            let sections = Dictionary(grouping: sortedItems, by: { $0.name.prefix(1).uppercased() })

            let sortedFirstLetters = sections.keys.sorted()

            let resultSections = sortedFirstLetters.map { firstLetter in
                return MakeSection(name: firstLetter, makes: sections[firstLetter] ?? [])
            }
            self.makeSection.onNext(resultSections)
        }
    }
    
    func callModelListAPI(makeId: Int) {
        NetworkManager().getModelList(makeId: makeId) { _, _, models in
            self.modelList = models
            self.filteredModelSection.onNext(models)
        }
    }
    
    func addUpdateVehicleAPI() {
        if let vehicle = self.vehicle {
            guard let addVehicle = self.getData() else {
                return
            }
            guard let title = addVehicle.title, let make = addVehicle.manufacturer, let model = addVehicle.model, let year = addVehicle.year, let color = addVehicle.color, let fuelType = addVehicle.fuelType else {
                return
            }
            var dic: [String: Any] = ["title": title, "vehicle_make_id": make.id, "vehicle_make_name": make.name, "vehicle_model_id": model.id, "vehicle_model_name": model.name, "year": year, "color": color, "fuel_type": fuelType]
            if let fuelType = addVehicle.fuelType, fuelType == "Plug-In Hybrid" || fuelType == "Electric", let connector = addVehicle.connector {
                dic["charging_connector_id"] = connector.id
            } else {
                dic["charging_connector_id"] = ""
            }
            CommonUtils.showProgressHud()
            NetworkManager().updateVehicle(id: vehicle.id, dic: dic) { response in
                CommonUtils.hideProgressHud()
                self.addVehicleResponse.onNext(response)
            }
        } else {
            guard let addVehicle = self.getData() else {
                return
            }
            guard let title = addVehicle.title, let make = addVehicle.manufacturer, let model = addVehicle.model, let year = addVehicle.year, let color = addVehicle.color, let fuelType = addVehicle.fuelType else {
                return
            }
            var dic: [String: Any] = ["title": title, "vehicle_make_id": make.id, "vehicle_make_name": make.name, "vehicle_model_id": model.id, "vehicle_model_name": model.name, "year": year, "color": color, "fuel_type": fuelType]
            if let fuelType = addVehicle.fuelType, fuelType == "Plug-In Hybrid" || fuelType == "Electric", let connector = addVehicle.connector {
                dic["charging_connector_id"] = connector.id
            }
            CommonUtils.showProgressHud()
            NetworkManager().addVehicle(dic: dic) { response in
                CommonUtils.hideProgressHud()
                self.addVehicleResponse.onNext(response)
            }
        }
    }
}
