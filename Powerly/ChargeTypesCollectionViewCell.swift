//
//  ChargeTypesCollectionViewCell.swift
//  PowerShare
//
//  Created by ADMIN on 10/07/23.
//  
//

import UIKit

class ChargeTypesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var connectorTitleLabel: UILabel!
    @IBOutlet weak var connectorImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var availibilityView: UIView?
    @IBOutlet weak var availabilityLabel: UILabel?
    @IBOutlet weak var numberLabel: UILabel?
    
    @IBOutlet weak var outView: UIView?
    
    func setupConnector(connector: Connector) {
        connectorTitleLabel.font = .robotoRegular(ofSize: 12)
        priceLabel.font = .robotoRegular(ofSize: 11)
        availabilityLabel?.font = .robotoRegular(ofSize: 12)
        numberLabel?.font = .robotoRegular(ofSize: 12)
        
        connectorTitleLabel.text = connector.name
        connectorImageView.sd_setImage(with: URL(string: connector.icon ?? ""), placeholderImage: UIImage(named: "genaral_placeholder"))
        priceLabel.text = String(format: "%@ %ld %@", NSLocalizedString("max", comment: ""), connector.maxPower, NSLocalizedString("kwh", comment: ""))
        
        if let status = connector.status {
            availibilityView?.isHidden = false
            availabilityLabel?.text = NSLocalizedString(status, comment: status)
            if status == "available" {
                availabilityLabel?.textColor = UIColor(named: "008CE9")
                availibilityView?.backgroundColor = UIColor(named: "F3F3F3")
            } else if status == "busy" {
                availabilityLabel?.textColor = UIColor(named: "E6352B")
                availibilityView?.backgroundColor = UIColor(named: "F3F3F3")
            } else {
                availabilityLabel?.textColor = UIColor.white
                availibilityView?.backgroundColor = UIColor(named: "E6352B")
            }
        } else {
            availibilityView?.isHidden = true
        }
    }
}
