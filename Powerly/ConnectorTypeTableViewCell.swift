//
//  ChargeTypeTableViewCell.swift
//  PowerShare
//
//  Created by admin on 10/05/23.
//  
//

import UIKit

class ConnectorTypeTableViewCell: UITableViewCell {
    
    @IBOutlet var connectorCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    @IBOutlet weak var removeStationButton: UIButton!
    var connectors = [Connector]()
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .robotoBold(ofSize: 20)
        typeLabel.font = .robotoRegular(ofSize: 14)
        maxLabel.font = .robotoRegular(ofSize: 14)
        removeStationButton.titleLabel?.font = .robotoMedium(ofSize: 16)
    }

    func setUpData(plugTypes: [Connector], type: ChargerType) {
        connectors = plugTypes
        self.connectorCollectionView.delegate = self
        self.connectorCollectionView.dataSource = self
        self.connectorCollectionView.reloadData()
        
        titleLabel.text = type.name
        typeLabel.text = type.currentType
        maxLabel.text = type.maxPower.description + " " + NSLocalizedString("kwh", comment: "")
    }
}

extension ConnectorTypeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.connectors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.className, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let connector = self.connectors.value(at: indexPath.item) {
            cell.imageView.sd_setImage(with: URL(string: connector.icon ?? ""), placeholderImage: UIImage(named: "genaral_placeholder"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let totalCellWidth = 24 * self.connectors.count
        let totalSpacingWidth = 10 * (self.connectors.count - 1)

        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}

class ConnectorCollectionView: UICollectionViewCell {
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var plugNumber: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typeLabel.font = .robotoRegular(ofSize: 12)
        plugNumber?.font = .robotoRegular(ofSize: 11)
    }
    
    func setUpData(connector: Connector, selected: Bool) {
        typeImageView.sd_setImage(with: URL(string: connector.icon ?? ""), placeholderImage: UIImage(named: "genaral_placeholder"))
        typeLabel.text = connector.name
        typeView.backgroundColor = UIColor(named: selected ? "EBF7FF":"WHITE")
        typeView.setBorderColor(color: UIColor(named: selected ? "008CE9":"E8E8E8"))
    }
    
    func setUpData(connector: Amenity, selected: Bool) {
        typeImageView.sd_setImage(with: URL(string: connector.icon ?? ""), placeholderImage: UIImage(named: "park"))
        typeLabel.text = connector.name
        typeView.backgroundColor = UIColor(named: selected ? "EBF7FF":"WHITE")
        typeView.setBorderColor(color: UIColor(named: selected ? "008CE9":"E8E8E8"))
    }
    
    func setUpData(type: ChargerType, selected: Bool) {
        typeImageView.sd_setImage(with: URL(string: type.img ?? ""), placeholderImage: UIImage(named: "park"))
        typeLabel.text = type.name
        typeView.backgroundColor = UIColor(named: selected ? "EBF7FF":"WHITE")
        typeView.setBorderColor(color: UIColor(named: selected ? "008CE9":"E8E8E8"))
    }
}
