//
//  StoreAnnotation.swift
//  GasBottle
//
//  Created by admin on 30/04/23.
//  
//

import UIKit
import CoreLocation

class StoreAnnotation: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var verificationBadgeImageView: UIImageView!
    @IBOutlet weak var maxView: UIView!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    
    func setUpStore(powerSource: ChargePoint) {
        self.nameLabel.font = .robotoMedium(ofSize: 15)
        distanceLabel.font = .robotoRegular(ofSize: 12)
        maxLabel.font = .robotoRegular(ofSize: 12)
        typeLabel.font = .robotoRegular(ofSize: 12)
        ratingLabel.font = .robotoRegular(ofSize: 14)
        self.ratingLabel.text = String(format: "%.1f", powerSource.rating)
        self.nameLabel.text = powerSource.title
        self.verificationBadgeImageView.isHidden = powerSource.isExternal
        if let location = LocationManager.shared.location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let sourceLocation = CLLocation(latitude: latitude, longitude: longitude)
            if let powerLatitude = Double(powerSource.latitude), let powerLongitude = Double(powerSource.longitude) {
                let storeLatitude = powerLatitude
                let storeLongitude = powerLongitude
                let destinationLocation = CLLocation(latitude: storeLatitude, longitude: storeLongitude)
                let kms = CommonUtils.distanceBetweenTwoLocations(source: sourceLocation, destination: destinationLocation)
                distanceLabel.text = String(format: "%.1f %@", kms,CommonUtils.getStringFromXML(name: "km_title"))
            }
        }
        
        if let connector = powerSource.connectors.first {
            maxView.isHidden = false
            typeView.isHidden = false
            self.maxLabel.text = connector.maxPower.description + " \(NSLocalizedString("kw", comment: ""))" + " \(NSLocalizedString("max", comment: ""))"
            self.typeLabel.text = connector.connectorCurrentType
        } else {
            maxView.isHidden = true
            typeView.isHidden = true
        }
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "StoreAnnotation", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView ?? UIView()
    }
}
