//
//  SideMenuTableViewCell.swift
//  PowerShare
//
//  Created by admin on 11/01/22.
//  
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var imgLedding: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgTailing: UIImageView!
    @IBOutlet var badgeStackView: UIStackView!
    @IBOutlet var badgeTitleView: UIView!
    @IBOutlet var badgeLabel: UILabel!
    
    override func awakeFromNib() {
        lblTitle.font = .robotoMedium(ofSize: 14)
        badgeLabel.font = .robotoRegular(ofSize: 12)
    }

}
