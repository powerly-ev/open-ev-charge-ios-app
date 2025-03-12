//
//  FeedbackViewModel.swift
//  PowerShare
//
//  Created by ADMIN on 26/07/23.
//  
//

import Foundation
import SwiftyJSON
import RxSwift

class FeedbackViewModel {
    var orderID: Int?
    var session = BehaviorSubject<ActiveSession?>(value: nil)
    var selectedInexpath: Int = -1
    var feedbackArray = BehaviorSubject<[String: [String]]>(value: [:])
    
    init(session: ActiveSession?) {
        self.session.onNext(session)
    }
    
    func getFeedbackMessage() {
        Task {
            if let json = try? await NetworkManager().getStaticReviewMessage() {
                if json.success == 1, let data = json.data {
                    self.feedbackArray.onNext(data)
                }
            }
        }
    }
    
    func getFeedBackArray(rating: Int) -> [String] {
        if let feedbackArray = try? self.feedbackArray.value(), let reviewList = feedbackArray[rating.description] {
            return reviewList
        }
        return []
    }
    
    func getSessionDetailBy(orderId: Int) {
        NetworkManager().getSessionByOrderId(orderId: orderId) { success, message, session in
            if let session = session {
                self.session.onNext(session)
            }
        }
    }
    
    func skipFeedbackAPI(orderId: Int, viewController: UIViewController) {
        CommonUtils.showProgressHud()
        NetworkManager().addPowerSourceSkipReview(orderId: orderId) { success, message, json in
            CommonUtils.hideProgressHud()
            viewController.dismiss(animated: true)
        }
    }
}
