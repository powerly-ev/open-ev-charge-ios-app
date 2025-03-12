//
//  SlotDayCollectionViewCell.swift
//  PowerShare
//
//  Created by admin on 16/02/22.
//  
//

import UIKit

class SlotDayCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayLabel.font = .robotoRegular(ofSize: 14)
        // Initialization code
    }

}
