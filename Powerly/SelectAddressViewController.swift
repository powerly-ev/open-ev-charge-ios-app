//
//  SelectAddressViewController.swift
//  PowerShare
//
//  Created by ADMIN on 08/08/23.
//  
//
import GoogleMaps
import UIKit

struct RequestAddress {
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var addressType: String = ""
    var ownedAddress: Int = 0
    var contactNumber: String = ""
}

class SelectAddressViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var pinLocationLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var saveNextLabel: UILabel!
    
    var userLocation: CLLocation!
    var isLoadedMap: Bool = false
    var requestedAddress: RequestAddress?
    var completionSaveNext: ((RequestAddress) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        do {
          if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
            mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
          }
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
        mapView?.delegate = self
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
        
        LocationManager.shared.startUpdatingLocation()
        LocationManager.shared.updatedLocation = { location in
            if let location = location {
                self.updateMapCenter(location: location)
                self.locationView.isHidden = true
                return
            }
        }
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 18)
        pinLocationLabel.font = .robotoRegular(ofSize: 16)
        addressLabel.font = .robotoRegular(ofSize: 16)
        saveNextLabel.font = .robotoMedium(ofSize: 16)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if LocationManager.shared.checkLocationEnabled() == true {
            locationView.isHidden = true
        } else {
            locationView.isHidden = false
        }
        
        LocationManager.shared.onLocation = { location in
            if let location = location {
                if LocationManager.shared.checkLocationEnabled() == true {
                    self.locationView.isHidden = true
                } else {
                    self.locationView.isHidden = false
                }
                if let latitude = UserManager.shared.user?.latitude, latitude != "", latitude != "-1", latitude != "0" {
                } else {
                    self.userLocation = location
                    self.updateMapCenter(location: location)
                }
                return
            }
        }
    }
    
    func updateMapCenter(location: CLLocation) {
        mapView?.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnSaveNextButton(_ sender: Any) {
        self.dismiss(animated: true) {
            if var requestedAddress = self.requestedAddress {
                requestedAddress.latitude = String(format: "%.9f", self.userLocation.coordinate.latitude)
                requestedAddress.longitude = String(format: "%.9f", self.userLocation.coordinate.longitude)
                requestedAddress.address = self.addressLabel.text ?? ""
                self.completionSaveNext?(requestedAddress)
            }
        }
    }
}

extension SelectAddressViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        if isLanguageArabic {
            let local = Locale(identifier: "ar_sa")
            geocoder.reverseGeocodeLocation(location, preferredLocale: local) { placemarks, _ in
                let name = placemarks?.first?.name
                let address = placemarks?.first
                if name != nil {
                    if let street = address?.postalAddress?.street {
                        self.addressLabel.text = street
                    } else {
                        self.addressLabel.text = name
                    }
                    if let city = address?.postalAddress?.city {
                        self.requestedAddress?.city = city
                    }
                    if let state = address?.postalAddress?.state {
                        self.requestedAddress?.state = state
                    }
                }
            }
        } else {
            geocoder.reverseGeocodeLocation(location) { [self] placemarks, _ in
                let name = placemarks?.first?.name
                if let name = name {
                    addressLabel.text = name
                }
                if let city = placemarks?.first?.locality {
                    self.requestedAddress?.city = city
                }
                if let state = placemarks?.first?.administrativeArea {
                    self.requestedAddress?.state = state
                }
            }
        }
        if userLocation != nil {
            if self.isLoadedMap {
                userLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
            }
            self.isLoadedMap = true
        } else {
            self.isLoadedMap = true
            userLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    }
}
