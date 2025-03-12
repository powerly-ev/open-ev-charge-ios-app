//
//  MyOrderTableViewCell.swift
//  PowerShare
//
//  Created by admin on 12/01/22.
//  
//

import UIKit

class MyOrderTableViewCell: UITableViewCell {
    @IBOutlet weak var lblItems: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var shadowBackgroundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblItems.font = .robotoMedium(ofSize: 14)
        
      
    }



}
