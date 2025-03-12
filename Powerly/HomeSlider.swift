//
//  HomeSlider.swift
//  Powerly
//
//  Created by ADMIN on 17/01/24.
//  
//

import Foundation

enum SliderType {
    case club
    case refer
    case buyEV
}

struct HomeSlider {
    let type: SliderType
    let title: String
    let description: String
    let image: String
    let buttonName: String
}
