//
//  WalletViewModel.swift
//  Powerly
//
//  Created by ADMIN on 08/07/24.
//  
//

import Foundation
import RxSwift

struct WalletViewModel {
    var wallets = BehaviorSubject<[Wallet]>(value: [Wallet]())
    
    func getWallets() async {
        if let response = try? await NetworkManager().getWallets(), let data = response.data {
            self.wallets.onNext(data)
        }
    }
    
    func requestPayout() async -> Response? {
        CommonUtils.showProgressHud()
        let response = try? await NetworkManager().reqeustPayout()
        CommonUtils.hideProgressHud()
        return response
    }
}
