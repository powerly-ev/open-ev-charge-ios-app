//
//  SelectTimeCollectionViewCell.swift
//  PowerShare
//
//  Created by ADMIN on 07/07/23.
//  
//

import UIKit

class SelectTimeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var slotImageView: UIImageView!
    @IBOutlet weak var slotNameLabel: UILabel!
    @IBOutlet weak var slotBackgroundView: UIView!
    
    func setupTime(selectTime: SelectTime, index: Int, indexPath: IndexPath) {
        slotImageView.image = selectTime.isFull ? UIImage(named: "express_service_icon"):UIImage(systemName: "clock")
        if selectTime.isFull {
            slotNameLabel.text = NSLocalizedString("FULL", comment: "")
        } else {
            slotNameLabel.text = selectTime.time.convertToMinHourFormat()
        }
        if index == indexPath.item {
            slotBackgroundView.backgroundColor = UIColor(named: "D4EEFF")
            slotNameLabel.font = .robotoMedium(ofSize: 14)
        } else {
            slotBackgroundView.backgroundColor = .white
            slotNameLabel.font = .robotoRegular(ofSize: 14)
        }
    }
}
