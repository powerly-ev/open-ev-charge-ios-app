//
//  HomeViewController.swift
//  PowerShare
//
//  Created by admin on 24/01/23.
//  
//

import GoogleMaps
import GooglePlaces
import RxCocoa
import RxSwift
import SkeletonView
import UIKit

class HomeViewController: GuestCommonViewController {
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var signinLabel: UILabel!
    @IBOutlet weak var signinView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var visitedTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var plugExternalButton: UIButton!
    
    // Location Allow Popup
    @IBOutlet weak var locationAllowDescriptionLabel: UILabel!
    @IBOutlet weak var locationAllowLabel: UILabel!
    
    @IBOutlet weak var nearByStationLabel: UILabel!
    
    @IBOutlet weak var locationView: UIView!
    let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    var userLocation: CLLocation?
    var isFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
        initFont()
        initUI()
        if CommonUtils.isUserLoggedIn() {
            self.viewModel.getUserDetailApi(completion: {
            })
        } else {
            signinView.isHidden = false
        }
        bindView()
        self.viewModel.setUpSliderData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initLoadData()
        if CommonUtils.isUserLoggedIn() && viewModel.loadUserDetailAPI {
            self.viewModel.getUserDetailApi(completion: {})
        }
        if LocationManager.shared.checkLocationEnabled() == true {
            locationView.isHidden = true
        } else {
            locationView.isHidden = false
        }
        LocationManager.shared.startUpdatingLocation()
        LocationManager.shared.updatedLocation = { location in
            if let location = location {
                self.updateMapCenter(location: location.coordinate)
                Task {
                    if await LocationManager.shared.updateCurrencyCountry() {
                        self.viewModel.getUserDetailApi(completion: {})
                    }
                    self.userLocation = location
                    self.locationView.isHidden = true
                    self.viewModel.getNearByPowerSource(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, callVisited: true, callExternalAPI: !isShowVerifiedCPOnly)
                }
                return
            }
        }
    }
    
    func initMap() {
        do {
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        mapView?.delegate = self
        mapView?.isMyLocationEnabled = false
        mapView?.settings.myLocationButton = false
    }
    
    func initFont() {
        helpLabel.font = .robotoMedium(ofSize: 14)
        appNameLabel.font = .robotoBold(ofSize: 14)
        locationAllowDescriptionLabel.font = .robotoRegular(ofSize: 16)
        locationAllowLabel.font = .robotoMedium(ofSize: 16)
        nearByStationLabel.font = .robotoMedium(ofSize: 16)
        
        helpLabel.text = CommonUtils.getStringFromXML(name: "help_text")
        signinLabel.text = CommonUtils.getStringFromXML(name: "Sign_In")
    }
    
    func initUI() {
        tableView.register(UINib(nibName: VisitedTableViewCell.className, bundle: nil), forCellReuseIdentifier: VisitedTableViewCell.className)
        plugExternalButton.addButtonDropshadowtoVIEW()
        if !CommonUtils.isUserLoggedIn() {
            balanceView.isHidden = true
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let size = self.viewModel.adWidth
        flowLayout.itemSize = CGSize(width: size, height: 210)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        sliderCollectionView.setCollectionViewLayout(flowLayout, animated: true)
        sliderCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func initLoadData() {
        if CommonUtils.isUserLoggedIn() {
            DispatchQueue.main.async {
                let balanceAttributed = NSMutableAttributedString()
                balanceAttributed.custom(String(format: "%.1f ", CommonUtils.getCurrentUserBalance()), font: .robotoMedium(ofSize: 16), color: UIColor(named: "008CE9") ?? .green)
                balanceAttributed.custom(CommonUtils.getCurrency(), font: .robotoBold(ofSize: 12), color: UIColor(named: "7A7A7A") ?? .green)
                self.balanceLabel.attributedText = balanceAttributed
            }
        }
    }
    
    func updateMapCenter(location: CLLocationCoordinate2D) {
        mapView?.camera = GMSCameraPosition.camera(withTarget: location, zoom: 11, bearing: 0, viewingAngle: 0)
    }
    
    func bindView() {
        viewModel.sliders
            .asDriver(onErrorJustReturn: [])
            .drive(sliderCollectionView.rx.items(cellIdentifier: SliderCollectionViewCell.className, cellType: SliderCollectionViewCell.self)) { _, element, cell in
                cell.setupData(slider: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.updateUserData.subscribe { userData in
            if userData {
                self.initLoadData()
            }
        }.disposed(by: disposeBag)
        
        UserManager.shared.reviewOrdersList.asObserver().subscribe { reviewOrders in
            if let order = reviewOrders.element?.first {
                guard let controller = UIStoryboard(storyboard: .order).instantiateViewController(withIdentifier: UserFeedBackFormViewController.className) as? UserFeedBackFormViewController else {
                    return
                }
                let viewModel = FeedbackViewModel(session: order)
                viewModel.orderID = order.id
                controller.viewModel = viewModel
                controller.modalPresentationStyle = .overFullScreen
                self.present(controller, animated: true, completion: nil)
            }
        }.disposed(by: disposeBag)
        
        viewModel.powerSources.asObserver()
        .subscribe(
            onNext: { powerSources in
                self.processPowerSources(powerSources)
            }
        )
        .disposed(by: disposeBag)
        
        viewModel.visitedPowerSources.asObserver().subscribe { powerSources in
            let count = powerSources.element?.count ?? 0
            let updatedCount = (count > 4) ? 5:count
            self.visitedTableViewHeight.constant = CGFloat(updatedCount*60)
            self.tableView.reloadData()
        }.disposed(by: disposeBag)
    }
    
    func processPowerSources(_ powerSources: [ChargePoint]) {
        self.mapView.clear()
        
        for powerSource in powerSources {
            if let latitude = Double(powerSource.latitude), let longitude = Double(powerSource.longitude) {
                // let position = CLLocationCoordinate2DMake(latitude, longitude)
                let image = UIImage(named: "spark8") // powerSource.is_external ? UIImage(named: "spark9") : UIImage(named: "spark8")
                let marker = MarkerUtils.createMarker(latitude: latitude, longitude: longitude, rating: powerSource.rating, markerImage: image, isGoogle: powerSource.isGoogle)
                marker.title = powerSource.title
                marker.userData = powerSource
                // let image = powerSource.is_external ? UIImage(named: "spark9") : UIImage(named: "spark8")
                // marker.icon = image
                marker.zIndex = powerSource.isExternal ? 0 : 1
                marker.map = self.mapView
            }
        }
        if isFirstLoad {
            isFirstLoad = false
            if let firstCP = powerSources.first(where: { !$0.isExternal }), let cpLatitude = Double(firstCP.latitude), let cpLongitude = Double(firstCP.longitude), let coordinates = LocationManager.shared.location?.coordinate {
                let distance = CommonUtils.distanceBetweenTwoLocations(source: CLLocation(latitude: cpLatitude, longitude: cpLongitude), destination: CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude))
                if distance <= 10 {
                    updateMapCenter(location: CLLocationCoordinate2D(latitude: cpLatitude, longitude: cpLongitude))
                    return
                }
            }
            if let currentLocation = LocationManager.shared.location?.coordinate, let nearestPowerSource = HomeUtils.findNearestPowerSource(from: powerSources, currentLocation: currentLocation), let cpLatitude = Double(nearestPowerSource.latitude), let cpLongitude = Double(nearestPowerSource.longitude) {
                updateMapCenter(location: CLLocationCoordinate2D(latitude: cpLatitude, longitude: cpLongitude))
            }
        }
    }
    
    @IBAction func didTapOnLocationAllowButton(_ sender: Any) {
        LocationUtils.handleLocationAuthorization()
    }
    
    @IBAction func didTapOnHelpButton(_ sender: Any) {
        self.supportRequest()
    }
    
    @IBAction func didTapOnSigninButton(_ sender: Any) {
        CommonUtils.logFacebookCustomEvents("sigin_tap_map", contentType: [:])
        self.showListOfOtherOptions(showGuest: false)
    }
    
    @IBAction func didTapOnAvailableBalanceButton(_ sender: Any) {
        guard let balanceVC = UIStoryboard(storyboard: .balance).instantiateViewController(withIdentifier: UserShowBalanceViewController.className) as? UserShowBalanceViewController else {
            return
        }
        let navBalance = CommonUtils.navigationToController()
        navBalance.setViewControllers([balanceVC], animated: true)
        self.present(navBalance, animated: true, completion: nil)
    }
    
    @IBAction func didTapOnViewAllButton(_ sender: Any) {
        self.moveToFullMapScreen()
    }
    
    func moveToFullMapScreen(chargePoint: ChargePoint? = nil) {
        if !CommonUtils.isUserLoggedIn() {
            self.showListOfOtherOptions(showGuest: false)
            return
        }
        guard let storeVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: StoreMapViewController.className) as? StoreMapViewController else { return }
        self.viewModel.selectedChargePoint = chargePoint
        storeVC.viewModel = self.viewModel
        self.navigationController?.pushViewController(storeVC, animated: true)
    }
    
    @IBAction func didTapOnAddExternalPowerSource(_ sender: Any) {
        
    }
}

extension HomeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let chargePoint = marker.userData as? ChargePoint {
            self.moveToFullMapScreen(chargePoint: chargePoint)
        }
        return true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        userLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.didTapOnViewAllButton(self)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        marker.tracksInfoWindowChanges = true
        if let infoView = StoreAnnotation.instanceFromNib() as? StoreAnnotation, let powerSource = marker.userData as? ChargePoint {
            infoView.setUpStore(powerSource: powerSource)
            return infoView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let powerSource = marker.userData as? ChargePoint {
            guard let storeListVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: PowerSourceDetailViewController.className) as? PowerSourceDetailViewController else {
                return
            }
            storeListVC.viewModel = ChargePointDetailViewModel(chargePoint: powerSource)
            storeListVC.modalPresentationStyle = .overFullScreen
            self.present(storeListVC, animated: true, completion: nil)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.viewModel.getVisitedPowerSources().count
        return (count > 2) ? 3:count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VisitedTableViewCell.className, for: indexPath) as? VisitedTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        if let powerSource = self.viewModel.getVisitedPowerSources().value(at: indexPath.row) {
            cell.setUpPowerSource(powerSource: powerSource)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let powerSource = self.viewModel.getVisitedPowerSources().value(at: indexPath.row) else {
            return
        }
        guard let storeListVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: PowerSourceDetailViewController.className) as? PowerSourceDetailViewController else {
            return
        }
        storeListVC.viewModel = ChargePointDetailViewModel(chargePoint: powerSource)
         storeListVC.modalPresentationStyle = .overFullScreen
         self.present(storeListVC, animated: true, completion: nil)
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == sliderCollectionView {
            pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
            viewModel.currentIndex = pageControl.currentPage
            // self.autoScroll()
        }
    }
}
