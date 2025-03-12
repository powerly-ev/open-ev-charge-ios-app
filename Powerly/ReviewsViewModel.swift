//
//  ReviewsModel.swift
//  PowerShare
//
//  Created by ADMIN on 27/07/23.
//  
//

import Foundation
import RxSwift

struct ReviewsViewModel {
    var reviewList = PublishSubject<[RatingReview]>()
    
    func getReviewRatingList(chargeId: String) {
        NetworkManager().powerSourceReviews(chargeId: chargeId) { _, _, reviewList in
            self.reviewList.onNext(reviewList)
        }
    }
}
