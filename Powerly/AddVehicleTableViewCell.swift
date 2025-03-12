//
//  AddVehicleTableViewCell.swift
//  PowerShare
//
//  Created by ADMIN on 19/05/23.
//  
//

import UIKit

class AddVehicleTableViewCell: UITableViewCell {
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    var model: AddVehicle?
    var images = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        if isLanguageArabic {
            titleLabel.textAlignment = .right
            descriptionLabel.textAlignment = .right
            outView.semanticContentAttribute = .forceRightToLeft
        }
    }

    func setUpItem(item: VehicleDetail) {
        var filled = false
        titleLabel.text = "* " + item.title
        descriptionLabel.text = ""
        imageCollectionView.isHidden = true
        imageCollectionView.delegate = nil
        imageCollectionView.dataSource = nil
        switch item.type {
        case .manufacturer:
            if let manufecturer = model?.manufacturer {
                filled = true
                descriptionLabel.text = manufecturer.name
            }
        
        case .model:
            if let model = model?.model {
                filled = true
                descriptionLabel.text = model.name
            }
        
        case .details:
            if let version = model?.color {
                filled = true
                descriptionLabel.text = version
            }
        }
        checkMarkImageView.tintColor = filled ? UIColor(named: "008CE9"):UIColor(named: "E8E8E8")
    }
}

extension AddVehicleTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.className, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let image = self.images.value(at: indexPath.item) {
            cell.imageView.image = UIImage(named: image)
        }
        return cell
    }
}
