//
//  StoreMapViewController.swift
//  PowerShare
//
//  Created by admin on 01/03/23.
//  
//
import CoreLocation
import CoreTelephony
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import RxCocoa
import RxGoogleMaps
import RxSwift
import SwiftyJSON
import UIKit

class StoreMapViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var locationDescLabel: UILabel!
    @IBOutlet var mapView: GMSMapView!
    // private var clusterManager: GMUClusterManager!
    // private var clusterManagerExternal: GMUClusterManager!
    var userLocation: CLLocation!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var locationButtonView: UIView!
    @IBOutlet weak var filterButtonView: UIView!
    @IBOutlet weak var searchButtonView: UIView!
    @IBOutlet weak var closeIcon: UIButton!
    
    var viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    var allowAPI = true
    var isFirstAnimation = true
    let itemWidth = UIScreen.main.bounds.width
    var placesClient = GMSPlacesClient.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        
        bindViewModel()
        LocationManager.shared.startUpdatingLocation()
        LocationManager.shared.updatedLocation = { location in
            if let location = location {
                self.userLocation = location
                if let selectedChargePoint = self.viewModel.selectedChargePoint {
                    self.viewModel.selectedChargePoint = nil
                    if let latitude = Double(selectedChargePoint.latitude), let longitude = Double(selectedChargePoint.longitude) {
                        self.updateMapCenter(coordinate: CLLocationCoordinate2DMake(latitude, longitude))
                        if let chargePointIndex = self.viewModel.getPowerSources().firstIndex(where: {$0.id == selectedChargePoint.id}) {
                            let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
                            if chargePointIndex < numberOfItems {
                                self.collectionView.scrollToItem(at: IndexPath(item: chargePointIndex, section: 0), at: .centeredHorizontally, animated: true)
                            }
                        }
                    }
                }
                
                self.locationView.isHidden = true
                self.viewModel.getNearByPowerSource(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, callVisited: false, callExternalAPI: !isShowVerifiedCPOnly)
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if LocationManager.shared.checkLocationEnabled() == true {
            locationView.isHidden = true
        } else {
            locationView.isHidden = false
        }
        
        if CommonUtils.isUserLoggedIn() {
            let balanceAttributed = NSMutableAttributedString()
            balanceAttributed.custom(String(format: "%.1f ", CommonUtils.getCurrentUserBalance()), font: .robotoMedium(ofSize: 16), color: UIColor(named: "008CE9") ?? .green)
            balanceAttributed.custom(CommonUtils.getCurrency(), font: .robotoBold(ofSize: 12), color: UIColor(named: "7A7A7A") ?? .green)
            balanceLabel.attributedText = balanceAttributed
        }
        
        LocationManager.shared.onLocation = { location in
            if location != nil {
                if LocationManager.shared.checkLocationEnabled() == true {
                    self.locationView.isHidden = true
                } else {
                    self.locationView.isHidden = false
                }
                self.userLocation = location
                // self.updateMapCenter()
                return
            }
        }
    }
    
    func initFont() {
        locationDescLabel.font = .robotoRegular(ofSize: 14)
        helpLabel.font = .robotoMedium(ofSize: 14)
        locationView.layer.cornerRadius = 5.0
        helpLabel.text = CommonUtils.getStringFromXML(name: "help_text")
        locationDescLabel.text = CommonUtils.getStringFromXML(name: "auto_location_error")
    }
    
    func initUI() {
        do {
          if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
            mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
          }
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = false
        locationView.addOnlyDropshadowtoVIEW()
        filterButtonView.addOnlyDropshadowtoVIEW()
        searchButtonView.addOnlyDropshadowtoVIEW()
        self.viewModel.markers = []
    }
    
    func bindViewModel() {
        viewModel.powerSources.asObserver()
            .subscribe(
                onNext: { powerSources in
                    self.addPowerSourceMarkers(powerSources)
                    self.collectionView.reloadData()
                }
            )
            .disposed(by: disposeBag)
        
        mapView.rx.handleTapMarker { marker in
            if let powerSource = marker.userData as? ChargePoint {
                if let currentSelectedMarker = self.mapView.selectedMarker, let currentCP = currentSelectedMarker.userData as? ChargePoint, currentCP.id == powerSource.id {
                    if let detailVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: PowerSourceDetailViewController.className) as? PowerSourceDetailViewController {
                        detailVC.viewModel = ChargePointDetailViewModel(chargePoint: powerSource)
                        detailVC.modalPresentationStyle = .overFullScreen
                        self.present(detailVC, animated: true, completion: nil)
                    }
                } else {
                    self.highlightMarket(chargePoint: powerSource)
                    if let firstIndex = self.viewModel.getPowerSources().firstIndex(where: {$0.id == powerSource.id}) {
                        self.collectionView.scrollToItem(at: IndexPath(item: firstIndex, section: 0), at: .centeredHorizontally, animated: true)
                    }
                }
            }
            return true
        }
        
        mapView.rx.didChange
            .debounce(.milliseconds(1500), scheduler: MainScheduler.instance)
            .subscribe({ position in
                if let latitude = position.element?.target.latitude, let longitude = position.element?.target.longitude, self.allowAPI {
                    self.viewModel.getNearByPowerSource(latitude: latitude, longitude: longitude, callVisited: false, callExternalAPI: !isShowVerifiedCPOnly)
                } else {
                    self.allowAPI = true
                }
            })
            .disposed(by: disposeBag)
        
        mapView.rx.idleAt.asObservable()
            .subscribe { position in
                if self.userLocation != nil {
                    if self.viewModel.isLoadedMap {
                        self.userLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
                    }
                    self.viewModel.isLoadedMap = true
                } else {
                    self.viewModel.isLoadedMap = true
                    self.userLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
                }
            }.disposed(by: disposeBag)
    }
    
    func addPowerSourceMarkers(_ powerSources: [ChargePoint]) {
        for powerSource in powerSources {
            if let latitude = Double(powerSource.latitude), let longitude = Double(powerSource.longitude) {
                if !self.viewModel.markers.contains(where: { marker in
                    if let data = marker.userData as? ChargePoint, data.identifier == powerSource.identifier {
                        return true
                    }
                    return false
                }) {
                    let image = UIImage(named: "spark8")
                    let marker = MarkerUtils.createMarker(latitude: latitude, longitude: longitude, rating: powerSource.rating, markerImage: image, isGoogle: powerSource.isGoogle)
                    marker.title = ""
                    marker.userData = powerSource
                    marker.zIndex = powerSource.isExternal ? 0:1
                    marker.map = self.mapView
                    self.viewModel.markers.append(marker)
                }
            }
        }
        if isFirstAnimation {
            isFirstAnimation = false
            if let selectedChargePoint = viewModel.selectedChargePoint {
                self.highlightMarket(chargePoint: selectedChargePoint)
                return
            }
            if let firstCP = powerSources.first(where: {!$0.isExternal}), let cpLatitude = Double(firstCP.latitude), let cpLongitude = Double(firstCP.longitude), let coordinates = LocationManager.shared.location?.coordinate {
                let distance = CommonUtils.distanceBetweenTwoLocations(source: CLLocation(latitude: cpLatitude, longitude: cpLongitude), destination: CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude))
                if distance <= 10 {
                    self.highlightMarket(chargePoint: firstCP)
                    self.updateMapCenter(coordinate: CLLocationCoordinate2D(latitude: cpLatitude, longitude: cpLongitude))
                    if let chargePointIndex = powerSources.firstIndex(where: { $0.id == firstCP.id }) {
                        let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
                        if chargePointIndex < numberOfItems {
                            self.collectionView.scrollToItem(at: IndexPath(item: chargePointIndex, section: 0), at: .centeredHorizontally, animated: true)
                        }
                    }
                    return
                }
            }
            if let currentLocation = LocationManager.shared.location?.coordinate, let nearestPowerSource = HomeUtils.findNearestPowerSource(from: powerSources, currentLocation: currentLocation), let cpLatitude = Double(nearestPowerSource.latitude), let cpLongitude = Double(nearestPowerSource.longitude) {
                self.highlightMarket(chargePoint: nearestPowerSource)
                self.updateMapCenter(coordinate: CLLocationCoordinate2D(latitude: cpLatitude, longitude: cpLongitude))
                DispatchQueue.main.async {
                    if let chargePointIndex = powerSources.firstIndex(where: {$0.id == nearestPowerSource.id}) {
                        let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
                        if chargePointIndex < numberOfItems {
                            self.collectionView.scrollToItem(at: IndexPath(item: chargePointIndex, section: 0), at: .centeredHorizontally, animated: true)
                        }
                    }
                }
            }
            /*if let firstCP = powerSources.last(where: {$0.is_external}), let cpLatitude = Double(firstCP.latitude), let cpLongitude = Double(firstCP.longitude), let coordinates = LocationManager.shared.location?.coordinate {
                let distance = CommonUtils.distanceBetweenTwoLocations(source: CLLocation(latitude: cpLatitude, longitude: cpLongitude), destination: CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude))
                if distance <= 10 {
                    self.highlightMarket(chargePoint: firstCP)
                    self.updateMapCenter(coordinate: CLLocationCoordinate2D(latitude: cpLatitude, longitude: cpLongitude))
                    DispatchQueue.main.async {
                        if let chargePointIndex = powerSources.firstIndex(where: {$0.id == firstCP.id}) {
                            let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
                            if chargePointIndex < numberOfItems {
                                self.collectionView.scrollToItem(at: IndexPath(item: chargePointIndex, section: 0), at: .centeredHorizontally, animated: true)
                            }
                        }
                    }
                    return
                }
            }
            if let firstCP = powerSources.first, let cpLatitude = Double(firstCP.latitude), let cpLongitude = Double(firstCP.longitude) {
                self.highlightMarket(chargePoint: firstCP)
                self.updateMapCenter(coordinate: CLLocationCoordinate2D(latitude: cpLatitude, longitude: cpLongitude))
                DispatchQueue.main.async {
                    if let chargePointIndex = powerSources.firstIndex(where: {$0.id == firstCP.id}) {
                        let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
                        if chargePointIndex < numberOfItems {
                            self.collectionView.scrollToItem(at: IndexPath(item: chargePointIndex, section: 0), at: .centeredHorizontally, animated: true)
                        }
                    }
                }
            }*/
        }
    }
    
    func updateMapCenter(coordinate: CLLocationCoordinate2D) {
        mapView?.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    }
    
    @IBAction func didTapOnSearchLocationButton(_ sender: Any) {
        guard let searchVC = UIStoryboard(storyboard: .map).instantiateViewController(withIdentifier: SearchLocationPopup.className) as? SearchLocationPopup else {
            return
        }
        searchVC.modalPresentationStyle = .overFullScreen
        searchVC.completionLocation = { place in
            self.mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 11, bearing: 0, viewingAngle: 0)
        }
        self.present(searchVC, animated: false) {
        }
    }
    
    @IBAction func didTap(onLocationButton sender: Any) {
        LocationUtils.handleLocationAuthorization()
    }

    @IBAction func didTapOnBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnHelpButton(_ sender: Any) {
        self.supportRequest()
    }
    
    @IBAction func didTapOnBalanceButton(_ sender: Any) {
        guard let balanceVC = UIStoryboard(storyboard: .balance).instantiateViewController(withIdentifier: UserShowBalanceViewController.className) as? UserShowBalanceViewController else {
            return
        }
        let navBalance = CommonUtils.navigationToController()
        navBalance.setViewControllers([balanceVC], animated: true)
        self.present(navBalance, animated: true, completion: nil)
    }
    
    @IBAction func didTapOnCurrentLocationButton(_ sender: Any) {
        if let location = LocationManager.shared.location {
            self.updateMapCenter(coordinate: location.coordinate)
            if collectionView.numberOfItems(inSection: 0) > 0 {
                collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
            }
        }
    }
    
    @IBAction func didTapOnFilterButton(_ sender: Any) {
        guard let filterVC = UIStoryboard(storyboard: .map).instantiateViewController(withIdentifier: FilterViewController.className) as? FilterViewController else {
            return
        }
        filterVC.modalPresentationStyle = .overFullScreen
        filterVC.viewModel = self.viewModel
        self.present(filterVC, animated: true, completion: nil)
    }
}

extension UIView {
    class func fromNib(named: String? = nil) -> Self {
        let name = named ?? "\(Self.self)"
        guard
            let nib = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
            else { fatalError("missing expected nib named: \(name)") }
        guard
            let view = nib.first as? Self
            else { fatalError("view of type \(Self.self) not found in \(nib)") }
        return view
     }
}

extension StoreMapViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getPowerSources().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NearByCollectionViewCell.className, for: indexPath) as? NearByCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let cp = self.viewModel.getPowerSources().value(at: indexPath.item) {
            cell.setup(cp: cp)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cp = self.viewModel.getPowerSources().value(at: indexPath.item) {
            if let detailVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: PowerSourceDetailViewController.className) as? PowerSourceDetailViewController {
                detailVC.viewModel = ChargePointDetailViewModel(chargePoint: cp)
                detailVC.modalPresentationStyle = .overFullScreen
                self.present(detailVC, animated: true, completion: nil)
            }
        }
    }
}

extension StoreMapViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let centerPoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            // Now you have the indexPath of the centered item
            // let centeredItem = collectionView.cellForItem(at: indexPath)
            
            if let chargePoint = self.viewModel.getPowerSources().value(at: indexPath.item) {
                self.allowAPI = false
                self.updateMapCenter(coordinate: CLLocationCoordinate2D(latitude: Double(chargePoint.latitude)!, longitude: Double(chargePoint.longitude)!))
                self.highlightMarket(chargePoint: chargePoint)
            }
        }
    }
    
    func highlightMarket(chargePoint: ChargePoint) {
        // Deselect the old marker (if any)
        if let oldMarker = self.mapView.selectedMarker, let cp = oldMarker.userData as? ChargePoint {
            let image = UIImage(named: "spark8")//cp.is_external ? UIImage(named: "spark9") : UIImage(named: "spark8")
            oldMarker.iconView = MarkerUtils.createMarkerView(rating: cp.rating, markerImage: image, isGoogle: cp.isGoogle)
            oldMarker.zIndex = cp.isExternal ? 0 : 1
            self.scaleMarkerWithAnimation(marker: oldMarker, selected: false)
        }

        // Find and select the new marker
        if let newMarker = self.viewModel.markers.first(where: { marker in
            if let cp = marker.userData as? ChargePoint, cp.id == chargePoint.id {
                let customMarkerView9 = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 45, height: 50 + (50/3)*2))
                customMarkerView9.imageName = "spark8"
                marker.iconView = customMarkerView9
                marker.zIndex = 2
                self.scaleMarkerWithAnimation(marker: marker, selected: true)
                return true
            }
            return false
        }) {
            self.mapView.selectedMarker = newMarker
        }
    }

    func scaleMarkerWithAnimation(marker: GMSMarker, selected: Bool) {
        marker.tracksViewChanges = true
        if selected {
            if let customMarkerView = marker.iconView as? CustomMarkerView {
                // Bounce up and down animation
                let bounceAnimation = CAKeyframeAnimation(keyPath: "position")
                bounceAnimation.values = [
                    NSValue(cgPoint: customMarkerView.iconImageView.center),
                    NSValue(cgPoint: CGPoint(x: customMarkerView.iconImageView.center.x, y: customMarkerView.iconImageView.center.y - customMarkerView.iconImageView.frame.size.height/3)),
                    NSValue(cgPoint: customMarkerView.iconImageView.center)
                ]
                bounceAnimation.keyTimes = [0, 0.5, 1.0]
                bounceAnimation.timingFunctions = [
                    CAMediaTimingFunction(name: .easeInEaseOut),
                    CAMediaTimingFunction(name: .easeInEaseOut)
                ]
                bounceAnimation.duration = 1.0
                bounceAnimation.repeatCount = .infinity
                
                customMarkerView.subviews.first?.layer.add(bounceAnimation, forKey: "bounceAnimation")
            }
        } else {
            marker.iconView?.subviews.first?.layer.removeAnimation(forKey: "bounceAnimation")
        }
    }
}

class CustomMarkerView: UIView {
    let iconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 50)) // Adjust the size as needed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var imageName: String = "" {
        didSet {
            iconImageView.image = UIImage(named: imageName)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func commonInit() {
        addSubview(iconImageView)
        iconImageView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    }
}
