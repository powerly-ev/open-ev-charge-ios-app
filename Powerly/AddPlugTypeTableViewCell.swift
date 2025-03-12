//
//  AddPlugTypeTableViewCell.swift
//  PowerShare
//
//  Created by admin on 12/05/23.
//  
//

import UIKit

class AddPlugTypeTableViewCell: UITableViewCell {
    @IBOutlet weak var addPlugButtonView: UIView!
    @IBOutlet weak var addPlusLeftImageView: UIImageView!
    @IBOutlet weak var addPlugLabel: UILabel!
    @IBOutlet weak var addPlusRightImageView: UIImageView!
    @IBOutlet weak var addPlugButton: UIButton!
    
    @IBOutlet weak var connectorImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var maxPowerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .robotoBold(ofSize: 20)
        typeLabel.font = .robotoRegular(ofSize: 14)
        maxPowerLabel.font = .robotoRegular(ofSize: 14)
        addPlugLabel.font = .robotoMedium(ofSize: 16)
    }

    func setUpData(connector: Connector, selected: Bool) {
        connectorImageView.sd_setImage(with: URL(string: connector.icon ?? ""), placeholderImage: UIImage(named: "genaral_placeholder"))
        nameLabel.text = connector.name
        typeLabel.text = connector.type
        maxPowerLabel.text = connector.maxPower.description + " " + NSLocalizedString("kw", comment: "")
        if selected == true {
            addPlugButtonView.backgroundColor = UIColor(named: "F3F3F3")
            addPlusLeftImageView.image = UIImage(named: "checkmark_blue")
            addPlusLeftImageView.tintColor = UIColor(named: "AAAAAA")
            addPlugLabel.textColor = UIColor(named: "AAAAAA")
            addPlugLabel.text = NSLocalizedString("added_to_stations", comment: "")
        } else {
            addPlugButtonView.backgroundColor = UIColor(named: "222222")
            addPlusLeftImageView.image = UIImage(named: "plus_white_icon")
            addPlusLeftImageView.tintColor = .white
            addPlugLabel.textColor = UIColor.white
            addPlugLabel.text = NSLocalizedString("add_plug", comment: "")
        }
    }
}
