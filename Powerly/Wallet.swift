//
//  Wallet.swift
//  Powerly
//
//  Created by ADMIN on 08/07/24.
//  
//

import Foundation

struct Wallet: Codable {
    let rechargeable: Bool
    let payable: Bool
    let id: Int
    let withdrawable: Bool
    let type: String
    let name: String
    let balance: String
}
