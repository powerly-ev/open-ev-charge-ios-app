//
//  MyVehicleTableViewCell.swift
//  PowerShare
//
//  Created by ADMIN on 07/08/23.
//  
//

import UIKit

class MyVehicleTableViewCell: UITableViewCell {
    @IBOutlet var titleView: UIView!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet weak var plugImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet var gasView: UIView!
    @IBOutlet var productView: UIView!
    @IBOutlet var plugTypeTitle: UILabel!
    @IBOutlet var plugTypeLabel: UILabel!
    @IBOutlet var lastUpdateView: UIView!
  
    // Make
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var makeValueLabel: UILabel!
    @IBOutlet weak var plateNumber: UILabel!
    
    // Model
    @IBOutlet weak var carView: UIView!
    @IBOutlet weak var carIcon: UIImageView!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var modelValueLabel: UILabel!
    
    // version
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionValueLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .robotoMedium(ofSize: 16)
        makeLabel.font = .robotoMedium(ofSize: 14)
        makeValueLabel.font = .robotoMedium(ofSize: 14)
        plateNumber.font = .robotoBold(ofSize: 16)
        modelLabel.font = .robotoMedium(ofSize: 14)
        modelValueLabel.font = .robotoMedium(ofSize: 14)
        plugTypeTitle.font = .robotoMedium(ofSize: 14)
        plugTypeLabel.font = .robotoMedium(ofSize: 14)
        versionLabel.font = .robotoMedium(ofSize: 14)
        versionValueLabel.font = .robotoMedium(ofSize: 14)
    }
    
    func setupCell(vehicle: Vehicle) {
        titleLabel.text = vehicle.title
        makeValueLabel.text = vehicle.make.name
        modelValueLabel.text = vehicle.model.name
        plugTypeLabel.text = vehicle.chargingConnector?.name ?? ""
        versionValueLabel.text = vehicle.fuelType
        if let color = CommonUtils.allCarColors().first(where: { $0.name == vehicle.color }) {
            carIcon.tintColor = UIColor(hex: color.hex)
            carView.backgroundColor = color.isLight ? .black:.clear
        }
    }
}
