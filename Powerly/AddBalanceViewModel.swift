//
//  AddBalanceViewModel.swift
//  PowerShare
//
//  Created by admin on 28/02/23.
//  
//

import Foundation
import RxSwift
import SwiftyJSON

class AddBalanceViewModel {
    var cards = BehaviorSubject<[Card]?>(value: nil)
    var defaultCard: Card?
    var isShowAddCardView = true
    
    func retrieveCards() {
        NetworkManager().getCards { success, _, cards in
            if success == 1 {
                self.cards.onNext(cards)
            }
        }
    }
}
