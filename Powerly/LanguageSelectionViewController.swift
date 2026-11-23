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
    static let spanishRegions: Set<String> = ["MX", "ES", "EC", "AR", "CO", "CL", "PE", "VE", "UY", "PY", "BO", "CR", "PA", "DO", "GT", "HN", "NI", "SV", "CU", "PR"]
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
                if Self.spanishRegions.contains(countryCode) {
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
        } else if UserManager.shared.country == nil, let country = UserManager.shared.countryList.first(where: { $0.iso == "MX" }) {
            UserManager.shared.country = country
        }
    }
    
    @objc func handleTap(onLabel tapGesture: UITapGestureRecognizer) {
        guard let text = self.termsLabel.attributedText?.string else {
            return
        }
        let terms = CommonUtils.getStringFromXML(name: "termsofservice")
        if let range = text.range(of: terms),
           tapGesture.didTapAttributedTextInLabel(label: self.termsLabel, inRange: NSRange(range, in: text)) {
            let configured = CommonUtils.getStringFromPlist("TERMS_AND_CONDITIONS_URL")
            if configured.isEmpty == false {
                self.openLegalPage(title: CommonUtils.getStringFromXML(name: "terms_condition"), url: configured)
            }
        } else if let range = text.range(of: CommonUtils.getStringFromXML(name: "privacypolicy")),
                  tapGesture.didTapAttributedTextInLabel(label: self.termsLabel, inRange: NSRange(range, in: text)) {
            let configured = CommonUtils.getStringFromPlist("PRIVACY_POLICY_URL")
            if configured.isEmpty == false {
                self.openLegalPage(title: CommonUtils.getStringFromXML(name: "privacypolicy"), url: configured)
            }
        }
    }

    private func openLegalPage(title: String, url: String) {
        guard let webVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: WebViewController.className) as? WebViewController else {
            return
        }
        webVC.headerString = title
        webVC.loadURL = url
        self.navigationController?.pushViewController(webVC, animated: true)
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
            case "Español":
                userDefault.setValue("es", forKey: UserDefaultKey.languageType.rawValue)
            default:
                userDefault.setValue("en", forKey: UserDefaultKey.languageType.rawValue)
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
        case "es":
            btnLanguage.setTitle("Español", for: .normal)
        default:
            btnLanguage.setTitle("English", for: .normal)
        }
    }
}
