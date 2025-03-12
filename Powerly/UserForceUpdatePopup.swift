//
//  UserForceUpdatePopup.swift
//  PowerShare
//
//  Created by admin on 21/10/21.

//

import UIKit

class UserForceUpdatePopup: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var gasableVersionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var updateNowButton: UIButton!
    @IBOutlet var callView: UIView!
    @IBOutlet var whatsAppView: UIView!
    @IBOutlet var callLabel: UILabel!
    @IBOutlet var whatsAppLabel: UILabel!
    @IBOutlet var orderViaLabel: UILabel!
    private var isFristTime = false
    public var actualVersion = ""
    var currentCountry: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(checkAppVersion(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 16)
        gasableVersionLabel.font = .robotoBold(ofSize: 18)
        descriptionLabel.font = .robotoRegular(ofSize: 16)
        updateNowButton.titleLabel?.font = .robotoMedium(ofSize: 16)
    }
    
    func initUI() {
        headerLabel.text = CommonUtils.getStringFromXML(name: "update_required")
        gasableVersionLabel.text = "\(appName.capitalized) \(actualVersion)"
        descriptionLabel.text = CommonUtils.getStringFromXML(name: "force_update_desc")
        updateNowButton.setTitle(CommonUtils.getStringFromXML(name: "update_now"), for: .normal)
        orderViaLabel.text = CommonUtils.getStringFromXML(name: "order_via")
        callLabel.text = CommonUtils.getStringFromXML(name: "call_title")
        whatsAppLabel.text = CommonUtils.getStringFromXML(name: "whatsapp_title")
        if let country = UserManager.shared.country {
            self.currentCountry = country
        } else {
            UserManager.shared.countryList.forEach { country in
                if country.iso == Locale.current.regionCode {
                    self.currentCountry = country
                }
            }
        }
//        if let whatsappNumber = self.currentCountry?.whatsapp, whatsappNumber != "" {
//            self.whatsAppView.isHidden = false
//        } else {
//            self.whatsAppView.isHidden = true
//        }
        self.whatsAppView.isHidden = true
    }
    
    @objc func checkAppVersion(notification: Notification) {
        NetworkManager().checkAppVersion { needToUpdate, _ in
            if needToUpdate == 0 {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func extracted() -> String {
        return "itms-apps://itunes.apple.com/app/apple-store/id1125723362?mt=8"
    }
    
    @IBAction func didTapOnUpdateNowbutton(sender: Any) {
        if let url = URL(string: extracted()) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func didTapOnCallButton(_ sender: Any) {
        if let contactNumber = self.currentCountry?.contactNumber {
            let phoneNumber = "telprompt://" + contactNumber
            if let url = URL(string: phoneNumber) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func didTapOnWhatAppButton(_ sender: Any) {
//        if let whatsappNumber = self.currentCountry?.whatsapp, whatsappNumber != "" {
//            if let url = URL(string: whatsappNumber) {
//                UIApplication.shared.open(url)
//            }
//        }
    }
}
