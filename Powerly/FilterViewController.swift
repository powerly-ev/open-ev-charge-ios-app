//
//  FilterViewController.swift
//  Powerly
//
//  Created by ADMIN on 23/11/23.
//  
//
import RxSwift
import UIKit

class FilterViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var chargingConnectorLabel: UILabel!
    @IBOutlet weak var vehicleTitleLabel: UILabel!
    @IBOutlet weak var vehicleNameLabel: UILabel!
    @IBOutlet weak var addVehicleButton: UIButton!
    @IBOutlet weak var chargingTypeDescriptionLabel: UILabel!
    @IBOutlet weak var hightAmenityView: NSLayoutConstraint!
    @IBOutlet weak var hightConnectorView: NSLayoutConstraint!
    @IBOutlet weak var connectorCollectionView: UICollectionView!
    @IBOutlet weak var amenityTitleLabel: UILabel!
    @IBOutlet weak var amenitiesCollectionView: UICollectionView!
    @IBOutlet weak var stationCountTitleLabel: UILabel!
    @IBOutlet weak var stationCollectionView: UICollectionView!
    @IBOutlet weak var availibilityTitleLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var acView: UIView!
    @IBOutlet weak var acLabel: UILabel!
    @IBOutlet weak var acButton: UIButton!
    @IBOutlet weak var dcView: UIView!
    @IBOutlet weak var dcLabel: UILabel!
    @IBOutlet weak var dcButton: UIButton!
    @IBOutlet weak var kwRangeTitleLabel: UILabel!
    @IBOutlet weak var killoWattRangeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var killoWattRangeSlider: RangeSeekSlider!
    @IBOutlet weak var distanceTitleLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var operatorsTitleLabel: UILabel!
    @IBOutlet weak var selectedOperatorLabel: UILabel!
    @IBOutlet weak var seeStationButton: SpinnerButton!
    
    var viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        bindView()
    }
    
    func initUI() {
        let layout = UICollectionViewLeftAlignedLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 10
        amenitiesCollectionView.collectionViewLayout = layout
        // connectorCollectionView.collectionViewLayout = layout
        killoWattRangeSlider.delegate = self
        killoWattRangeLabel.text = String(format: "%.f - %.f+", killoWattRangeSlider.selectedMinValue, killoWattRangeSlider.selectedMaxValue)
        distanceLabel.text = String(format: "%.f", distanceSlider.value)
    }
    
    func initFont() {
        headerLabel.font = .robotoBold(ofSize: 18)
        resetButton.titleLabel?.font = .robotoBold(ofSize: 18)
        chargingConnectorLabel.font = .robotoBold(ofSize: 16)
        acLabel.font = .robotoMedium(ofSize: 14)
        dcLabel.font = .robotoMedium(ofSize: 14)
        vehicleTitleLabel.font = .robotoRegular(ofSize: 14)
        vehicleNameLabel.font = .robotoMedium(ofSize: 14)
        addVehicleButton.titleLabel?.font = .robotoMedium(ofSize: 14)
        chargingTypeDescriptionLabel.font = .robotoRegular(ofSize: 14)
        amenityTitleLabel.font = .robotoBold(ofSize: 16)
        stationCountTitleLabel.font = .robotoBold(ofSize: 16)
        availibilityTitleLabel.font = .robotoBold(ofSize: 16)
        openLabel.font = .robotoMedium(ofSize: 16)
        kwRangeTitleLabel.font = .robotoBold(ofSize: 16)
        distanceTitleLabel.font = .robotoBold(ofSize: 16)
        operatorsTitleLabel.font = .robotoBold(ofSize: 16)
        killoWattRangeLabel.font = .robotoMedium(ofSize: 16)
        distanceLabel.font = .robotoMedium(ofSize: 16)
        selectedOperatorLabel.font = .robotoRegular(ofSize: 16)
        seeStationButton.titleLabel?.font = .robotoMedium(ofSize: 16)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.hightConnectorView.constant = self.connectorCollectionView.contentSize.height
        self.hightAmenityView.constant = self.amenitiesCollectionView.contentSize.height
    }

    func bindView() {
        self.viewModel.connectors.asObservable().subscribe { _ in
            self.connectorCollectionView.reloadData()
        }.disposed(by: disposeBag)
        
        self.viewModel.amenities.asObservable().subscribe { _ in
            self.amenitiesCollectionView.reloadData()
        }.disposed(by: disposeBag)
    }

    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnResetButton(_ sender: Any) {
    }
    
    @IBAction func didTapOnACButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        acView.backgroundColor = UIColor(named: sender.isSelected ? "EBF7FF":"WHITE")
        acView.setBorderColor(color: UIColor(named: sender.isSelected ? "008CE9":"E8E8E8"))
    }
    
    @IBAction func didTapOnDBButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        dcView.backgroundColor = UIColor(named: sender.isSelected ? "EBF7FF":"WHITE")
        dcView.setBorderColor(color: UIColor(named: sender.isSelected ? "008CE9":"E8E8E8"))
    }
    
    @IBAction func didTapOnAddVehicleButton(_ sender: Any) {
        guard let myEVVC = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: MyVehicleViewController.className) as? MyVehicleViewController else {
            return
        }
        myEVVC.completionSelection = { vehicle in
            self.vehicleNameLabel.text = vehicle.title
            self.vehicleTitleLabel.font = .robotoRegular(ofSize: 12)
            self.vehicleNameLabel.isHidden = false
            self.vehicleTitleLabel.text = "Vehicle"
        }
        myEVVC.fromFilter = true
        myEVVC.modalPresentationStyle = .fullScreen
        let navEV = CommonUtils.navigationToController()
        navEV.setViewControllers([myEVVC], animated: true)
        self.present(navEV, animated: true, completion: nil)
    }
    
    @IBAction func killoWattRangeChanged(_ sender: RangeSeekSlider) {
    }
    
    @IBAction func changeDistanceSlider(_ sender: UISlider) {
        distanceLabel.text = String(format: "%.f", sender.value)
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case connectorCollectionView:
        return viewModel.getConnectors().count
        
        case amenitiesCollectionView:
        return viewModel.getAmenities().count
        
        case stationCollectionView:
        return viewModel.stations.count
        
        default:
        return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
            case connectorCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConnectorCollectionView.className, for: indexPath) as? ConnectorCollectionView else {
                return UICollectionViewCell()
            }
            let type = self.viewModel.getConnectors()[indexPath.item]
            cell.setUpData(connector: type, selected: self.viewModel.selectedConnectorFilter.contains(where: {$0.id == type.id}))
            return cell
            
            case amenitiesCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConnectorCollectionView.className, for: indexPath) as? ConnectorCollectionView else {
                return UICollectionViewCell()
            }
            let type = self.viewModel.getAmenities()[indexPath.item]
            cell.setUpData(connector: type, selected: self.viewModel.selectedAmenityFilter.contains(where: {$0.id == type.id}))
            return cell
            
            case stationCollectionView:
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "stationsCountCell", for: indexPath)
            if let name = viewModel.stations.value(at: indexPath.item),
               let nameLabel = cell.viewWithTag(1) as? UILabel,
               let outView = cell.viewWithTag(2)  {
                nameLabel.font = .robotoMedium(ofSize: 14)
                nameLabel.text = name
                outView.backgroundColor = UIColor(named: self.viewModel.selectedStationCountFilter == name ? "F3F3F3": "WHITE")
            }
            return cell
            
            default:
                return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
            case connectorCollectionView:
                let type = self.viewModel.getConnectors()[indexPath.item]
                if self.viewModel.selectedConnectorFilter.contains(where: {$0.id == type.id}) {
                    self.viewModel.selectedConnectorFilter.removeAll(where: {$0.id == type.id})
                } else {
                    self.viewModel.selectedConnectorFilter.append(type)
                }
                self.connectorCollectionView.reloadData()
                
            case amenitiesCollectionView:
                let type = self.viewModel.getAmenities()[indexPath.item]
                if self.viewModel.selectedAmenityFilter.contains(where: {$0.id == type.id}) {
                    self.viewModel.selectedAmenityFilter.removeAll(where: {$0.id == type.id})
                } else {
                    self.viewModel.selectedAmenityFilter.append(type)
                }
                self.amenitiesCollectionView.reloadData()
            
            case stationCollectionView:
                self.viewModel.selectedStationCountFilter = self.viewModel.stations[indexPath.item]
                self.stationCollectionView.reloadData()
            
            default:
              break
            
        }
        
    }
}

extension FilterViewController: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        killoWattRangeLabel.text = String(format: "%.f - %.f+", minValue, maxValue)
    }
}

