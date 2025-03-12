//
//  MyPowerSourceModel.swift
//  PowerShare
//
//  Created by admin on 06/05/23.
//  
//
import Foundation

enum MyEvSelection: Int {
    case ev = 0
    case station = 1
    case item = 2
}

struct MyMenuOtion {
    let type: MyEvSelection
    let text: String
    var isSelected: Bool
    let image: UIImage?
}
