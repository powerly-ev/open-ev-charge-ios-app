//
//  VisitedTableViewCell.swift
//  PowerShare
//
//  Created by ADMIN on 15/07/23.
//  
//
import CoreLocation
import UIKit

class VisitedTableViewCell: UITableViewCell {
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var connectorImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.outView.addLightDropshadowtoVIEW()
        priceLabel.font = .robotoRegular(ofSize: 16)
        nameLabel.font = .robotoRegular(ofSize: 16)
    }

    func setUpPowerSource(powerSource: ChargePoint) {
        nameLabel.text = powerSource.title
        connectorImageView.sd_setImage(with: URL(string: powerSource.connectors.first?.icon ?? ""), placeholderImage: UIImage(named: "genaral_placeholder"))
        checkMarkImageView.isHidden = powerSource.isExternal
        if let location = LocationManager.shared.location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let sourceLocation = CLLocation(latitude: latitude, longitude: longitude)
            if let powerLatitude = Double(powerSource.latitude), let powerLongitude = Double(powerSource.longitude) {
                let destinationLocation = CLLocation(latitude: powerLatitude, longitude: powerLongitude)
                let kms = CommonUtils.distanceBetweenTwoLocations(source: sourceLocation, destination: destinationLocation)
                if powerSource.isNearest {
                    priceLabel.textColor = UIColor(named: "008CE9")
                    priceLabel.font = .robotoMedium(ofSize: 14)
                } else {
                    priceLabel.textColor = UIColor(named: "222222")
                    priceLabel.font = .robotoMedium(ofSize: 14)
                }
                priceLabel.text = powerSource.isNearest ? NSLocalizedString("nearest",comment: ""):String(format: "%.1f %@", kms, CommonUtils.getStringFromXML(name: "km_title"))
            }
        }
    }
}
