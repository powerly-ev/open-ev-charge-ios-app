//
//  MaintanancePopup.swift
//  PowerShare
//
//  Created by admin on 27/09/22.
//  
//

import UIKit

class MaintanancePopup: UIViewController {
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var callView: UIView!
    @IBOutlet var whatsAppView: UIView!
    @IBOutlet var callLabel: UILabel!
    @IBOutlet var whatsAppLabel: UILabel!
    @IBOutlet var orderViaLabel: UILabel!
    var currentCountry: Country?
    
    let nc = NotificationCenter.default
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = ""
        loadText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callMaintananceAPI()
        nc.addObserver(self, selector: #selector(callMaintananceAPI), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        nc.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func loadText() {
        headerLabel.text = CommonUtils.getStringFromXML(name: "a_short_break")
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
    
    @objc func callMaintananceAPI() {
        NetworkManager().maintenanceMode { success, message, json in
            if let maintenanceMode = json["results"]["maintenanceMode"].bool {
                self.descriptionLabel.text = message
                if maintenanceMode == false {
                    self.dismiss(animated: true)
                }
            }
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
