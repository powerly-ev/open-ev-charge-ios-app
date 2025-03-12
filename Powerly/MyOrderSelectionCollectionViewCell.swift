//
//  MyOrderSelectionCollectionViewCell.swift
//  PowerShare
//
//  Created by admin on 25/04/23.
//  
//

import UIKit

class MyOrderSelectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var saperatorView: UIView!
    
    
    func setUpData(selection: MyOrderMenuOtion) {
        if selection.isSelected {
            saperatorView.isHidden = false
            selectionLabel.textColor = UIColor(named: "008CE9")
        } else {
            saperatorView.isHidden = true
            selectionLabel.textColor = UIColor(named: "222222")
        }
        selectionLabel.font = .robotoMedium(ofSize: 16)
        selectionLabel.text = selection.text
    }
    
    func setUpData(selection: MyMenuOtion) {
        selectionLabel.text = selection.text
        selectionLabel.font = .robotoMedium(ofSize: 16)
        if selection.isSelected {
            selectionLabel.textColor = UIColor(named: "008CE9")
        } else {
            selectionLabel.textColor = UIColor(named: "222222")
        }
    }
}
