//
//  UserManager.swift
//  PowerShare
//
//  Created by admin on 11/12/21.

//

import Foundation
import RxSwift
import SwiftyJSON

class UserManager {
    static let shared = UserManager()
    
    init() {}
    var country: Country?
    var countryList = [Country]()
    var currencyList = BehaviorSubject<[Currency]>(value: [Currency]())
    var user: User?
    var lastClosedRecurringOrderId: String?
    var callReviewOrder = true
    var reviewOrdersList = PublishSubject<[ActiveSession]>()
    
    func saveUserToDefault(userCurrent: User) {
        user = userCurrent
    }
    
    func clearObjectToLocal() {
        country = nil
        countryList = [Country]()
        user = nil
        callReviewOrder = true
        reviewOrdersList.onNext([ActiveSession]())
    }
    
    func setDefaultMethodToApplePay() {
    }
    
    func fetchCurrencyList() {
        CommonUtils.showProgressHud()
        NetworkManager().currencyList { _, _, currencies in
            CommonUtils.hideProgressHud()
            self.currencyList.onNext(currencies)
        }
    }
    
    class func webserviceCallForUserDetails() async throws -> Bool {
        if let response = try? await NetworkManager().userDetails() {
            if response.success == 1 {
                if let userDetail = response.data {
                    if userDetail.currency != "" {
                        userDefault.set(userDetail.currency, forKey: UserDefaultKey.kUserDefaultCurrency.rawValue)
                        userDefault.synchronize()
                    }
                    if userDetail.totalBalance != "" {
                        CommonUtils.setCurrentUserBalance(userDetail.totalBalance)
                    }
                    UserManager.shared.saveUserToDefault(userCurrent: userDetail)
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
