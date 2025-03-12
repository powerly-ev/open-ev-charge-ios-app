//
//  NearByCollectionViewCell.swift
//  Powerly
//
//  Created by ADMIN on 02/11/23.
//  
//
import CoreLocation
import UIKit

class NearByCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var checkmarkIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var tags = [Tag]()
    
    override func awakeFromNib() {
        titleLabel.font = .robotoMedium(ofSize: 16)
        let layout = UICollectionViewLeftAlignedLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.collectionViewLayout = layout
    }
    
    func setup(cp: ChargePoint) {
        titleLabel.text = cp.title
        let available = CommonUtils.getCorrectStatus(chargePoint: cp)
        checkmarkIcon.isHidden = cp.isExternal
        tags = [Tag]()
        if available.statusText != "" && !cp.isExternal {
            checkmarkIcon.image = available.statusImage
            checkmarkIcon.tintColor = available.primaryColor
            tags.append(Tag(icon: available.iconImage, tintColor: UIColor(named: "DE2929"), title: available.statusText))
        } else {
            checkmarkIcon.image = UIImage(systemName: "checkmark.circle.fill")
            checkmarkIcon.tintColor = UIColor(named: "008CE9")
        }
        if let location = LocationManager.shared.location,
           let powerLatitude = Double(cp.latitude),
           let powerLongitude = Double(cp.longitude) {
            
            let sourceLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let destinationLocation = CLLocation(latitude: powerLatitude, longitude: powerLongitude)
            let kms = CommonUtils.distanceBetweenTwoLocations(source: sourceLocation, destination: destinationLocation)
            tags.append(Tag(icon: nil, tintColor: nil, title: String(format: "%.1f %@", kms, CommonUtils.getStringFromXML(name: "km_title"))))
        }
        tags.append(Tag(icon: UIImage(systemName: "star.fill"), tintColor: UIColor(named: "008CE9"), title: cp.rating == 0 ? CommonUtils.getStringFromXML(name: "new_title"):String(format: "%.1f", cp.rating)))
        if let maxConnector = cp.connectors.max(by: { $0.maxPower < $1.maxPower }) {
            tags.append(Tag(icon: nil, tintColor: nil, title: String(format: "%ld %@", maxConnector.maxPower, NSLocalizedString("kwh", comment: ""))))
            if let connectType = maxConnector.type, !connectType.isEmpty {
                tags.append(Tag(icon: nil, tintColor: nil, title: connectType))
            }
            tags.append(Tag(icon: nil, tintColor: nil, title: maxConnector.name))
        }
        cp.amenities.forEach { amenity in
            tags.append(Tag(icon: nil, tintColor: UIColor(named: "222222"), title: amenity.name))
        }
        collectionView.reloadData()
    }
}

extension NearByCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.className, for: indexPath) as? TagCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let tag = tags.value(at: indexPath.item) {
            cell.iconImageView.isHidden = tag.icon == nil
            cell.iconImageView.image = tag.icon
            cell.iconImageView.tintColor = tag.tintColor
            cell.titleLabel.text = tag.title
            if let tintColor = tag.tintColor {
                cell.titleLabel.textColor = tintColor
            } else {
                cell.titleLabel.textColor = UIColor(named: "222222")
            }
        }
        return cell
    }
}

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

struct Tag {
    let icon: UIImage?
    let tintColor: UIColor?
    let title: String
}
