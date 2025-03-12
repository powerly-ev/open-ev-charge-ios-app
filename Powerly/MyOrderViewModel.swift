//
//  MyOrderViewModel.swift
//  PowerShare
//
//  Created by admin on 09/01/23.
//  
//
import Combine
import Foundation
import RxSwift
import UIKit

enum MyOrderSelection: Int {
    case active = 0
    case past = 2
}

struct MyOrderMenuOtion {
    let type: MyOrderSelection
    let text: String
    var isSelected: Bool
}

class MyOrderViewModel {
    var activeSessions = BehaviorSubject(value: [ActiveSession]())
    var pastSession = BehaviorSubject(value: [ActiveSession]())
    var errorMessage = PassthroughSubject<String, Never>()
    
    var menuOptions = BehaviorSubject<[MyOrderMenuOtion]>(value: [MyOrderMenuOtion(type: .active, text: NSLocalizedString("active_session", comment: ""),
                                                                                  isSelected: false),
                                                                 MyOrderMenuOtion(type: .past, text: NSLocalizedString("history", comment: ""), isSelected: false)])
    var pagePast = 1
    var isLoading = false
    
    var pageOwner = 1
    var isOnwerLoading = false
    
    let currentRefreshControl = UIRefreshControl()
    
    init() {
    }
    func getMyOrderSelected() -> MyOrderMenuOtion? {
        if let options = try? menuOptions.value(), let selection = options.first(where: { $0.isSelected == true }) {
            return selection
        }
        return nil
    }
    
    func updateSelection(selection: MyOrderSelection) {
        if var options = try? menuOptions.value() {
            options.enumerated().forEach { element in
                options[element.offset].isSelected = element.element.type == selection
            }
            self.menuOptions.onNext(options)
        }
    }
    
    func getActiveSessions() -> [ActiveSession] {
        do {
            return try activeSessions.value()
        } catch {
            return [ActiveSession]()
        }
    }
    
    func getCompletedSessions() -> [ActiveSession] {
        do {
            return try pastSession.value()
        } catch {
            return [ActiveSession]()
        }
    }
    
    func callGetActiveSession() {
        NetworkManager().activeSession { _, _, activeSessions in
            self.activeSessions.onNext(activeSessions)
        }
    }
    
    func webserviceCallForPastOrder(isReload: Bool) {
        if isReload {
            self.pagePast = 1
            CommonUtils.showProgressHud()
        }
        self.isLoading = true
        NetworkManager().completedSession(page: pagePast) { _, _, activeSession in
            CommonUtils.hideProgressHud()
            if var existedOrders = try? self.pastSession.value() {
                if self.pagePast == 1 {
                    self.pastSession.onNext(activeSession)
                } else {
                    if activeSession.count > 0 {
                        existedOrders.append(contentsOf: activeSession)
                    }
                    self.pastSession.onNext(existedOrders)
                }
            }
            if activeSession.count > 0 {
                self.pagePast += self.pagePast
                self.isLoading = false
            }
            if isReload && activeSession.count == 0 {
                self.isLoading = false
            }
        }
    }
    
    func stopCharging(id: String, orderId: Int) {
        CommonUtils.showProgressHud()
        NetworkManager().stopTransaction(id: id, orderId: orderId) { success, message, _ in
            CommonUtils.hideProgressHud()
            if success == 1 {
                self.callGetActiveSession()
            } else {
                self.errorMessage.send(message)
            }
        }
    }
}
