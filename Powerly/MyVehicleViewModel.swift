//
//  MyVehicleViewModel.swift
//  PowerShare
//
//  Created by ADMIN on 10/08/23.
//  
//
import Combine
import Foundation
import RxSwift

struct MyVehicleViewModel {
    var vehicles = BehaviorSubject(value: [Vehicle]())
    var refreshControl = UIRefreshControl()
    var errorMessage = PassthroughSubject<String, Never>()
    func getVehicleListAPI(completion: @escaping () -> Void) {
        NetworkManager().getVehicleList { _, _, vehicles in
            self.vehicles.onNext(vehicles)
            completion()
        }
    }
    
    func deleteVehicle(id: Int) {
        CommonUtils.showProgressHud()
        NetworkManager().deleteVehicle(id: id) { response in
            CommonUtils.hideProgressHud()
            if response.success == 1 {
                self.getVehicleListAPI {}
            } else {
                self.errorMessage.send(response.message)
            }
        }
    }
}
