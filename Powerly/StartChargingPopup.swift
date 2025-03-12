//
//  StartChargingPopup.swift
//  PowerShare
//
//  Created by ADMIN on 16/08/23.
//  
//
import CoreLocation
import UIKit

class StartChargingPopup: UIViewController {
    @IBOutlet weak var selectTimeCollectionView: UICollectionView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceStackView: UIStackView!
    
    @IBOutlet weak var connectorView: UIView!
    @IBOutlet weak var connectorCollectionView: UICollectionView!
    @IBOutlet weak var startChargingLabel: UILabel!
   
    var viewModel: ChargePointDetailViewModel!
    var completionStartCharging: ((ChargePointDetailViewModel) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
    }
    
    func initUI() {
        headerLabel.font = .robotoBold(ofSize: 18)
        descriptionLabel.font = .robotoRegular(ofSize: 18)
        startChargingLabel.font = .robotoMedium(ofSize: 16)
        if isLanguageArabic {
            descriptionLabel.textAlignment = .right
            priceLabel.textAlignment = .right
            priceStackView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func initData() {
        guard let chargePoint = self.viewModel.getPowerSource() else {
            return
        }
        connectorView.isHidden = chargePoint.connectors.count < 2
        self.displayPrice(data: chargePoint)
        if let location = LocationManager.shared.location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let sourceLocation = CLLocation(latitude: latitude, longitude: longitude)
            if let powerLatitude = Double(chargePoint.latitude), let powerLongitude = Double(chargePoint.longitude) {
                let destinationLocation = CLLocation(latitude: powerLatitude, longitude: powerLongitude)
                let kms = CommonUtils.distanceBetweenTwoLocations(source: sourceLocation, destination: destinationLocation)
                if kms > 0.1 {
                    self.descriptionLabel.text = NSLocalizedString("start_charging_note_above_100", comment: "")
                } else {
                    self.descriptionLabel.text = NSLocalizedString("start_charging_note_below_100", comment: "")
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.animatetimeSlot()
    }
    
    func displayPrice(data: ChargePoint) {
        guard let time = self.viewModel.times.value(at: self.viewModel.selectedIndex) else {
            return
        }
        
        let attributed = NSMutableAttributedString()
        let priceText: String
        let unitText: String
        
        if !time.isFull && data.priceUnit == "minutes" {
            if isLanguageArabic {
                priceText = String(format: "%.2f %@", data.price * Float(time.time), CommonUtils.getCurrency())
            } else {
                priceText = String(format: "%@ %.2f", CommonUtils.getCurrency(), data.price * Float(time.time))
            }
            unitText = String(format: " %@ %d %@", NSLocalizedString("per", comment: ""), time.time, data.priceUnit.getPriceUnitNamePlural())
        } else {
            if isLanguageArabic {
                priceText = String(format: "%.2f %@", data.price, CommonUtils.getCurrency())
            } else {
                priceText = String(format: "%@ %.2f", CommonUtils.getCurrency(), data.price)
            }
            unitText = String(format: " %@ %@", NSLocalizedString("per", comment: ""), data.priceUnit.getPriceUnitName())
        }
        
        attributed.custom(priceText, font: .robotoRegular(ofSize: 16), color: UIColor(named: "008CE9") ?? .blue)
        attributed.custom(unitText, font: .robotoRegular(ofSize: 16), color: UIColor(named: "222222") ?? .blue)
        if let type = PriceUnit(rawValue: data.sessionLimitType), type == .energy, data.sessionLimitValue > 0 {
            attributed.custom(String(format: " (%.f %@)", data.sessionLimitValue, NSLocalizedString("max", comment: "")), font: .robotoRegular(ofSize: 16), color: UIColor(named: "222222") ?? .blue)
        }
        self.priceLabel.attributedText = attributed
    }
    
    func animatetimeSlot() {
        let itemCount = selectTimeCollectionView.numberOfItems(inSection: 0)
        self.selectTimeCollectionView.scrollToItem(at: IndexPath(item: itemCount-1, section: 0), at: .centeredHorizontally, animated: false)
        self.selectTimeCollectionView.setNeedsLayout()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.selectTimeCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            self.selectTimeCollectionView.setNeedsLayout()
        }
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnStartChargingButton(_ sender: Any) {
        guard let chargePoint = self.viewModel.getPowerSource() else {
            return
        }
        if chargePoint.category == PowerSourceCategory.evCharger.rawValue {
            if viewModel.selectedConnectors.isEmpty {
                TSMessage.showNotification(in: self, title: "", subtitle: NSLocalizedString("select_plug", comment: ""), type: .error)
                return
            }
        }
        self.dismiss(animated: true) {
            self.completionStartCharging?(self.viewModel)
        }
    }
}

extension StartChargingPopup: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case selectTimeCollectionView:
            return self.viewModel.times.count
            
        case connectorCollectionView:
            return self.viewModel.getPowerSource()?.connectors.count ?? 0
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case connectorCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChargeTypesCollectionViewCell.className, for: indexPath) as? ChargeTypesCollectionViewCell else {
                return UICollectionViewCell()
            }
            if let connector = self.viewModel.getPowerSource()?.connectors.value(at: indexPath.item) {
                cell.setupConnector(connector: connector)
                if let selectedConnector = self.viewModel.selectedConnectors.first(where: {$0.id == connector.id}) {
                    cell.numberLabel?.text = "Plug: \(selectedConnector.number ?? 0)"
                    cell.outView?.backgroundColor = UIColor(named: "D4EEFF")
                } else {
                    cell.numberLabel?.text = ""
                    cell.outView?.backgroundColor = .white
                }
            }
            return cell
            
        case selectTimeCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectTimeCollectionViewCell.className, for: indexPath) as? SelectTimeCollectionViewCell else {
                return UICollectionViewCell()
            }
            if let selectTime = self.viewModel.times.value(at: indexPath.item) {
                cell.setupTime(selectTime: selectTime, index: viewModel.selectedIndex, indexPath: indexPath)
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case selectTimeCollectionView:
            self.viewModel.selectedIndex = indexPath.item
            self.selectTimeCollectionView.reloadData()
            guard let powerSource = self.viewModel.getPowerSource() else {
                return
            }
            self.displayPrice(data: powerSource)
        case connectorCollectionView:
            if let connector = self.viewModel.getPowerSource()?.connectors.value(at: indexPath.item) {
                if connector.status == "available" {
                    handleSelection(for: connector)
                }
            }
            break
        default: break
        }
    }
    
    // Function to handle selection and unselection of connectors
    func handleSelection(for connector: Connector) {
        viewModel.selectedConnectors = [connector]
        // Check if the connector is already selected
//        if let index = viewModel.selectedConnectors.firstIndex(where: { $0.id == connector.id }) {
//            // If already selected, unselect it
//            viewModel.selectedConnectors.remove(at: index)
//            // Update the position of remaining selected connectors
//            /*updatePositions*/()
//        } else {
//            // If not selected, add it to the selectedConnectors
//
//            viewModel.selectedConnectors.append(connector)
//        }
        // Update the positions after selection/unselection
//        updatePositions()
        connectorCollectionView.reloadData()
    }
    
    // Function to update the position numbers based on the current selection order
    func updatePositions() {
        // Sort connectors by the order of selection (i.e., maintain the same order as they were selected)
        for (index, connector) in viewModel.selectedConnectors.enumerated() {
            viewModel.selectedConnectors[index].number = index + 1
        }
    }
}
