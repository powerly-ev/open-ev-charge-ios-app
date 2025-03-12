//
//  LanguageSelectionViewController.swift
//  PowerShare
//
//  Created by admin on 12/01/22.
//  
//

import IQKeyboardManagerSwift
import SwiftUI
import UIKit

class LanguageSelectionViewController: GuestCommonViewController {
    @IBOutlet weak var btnLanguage: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var welcomeDescLabel: UILabel!
    @IBOutlet weak var singinAppleLabel: UILabel!
    @IBOutlet weak var explorerLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var appleLogoImageView: UIImageView!
    var openOtherLoginOption = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultCountry()
        initFont()
        initUI()
        if userDefault.object(forKey: UserDefaultKey.languageType.rawValue) == nil {
            let locale = Locale.current
            if let countryCode = locale.regionCode {
                if (countryCode == "SA") || (countryCode == "JO") {
                    userDefault.setValue("ar", forKey: UserDefaultKey.languageType.rawValue)
                } else if countryCode == "EC" {
                    userDefault.setValue("es", forKey: UserDefaultKey.languageType.rawValue)
                } else {
                    userDefault.setValue("en", forKey: UserDefaultKey.languageType.rawValue)
                }
                userDefault.synchronize()
                DELEGATE?.reloadLanguageStrings()
            }
        }
        refreshViewsForNewLanguage()
        
        let infoDict = Bundle.main.infoDictionary
        let appVersion = infoDict?["CFBundleShortVersionString"] as? String
        let buildNumber = infoDict?["CFBundleVersion"] as? String
        versionLabel.text = "Version: \(CommonUtils.getStringFromPlist("VERSION_LABEL")) \(appVersion ?? "")(\(buildNumber ?? ""))"
        if openOtherLoginOption {
            self.didTapOnOtherOptionsButton(self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        initLanguage()
    }
    
    func initUI() {
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(onLabel:))))
    }
    
    func setupDefaultCountry() {
        if let country = UserManager.shared.countryList.first(where: { $0.iso == Locale.current.regionCode }) {
            UserManager.shared.country = country
        } else if UserManager.shared.country == nil, let country = UserManager.shared.countryList.first(where: { $0.iso == "SA" }) {
            UserManager.shared.country = country
        }
    }
    
    @objc func handleTap(onLabel tapGesture: UITapGestureRecognizer) {
        guard let text = self.termsLabel.attributedText?.string else {
            return
        }
        let countryId = UserManager.shared.country?.id
        let terms = CommonUtils.getStringFromXML(name: "termsofservice")
        let privacy = CommonUtils.getStringFromXML(name: "privacypolicy")
    }
    
    func initFont() {
        headerLabel.font = .robotoBlack(ofSize: 32)
        welcomeDescLabel.font = .robotoRegular(ofSize: 16)
        btnLanguage.titleLabel?.font = .robotoMedium(ofSize: 16)
        singinAppleLabel.font = .robotoMedium(ofSize: 18)
        explorerLabel.font = .robotoMedium(ofSize: 18)
    }
    
    func initLanguage() {
        headerLabel.text = CommonUtils.getStringFromXML(name: "welcome_to_gasable")
        welcomeDescLabel.text = CommonUtils.getStringFromXML(name: "welcome_description")
        let attributedText = NSMutableAttributedString().normal(CommonUtils.getStringFromXML(name: "privacy_policy_title"))
        attributedText.colorRange(value: CommonUtils.getStringFromXML(name: "termsofservice"), color: UIColor(named: "008CE9") ?? .lightGray)
        attributedText.colorRange(value: CommonUtils.getStringFromXML(name: "privacypolicy"), color: UIColor(named: "008CE9") ?? .lightGray)
        termsLabel.font = .robotoRegular(ofSize: 16)
        termsLabel.attributedText = attributedText
        singinAppleLabel.text = NSLocalizedString("Sign in with Apple", comment: "")
        explorerLabel.text = NSLocalizedString("Explore other Sign-in options", comment: "")
        if isLanguageArabic {
            headerLabel.textAlignment = .right
            welcomeDescLabel.textAlignment = .right
        } else {
            headerLabel.textAlignment = .left
            welcomeDescLabel.textAlignment = .left
        }
    }

    @IBAction func btnActionChangeLanguage(_ sender: Any) {
        guard let selectVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: SelectLanguageViewController.className) as? SelectLanguageViewController else {
            return
        }
        selectVC.completionSelectedLanguage = { language in
            self.btnLanguage.setTitle(
                language,
                for: .normal)
            switch language {
            case "English":
                userDefault.setValue("en", forKey: UserDefaultKey.languageType.rawValue)
            
            case "العربية":
                userDefault.setValue("ar", forKey: UserDefaultKey.languageType.rawValue)
            
            case "Español":
                userDefault.setValue("es", forKey: UserDefaultKey.languageType.rawValue)
            
            case "Français":
                userDefault.setValue("fr", forKey: UserDefaultKey.languageType.rawValue)
            
            default:
                break
            }
            userDefault.synchronize()
            DELEGATE?.reloadLanguageStrings()
            self.initLanguage()
        }
        self.present(selectVC, animated: true) {
        }
    }
    
    @IBAction func didTapOnOtherOptionsButton(_ sender: Any) {
        self.showListOfOtherOptions(showGuest: true)
    }
    
    @IBAction func didTapOnSigninWithAppleButton(_ sender: Any) {
       
    }
    
    @IBAction func didTapOnSigninWithEmailButton(_ sender: Any) {
        openLoginOptions(option: .email)
    }
    
    
    func refreshViewsForNewLanguage() {
        let selectedLanguage = isLanguageType
        switch selectedLanguage {
        case "en":
            btnLanguage.setTitle("English", for: .normal)
        
        case "ar":
            btnLanguage.setTitle("عربى", for: .normal)
        
        case "es":
            btnLanguage.setTitle("Español", for: .normal)
        
        case "fr":
            btnLanguage.setTitle("French", for: .normal)
        
        default:
            break
        }
    }
}
