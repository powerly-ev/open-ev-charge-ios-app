//
//  EVChargerViewController.swift
//  PowerShare
//
//  Created by admin on 03/05/23.
//  
//
import CoreLocation
import RxSwift
import UIKit

class PowerSourceDetailViewController: UIViewController {
    @IBOutlet weak var callIcon: UIButton!
    @IBOutlet weak var bookInAdvanceLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var verificationImageView: UIImageView!
    
    @IBOutlet weak var openCloseView: UIView!
    @IBOutlet weak var openCloseStackView: UIStackView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var closeTimeLabel: UILabel!
    @IBOutlet weak var availibilityIcon: UIImageView!
    @IBOutlet weak var availibilityLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceStackView: UIStackView!
    @IBOutlet weak var priceValueLabel: UILabel!
    @IBOutlet weak var priceCurrencyLabel: UILabel!
    @IBOutlet weak var priceUnitLabel: UILabel!
    
    @IBOutlet weak var ratingArrow: UIImageView!
    @IBOutlet weak var ratingOutView: UIView!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: StarRatingView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var parkingLabel: UILabel!
    @IBOutlet weak var parkingValueLabel: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionValueLabel: UILabel!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var externalCPNoticeLabel: UILabel!
    
    @IBOutlet weak var connectorView: UIView!
    @IBOutlet weak var chargerTypesCollectionView: UICollectionView!
    @IBOutlet weak var amenitiesCollectionView: UICollectionView!
    @IBOutlet weak var amenitiesHight: NSLayoutConstraint!
    
    @IBOutlet weak var chargeBookBalanceView: UIView!
    // Start Charging button
    @IBOutlet weak var startChargingView: UIView!
    @IBOutlet weak var startChargingIconImageView: UIImageView!
    @IBOutlet weak var startChargingLabel: UILabel!
    @IBOutlet weak var bookInAdvanceView: UIView!
    @IBOutlet weak var startTimeStackView: UIStackView!
    
    // Drive to Station button
    @IBOutlet weak var driveStationView: UIView!
    @IBOutlet weak var driveToStationView: UIView!
    @IBOutlet weak var driveToStationIconImageView: UIImageView!
    @IBOutlet weak var driveToStationLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    // balance view
    @IBOutlet weak var balanceCurrencyStackView: UIStackView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var balanceArrow: UIImageView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var howToChargeLabel: UILabel!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    var viewModel: ChargePointDetailViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initFont()
        
        bindView()
        viewModel.getPowerSourceDetail()
        viewModel.getMediaOfStation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.viewModel.isOpenStartCharging {
            self.viewModel.isOpenStartCharging = false
            self.didTapOnStartCharging(self)
        }

        if let _ = KeychainHelper.getValue(forKey: KeyChainkey.storeUserOnboarding.rawValue, accessGroup: privateAccessToken) {
        } else {
            _ = KeychainHelper.setValue("true", forKey: KeyChainkey.storeUserOnboarding.rawValue, accessGroup: privateAccessToken)
            guard let onboardingVC = UIStoryboard(storyboard: .onboarding).instantiateViewController(withIdentifier: OnboardingViewController.className) as? OnboardingViewController else {
                return
            }
            onboardingVC.modalPresentationStyle = .overFullScreen
            self.present(onboardingVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.balanceLabel.text = String(format: "%.1f", CommonUtils.getCurrentUserBalance())
        self.currencyLabel.text = CommonUtils.getCurrency()
    }
    
    func initFont() {
        titleLabel.font = .robotoMedium(ofSize: 18)
        startTimeLabel.font = .robotoRegular(ofSize: 16)
        closeTimeLabel.font = .robotoRegular(ofSize: 12)
        priceValueLabel.font = .robotoRegular(ofSize: 16)
        priceUnitLabel.font = .robotoRegular(ofSize: 16)
        priceCurrencyLabel.font = .robotoRegular(ofSize: 12)
        ratingLabel.font = .robotoMedium(ofSize: 16)
        balanceLabel.font = .robotoMedium(ofSize: 24)
        currencyLabel.font = .robotoMedium(ofSize: 17)
        bookInAdvanceLabel.font = .robotoMedium(ofSize: 16)
        startChargingLabel.font = .robotoMedium(ofSize: 16)
        distanceLabel.font = .robotoRegular(ofSize: 12)
        driveToStationLabel.font = .robotoMedium(ofSize: 16)
        addressLabel.font = .robotoRegular(ofSize: 12)
        idLabel.font = .robotoRegular(ofSize: 12)
        parkingLabel.font = .robotoRegular(ofSize: 12)
        parkingValueLabel.font = .robotoRegular(ofSize: 11)
        amenitiesLabel.font = .robotoRegular(ofSize: 12)
        descriptionLabel.font = .robotoRegular(ofSize: 12)
        descriptionValueLabel.font = .robotoRegular(ofSize: 11)
        speedLabel.font = .robotoRegular(ofSize: 12)
        availibilityLabel.font = .robotoRegular(ofSize: 14)
        externalCPNoticeLabel.font = .robotoRegular(ofSize: 12)
        howToChargeLabel.font = .robotoMedium(ofSize: 12)
    }
    
    func initUI() {
        if isLanguageArabic {
            let layout = UICollectionViewRightAlignedLayout()
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            amenitiesCollectionView.collectionViewLayout = layout
            openCloseView.semanticContentAttribute = .forceRightToLeft
            openCloseStackView.semanticContentAttribute = .forceRightToLeft
            priceStackView.semanticContentAttribute = .forceRightToLeft
            priceView.semanticContentAttribute = .forceRightToLeft
            priceValueLabel.textAlignment = .right
            ratingOutView.semanticContentAttribute = .forceRightToLeft
            ratingStackView.semanticContentAttribute = .forceRightToLeft
            photosCollectionView.semanticContentAttribute = .forceRightToLeft
            balanceView.semanticContentAttribute = .forceRightToLeft
            driveStationView.semanticContentAttribute = .forceRightToLeft
            chargerTypesCollectionView.semanticContentAttribute = .forceRightToLeft
            parkingLabel.textAlignment = .right
            parkingValueLabel.textAlignment = .right
            amenitiesLabel.textAlignment = .right
            amenitiesCollectionView.semanticContentAttribute = .forceRightToLeft
            descriptionLabel.textAlignment = .right
            descriptionValueLabel.textAlignment = .right
            ratingArrow.image = UIImage(systemName: "chevron.backward")
            balanceArrow.image = UIImage(systemName: "chevron.backward")
            addressLabel.textAlignment = .right
            startTimeStackView.semanticContentAttribute = .forceRightToLeft
            closeTimeLabel.textAlignment = .right
        } else {
            let layout = UICollectionViewLeftAlignedLayout()
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            amenitiesCollectionView.collectionViewLayout = layout
        }
    }
    
    func bindView() {
        viewModel.powerSource.asObservable().subscribe { powerSource in
            if let element = powerSource.element, let data = element {
                self.initData(data: data)
            }
        }.disposed(by: disposeBag)
        
        if self.viewModel.getPowerSource()?.isGoogle ?? false {
            viewModel.mediaPlaces
             .asDriver(onErrorJustReturn: [])
             .drive(photosCollectionView.rx.items(cellIdentifier: MediaCell.className,
                                            cellType: MediaCell.self)) { _, element, cell in
                 cell.loadImageFromPlaceMetaData(metaData: element)
             }.disposed(by: disposeBag)
            
            viewModel.mediaPlaces.asObservable().subscribe { medias in
                self.photosCollectionView.isHidden = medias.element?.count == 0
            }.disposed(by: disposeBag)
        } else {
            viewModel.medias
             .asDriver(onErrorJustReturn: [])
             .drive(photosCollectionView.rx.items(cellIdentifier: MediaCell.className,
                                            cellType: MediaCell.self)) { _, element, cell in
                 cell.mediaImageView.sd_setImage(with: URL(string: element.url), placeholderImage: UIImage(named: "genaral_placeholder"))
             }.disposed(by: disposeBag)
            
            viewModel.medias.asObservable().subscribe { medias in
                self.photosCollectionView.isHidden = medias.element?.count == 0
            }.disposed(by: disposeBag)
        }
        
        photosCollectionView.rx.itemSelected.asObservable().subscribe { indexPath in
            guard let fullVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: FullScreenImageViewController.className) as? FullScreenImageViewController else {
                return
            }
            fullVC.modalPresentationStyle = .fullScreen
            if self.viewModel.getPowerSource()?.isGoogle ?? false {
                if let placeData = try? self.viewModel.mediaPlaces.value() {
                    fullVC.medias = placeData
                }
            } else {
                if let medias = try? self.viewModel.medias.value() {
                    fullVC.medias = medias
                }
            }
            fullVC.currentIndex = indexPath.element?.item ?? 0
            self.present(fullVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
    
    func initData(data: ChargePoint) {
        callIcon.isHidden = data.contactNumber == ""
        if data.isExternal {
            self.chargeBookBalanceView.isHidden = true
            self.verificationImageView.isHidden = true
            self.externalCPNoticeLabel.text = NSLocalizedString("external_notice", comment: "")
            ratingArrow.isHidden = true
        }
        self.verificationImageView.isHidden = data.isExternal
        self.noticeView.isHidden = !data.isExternal
        // Set up time slot
        self.viewModel.setUpTimeSlot(chargePoint: data)
        
        // Set basic information
        self.idLabel.text = String(format: "%@ #%@", NSLocalizedString("station", comment: ""), data.id)
        self.titleLabel.text = data.title
        if let address = data.address {
            self.addressLabel.text = CommonUtils.getFullAddress(from: address)
        } else {
            self.addressLabel.text = ""
        }
        self.ratingLabel.text = String(format: "%.1f", data.rating)
        self.ratingView.rating = data.rating
        var isOpen = true
        if data.isGoogle {
            self.closeTimeLabel.isHidden = true
            if let day = data.weekDays?[MarkerUtils.currentDayOfWeek()] {
                self.startTimeLabel.text = day
            } else {
                self.startTimeLabel.text = ""
            }
            favoriteButton.isHidden = true
            priceStackView.isHidden = true
            infoView.isHidden = true
        } else {
            // Set open/close time information
            if data.openTime == "00:00:00" && data.closeTime == "23:59:00" {
                self.startTimeLabel.text = NSLocalizedString("open_24_hours", comment: "")
                self.closeTimeLabel.isHidden = true
                let availibility = CommonUtils.getCorrectStatus(chargePoint: data)
                self.startTimeLabel.textColor = availibility.secondaryColor
                self.availibilityLabel.text = availibility.statusText
                self.availibilityIcon.image = availibility.statusImage
                self.availibilityLabel.textColor = availibility.primaryColor
                self.availibilityIcon.tintColor = availibility.primaryColor
            } else {
                if let openTimeComponent = data.openTime.getTimeComponents(),
                   let closeTimeComponent = data.closeTime.getTimeComponents() {
                    
                    let currentTime = Date()
                    let openTime = Calendar.current.date(bySettingHour: openTimeComponent.hours, minute: openTimeComponent.minutes, second: openTimeComponent.seconds, of: Date())!
                    let closeTime = Calendar.current.date(bySettingHour: closeTimeComponent.hours, minute: closeTimeComponent.minutes, second: closeTimeComponent.seconds, of: Date())!
                    
                    if CommonUtils.isTimeWithinRange(currentTime: currentTime, openTime: openTime, closeTime: closeTime) {
                        let availibility = CommonUtils.getCorrectStatus(chargePoint: data)
                        self.availibilityLabel.text = availibility.statusText
                        self.availibilityIcon.image = availibility.statusImage
                        self.availibilityLabel.textColor = availibility.primaryColor
                        self.availibilityIcon.tintColor = availibility.primaryColor
                        let text = CommonUtils.getStringFromXML(name: "open_store")
                        self.startTimeLabel.text = text
                        self.startTimeLabel.textColor = availibility.secondaryColor
                        self.closeTimeLabel.text = String(format: "%@ %@", CommonUtils.getStringFromXML(name: "close_in"), data.closeTime.timeConversion12(format: "HH:mm:ss", inTimeZone: TimeZone(identifier: "UTC")))
                        self.closeTimeLabel.textColor = UIColor(named: "222222")
                        self.availibilityIcon.isHidden = false
                        self.availibilityLabel.isHidden = false
                    } else {
                        isOpen = false
                        self.startTimeLabel.text = CommonUtils.getStringFromXML(name: "closed_title")
                        self.startTimeLabel.textColor = UIColor(named: "222222")
                        self.closeTimeLabel.text = String(format: "%@ %@", CommonUtils.getStringFromXML(name: "open_in"), data.openTime.timeConversion12(format: "HH:mm:ss", inTimeZone: TimeZone(identifier: "UTC")))
                        self.closeTimeLabel.textColor = UIColor(named: "008CE9")
                        self.availibilityIcon.isHidden = true
                        self.availibilityLabel.isHidden = true
                    }
                } else {
                    self.startTimeLabel.text = ""
                    self.closeTimeLabel.text = ""
                }
            }
        }
        
        // Set distance and charging views
        if let location = LocationManager.shared.location,
           let powerLatitude = Double(data.latitude),
           let powerLongitude = Double(data.longitude) {
            
            let sourceLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let destinationLocation = CLLocation(latitude: powerLatitude, longitude: powerLongitude)
            let kms = CommonUtils.distanceBetweenTwoLocations(source: sourceLocation, destination: destinationLocation)
            self.distanceLabel.text = String(format: "%.1f %@ %@", kms, CommonUtils.getStringFromXML(name: "km_title"), NSLocalizedString("away", comment: ""))
            
            if kms > 0.1 {
                self.driveToStationView.backgroundColor = UIColor(named: "222222")
                self.driveToStationLabel.textColor = UIColor.white
                self.driveToStationIconImageView.tintColor = UIColor.white
                
                self.startChargingView.backgroundColor = UIColor(named: "F3F3F3")
                self.startChargingLabel.textColor = UIColor(named: "222222")
                self.startChargingIconImageView.tintColor = UIColor(named: "222222")
            } else {
                self.startChargingView.backgroundColor = UIColor(named: "222222")
                self.startChargingLabel.textColor = UIColor.white
                self.startChargingIconImageView.tintColor = UIColor.white
                
                self.driveToStationView.backgroundColor = UIColor(named: "F3F3F3")
                self.driveToStationLabel.textColor = UIColor(named: "222222")
                self.driveToStationIconImageView.tintColor = UIColor(named: "222222")
            }
        }
        
        // Set description and price
        self.descriptionValueLabel.text = data.description
        self.displayPrice(data: data)
        
        if let maxConnector = data.connectors.max(by: { $0.maxPower < $1.maxPower }) {
            let mutedString = NSMutableAttributedString()
            mutedString.custom(maxConnector.maxPower.description + " \(NSLocalizedString("kw", comment: ""))", font: .robotoRegular(ofSize: 12), color: UIColor(named: "008CE9") ?? .blue)
            mutedString.custom(" \(NSLocalizedString("max", comment: ""))", font: .robotoRegular(ofSize: 12), color: UIColor(named: "222222") ?? .black)
            self.speedLabel.attributedText = mutedString
        } else {
            self.speedLabel.text = ""
        }
        // Reload collection views
        self.connectorView.isHidden = data.connectors.count == 0
        self.chargerTypesCollectionView.reloadData()
        self.amenitiesCollectionView.reloadData()
        self.amenitiesCollectionView.setNeedsLayout()
        self.amenitiesCollectionView.layoutIfNeeded()
        self.amenitiesHight.constant = self.amenitiesCollectionView.contentSize.height
        
        if data.onlineStatus == 1 {
            bookInAdvanceView.isUserInteractionEnabled = true
            startChargingView.isUserInteractionEnabled = isOpen
            self.startChargingView.backgroundColor = UIColor(named: "F3F3F3")
            self.startChargingLabel.textColor = UIColor(named: "222222")
            self.startChargingIconImageView.tintColor = UIColor(named: "222222")
            
            self.driveToStationView.backgroundColor = UIColor(named: "F3F3F3")
            self.driveToStationLabel.textColor = UIColor(named: "222222")
            self.driveToStationIconImageView.tintColor = UIColor(named: "222222")
        } else {
            bookInAdvanceView.isUserInteractionEnabled = false
            startChargingView.isUserInteractionEnabled = false
        }
    }

    func displayPrice(data: ChargePoint) {
        guard self.viewModel.times.value(at: self.viewModel.selectedIndex) != nil else {
            return
        }
        priceCurrencyLabel.text = CommonUtils.getCurrency()
        let priceText = String(format: "%.2f", data.price)
        var unitText = String(format: " %@ %@", NSLocalizedString("per", comment: ""), data.priceUnit.getPriceUnitName())
        if let type = PriceUnit(rawValue: data.sessionLimitType), type == .energy, data.sessionLimitValue > 0 {
            unitText.append(String(format: " (%.f \(NSLocalizedString("max", comment: "")))", data.sessionLimitValue))
        }
        self.priceValueLabel.text = priceText
        self.priceUnitLabel.text = unitText
    }

    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func moveToHomePage(activeSession: ActiveSession, currentView: Bool) {
        self.dismiss(animated: true) {
            if let tabVC = CommonUtils.getTabBarView() {
                tabVC.selectedIndex = 2
                if let navVC = tabVC.viewControllers?.value(at: 2) as? UINavigationController {
                    navVC.dismiss(animated: false)
                    navVC.popToRootViewController(animated: true)
                    if let myOrderVC = navVC.viewControllers.first as? MyOrderViewController {
                        myOrderVC.viewModel.updateSelection(selection: .active)
                    }
                }
                guard let evMeterVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: EVMeterViewController.className) as? EVMeterViewController else {
                    return
                }
                evMeterVC.modalPresentationStyle = .fullScreen
                evMeterVC.activeSession = activeSession
                tabVC.present(evMeterVC, animated: true, completion: nil)
                evMeterVC.startAnimation(isCurrentView: false)
            }
        }
    }
    
    @IBAction func didTapOnStartCharging(_ sender: Any) {
        guard let startPopup = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: StartChargingPopup.className) as? StartChargingPopup else {
            return
        }
        startPopup.viewModel = self.viewModel
        startPopup.completionStartCharging = {model in
            self.viewModel = model
            self.startTransaction()
        }
        startPopup.modalPresentationStyle = .overFullScreen
        self.present(startPopup, animated: true)
    }
    
    func startTransaction() {
        guard let selectTime = self.viewModel.times.value(at: viewModel.selectedIndex) else {
            return
        }
        guard let powerSource = self.viewModel.getPowerSource() else {
            return
        }
        Task {
            let quantity = selectTime.isFull ? "FULL":selectTime.time.description
            if let response = await self.viewModel.startTransaction(id: powerSource.id, quantity: quantity, connectors: self.viewModel.selectedConnectors) {
                if response.0 == 1 {
                    if let session = response.2 {
                        self.moveToHomePage(activeSession: session, currentView: true)
                    }
                } else {
                    TSMessage.showNotification(in: self, title: "", subtitle: response.1, type: .error)
                }
            }
        }
    }
    
    @IBAction func didTapOnBookInAdvanceButton(_ sender: Any) {
    }
    
    @IBAction func didTapOnDriveToStationButton(_ sender: Any) {
        guard let powerSource = self.viewModel.getPowerSource(), let latitude = Double(powerSource.latitude), let longitude = Double(powerSource.longitude) else {
            return
        }
        self.openGoogleMapsWithDirections(latitude: latitude, longitude: longitude)
    }
    
    @IBAction func didTapOnPaymentMethodView(_ sender: Any) {
        guard let balanceVC = UIStoryboard(storyboard: .balance).instantiateViewController(withIdentifier: UserShowBalanceViewController.className) as? UserShowBalanceViewController else {
            return
        }
        let navBalance = CommonUtils.navigationToController()
        navBalance.setViewControllers([balanceVC], animated: true)
        self.present(navBalance, animated: true, completion: nil)
    }
    
    @IBAction func didTapOnLikeButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func didTapOnPhoneButton(_ sender: Any) {
        if let contactNumber = self.viewModel.getPowerSource()?.contactNumber {
            let phoneNumber = "telprompt://" + contactNumber
            if let url = URL(string: phoneNumber) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func didTapOnHowToChargeButton(_ sender: Any) {
        guard let onboardingVC = UIStoryboard(storyboard: .onboarding).instantiateViewController(withIdentifier: OnboardingViewController.className) as? OnboardingViewController else {
            return
        }
        onboardingVC.modalPresentationStyle = .overFullScreen
        self.present(onboardingVC, animated: true)
    }
    
    @IBAction func didTapOnReviewsButton(_ sender: Any) {
        let chargingPoint = self.viewModel.getPowerSource()
        if chargingPoint?.isGoogle ?? false {
            return
        }
        guard let ratingsVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: RatingsReviewsViewController.className) as? RatingsReviewsViewController else {
            return
        }
        ratingsVC.powerSource = chargingPoint
        ratingsVC.modalPresentationStyle = .overFullScreen
        self.present(ratingsVC, animated: true)
    }
    
    func openGoogleMapsWithDirections(latitude: Double, longitude: Double) {
        guard let currentLocation = LocationManager.shared.location?.coordinate else {
            return
        }
        let destination = CLLocationCoordinate2DMake(latitude, longitude)
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            // Open Google Map
            let urlString = "comgooglemaps://?saddr=\(currentLocation.latitude),\(currentLocation.longitude)&daddr=\(destination.latitude),\(destination.longitude)&directionsmode=driving"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            // If Google Maps is not installed, open in Safari
            let urlString = "https://www.google.com/maps/dir/?api=1&origin=\(currentLocation.latitude),\(currentLocation.longitude)&destination=\(destination.latitude),\(destination.longitude)&travelmode=driving"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

extension PowerSourceDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case chargerTypesCollectionView:
            return self.viewModel.getPowerSource()?.connectors.count ?? 0
            
        case amenitiesCollectionView:
            return self.viewModel.getPowerSource()?.amenities.count ?? 0
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case chargerTypesCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChargeTypesCollectionViewCell.className, for: indexPath) as? ChargeTypesCollectionViewCell else {
                return UICollectionViewCell()
            }
            if let connector = self.viewModel.getPowerSource()?.connectors.value(at: indexPath.item) {
                cell.setupConnector(connector: connector)
            }
            return cell
            
        case amenitiesCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "amenitiesCell", for: indexPath)
            if let amenity = self.viewModel.getPowerSource()?.amenities.value(at: indexPath.item) {
                if let imageView = cell.viewWithTag(1) as? UIImageView {
                    imageView.sd_setImage(with: URL(string: amenity.icon ?? ""), placeholderImage: UIImage(named: "park"))
                }
                if let amenitiesLabel = cell.viewWithTag(2) as? UILabel {
                    amenitiesLabel.text = amenity.name
                }
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
