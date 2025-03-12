//
//  FeedbackListCollectionViewCell.swift
//  PowerShare
//
//  Created by admin on 08/01/22.
//  
//

import UIKit

class FeedbackListCollectionViewCell: UICollectionViewCell {
    @IBOutlet var feedbackView: UIView!
    @IBOutlet var feedbackLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        feedbackLabel.font = .robotoMedium(ofSize: 16)
    }
}
