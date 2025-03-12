//
//  UserRegistrationViewController.swift
//  PowerShare
//
//  Created by admin on 03/12/21.

//
import CoreLocation
import IQKeyboardManagerSwift
import UIKit
    
class UserRegistrationViewController: UIViewController {
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var countryDropDownArrowImageView: UIImageView!
    var address: Address?
    var mobileNumber: String?
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet var topView: UIView!
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var agreeButton: SpinnerButton!
    @IBOutlet weak var countryPickButton: UIButton!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var signupDescriptionLabel: UILabel!
    
    var countryCode: String?
    @objc var isSkip = false
    @objc var isContinue = false
    var selectedCountry: Country?
    var selectedCity: City?
    var selectedArea: Area?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserSessionManager.shared.clearSession()
        initFont()
        CommonUtils.lastPageSaved(name: "registration")
        initUI()
        loadString()
        if address == nil {
            setupDefaultCountry()
        } else {
            countryPickButton.isUserInteractionEnabled = false
        }
        setupUI()
    }
    
    func initFont() {
        lblHeader.font = .robotoMedium(ofSize: 16)
        signupDescriptionLabel.font = .robotoRegular(ofSize: 16)
        agreeButton.titleLabel?.font = .robotoMedium(ofSize: 16)
    }

    func loadString() {
        lblHeader.text = CommonUtils.getStringFromXML(name: "welcome_title")
        signupDescriptionLabel.text = CommonUtils.getStringFromXML(name: "signup_description")
        agreeButton.setTitle(CommonUtils.getStringFromXML(name: "agree_continue"), for: .normal)
        if mobileNumber != nil {
            mobileTextField.text = mobileNumber
        }
    }

    func initUI() {
        countryDropDownArrowImageView.image = UIImage(named: "ic_dropdownArrow")?.templateImage()
        countryDropDownArrowImageView.tintColor = UIColor(named: "APP_MAIN")
        mobileTextField.becomeFirstResponder()

        if let address = address {
            selectedCountry = address.country
            selectedCity = address.city
            selectedArea = address.area
        }
        
        if let country = selectedCountry {
            var countryCode: String?
            countryCode = "\(country.phoneCode)"
            countryCodeLabel.text = countryCode
            let imagePath = "CountryPicker.bundle/\(country.iso)"
            countryFlagImageView.image = UIImage(named: imagePath)
        }
    }

    @objc func handleTap(onLabel tapGesture: UITapGestureRecognizer) {
        guard let text = self.termsLabel.attributedText?.string else {
            return
        }
        let terms = CommonUtils.getStringFromXML(name: "termsofservice")
        if let range = text.range(of: terms),
           tapGesture.didTapAttributedTextInLabel(label: self.termsLabel, inRange: NSRange(range, in: text)) {

        } else if let range = text.range(of: CommonUtils.getStringFromXML(name: "privacypolicy")),
                  tapGesture.didTapAttributedTextInLabel(label: self.termsLabel, inRange: NSRange(range, in: text)) {
        }
    }
    
    func setupDefaultCountry() {
        if let country = UserManager.shared.countryList.first(where: { $0.iso == Locale.current.regionCode }) {
            UserManager.shared.country = country
            setupUI()
        } else if UserManager.shared.country == nil, let country = UserManager.shared.countryList.first(where: { $0.iso == "SA" }) {
            UserManager.shared.country = country
            setupUI()
        }
    }

    func setupUI() {
        guard let country = UserManager.shared.country else {
            return
        }
        let imagePath = "CountryPicker.bundle/\(String(describing: country.iso))"
        countryFlagImageView.image = UIImage(named: imagePath)
        if address == nil {
            address = Address()
        }
        address?.country = UserManager.shared.country
        selectedCountry = UserManager.shared.country
        if selectedCity == nil {
            selectedCity = City(cityId: "", cityNameArabic: "", cityNameEnglish: "")
            selectedCity?.cityId = ""
            address?.city = selectedCity
        }
        if selectedArea == nil {
            selectedArea = Area(areaId: "", areaNameArabic: "", areaNameEnglish: "")
            selectedArea?.areaId = ""
            address?.area = selectedArea
        }
        if address?.latitude == nil || address?.longitude == nil {
            address?.latitude = ""
            address?.longitude = ""
        }
        mobileTextField.placeholder = CommonUtils.getStringFromXML(name: "enter_mobile_number")
        let phoneCodeToPlaceholder: [String: String] = [
            "966": "5XXXXXXXX",
            "962": "7XXXXXXXX",
            "593": "9XXXXXXXX"
        ]

        if let placeholder = phoneCodeToPlaceholder[country.phoneCode] {
            mobileTextField.placeholder = placeholder
        }

        let countryCode: String = "+\(String(describing: country.phoneCode))"
        self.countryCodeLabel.text = countryCode
    }
    
    func displayFieldError(isError: Bool) {
        if isError {
            numberView.setBorderColor(color: UIColor(named: "CANCEL_TEXT"))
        } else {
            numberView.setBorderColor(color: UIColor(named: "222222"))
        }
    }

    @IBAction func didTap(onBackButton sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnCountryPickButton(_ sender: Any) {
        guard let countryPickVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: SelectCountryViewController.className) as? SelectCountryViewController else {
            return
        }
        countryPickVC.completionSelectedLanguage = { country in
            let currentCountry = UserManager.shared.country
            let currentCode = currentCountry?.phoneCode
            let selectedCode = country.phoneCode
            if currentCode != selectedCode {
                self.mobileTextField.text = ""
            }
            UserManager.shared.country = country
            self.setupUI()
        }
        self.present(countryPickVC, animated: true) {
        }
    }
    
    @IBAction func didTap(onRegistrationButton sender: Any) {
        CommonUtils.logFacebookCustomEvents("agree_continue", contentType: [:])
        view.endEditing(true)

        // VALIDATION
        if selectedCity == nil {
            TSMessage.showNotification(in: DELEGATE?.window?.rootViewController, title: CommonUtils.getStringFromXML(name: "error_title"), subtitle: CommonUtils.getStringFromXML(name: "regis_city_selected"), type: .error, duration: 2)
            return
        }

        if selectedArea == nil {
            TSMessage.showNotification(in: DELEGATE?.window?.rootViewController, title: CommonUtils.getStringFromXML(name: "error_title"), subtitle: CommonUtils.getStringFromXML(name: "selected_condition_spinner"), type: .error, duration: 2)
            return
        }

        mobileTextField.text = mobileTextField.text?.replacingOccurrences(of: "  ", with: " ")
        if (mobileTextField.text?.count ?? 0) <= 6 || (mobileTextField.text?.count ?? 0) >= 15 {
            self.displayFieldError(isError: true)
            return
        } else {
            self.displayFieldError(isError: false)
        }
        
        webserviceCallForDeterMineMethod()
    }
    
    private func showHideProgress(show: Bool) {
        if show {
            agreeButton.showLoading()
            self.view.isUserInteractionEnabled = false
        } else {
            agreeButton.hideLoading()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func webserviceCallForDeterMineMethod() {
        var phone = (mobileTextField.text ?? "").convertToNumber()
        let prefix = phone.prefix(1)
        if prefix == "0" {
            phone = phone.substring(from: 1)
        }
        guard let country = UserManager.shared.country else {
            return
        }
        guard let selectedCountry = selectedCountry else {
            return
        }
        let phoneNumber = "\(country.phoneCode)\(phone)"
        if phone.count <= 6 || phone.count >= 15 {
            TSMessage.showNotification(withTitle: nil, subtitle: CommonUtils.getStringFromXML(name: "enter_mobile_number"), type: .error)
            return
        }
        if !CommonUtils.validatePhone("+\(phoneNumber)") {
            TSMessage.showNotification(withTitle: nil, subtitle: CommonUtils.getStringFromXML(name: "selected_condition_phone"), type: .error)
            return
        }
        showHideProgress(show: true)
        NetworkManager().determineMethod(contactNumber: phoneNumber) { json in
            let results = json["results"]
            let isRegistered = results["is_registered"].bool
            let userType = results["user_type"].intValue
            let sucess = json["success"].intValue
            if sucess == 1 {
                self.webserviceCallForSignin()
            } else {
                self.showHideProgress(show: false)
                if userType == 1 || userType == 0 {
                    if let isRegistered = isRegistered, isRegistered == false {
                        guard let userConfirmVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: UserRegistrationConfirmPopup.className) as? UserRegistrationConfirmPopup else {
                            return
                        }
                        userConfirmVC.mobileNumber = "+\(selectedCountry.phoneCode)\(phone)"
                        userConfirmVC.continueHandler = {
                            self.webserviceCallFoRegisteration()
                        }
                        userConfirmVC.editHandler = {
                            self.displayFieldError(isError: true)
                            self.mobileTextField.becomeFirstResponder()
                        }
                        userConfirmVC.providesPresentationContextTransitionStyle = true
                        userConfirmVC.definesPresentationContext = true
                        userConfirmVC.modalPresentationStyle = .overCurrentContext
                        self.present(userConfirmVC, animated: true, completion: nil)
                        return
                    }
                }
                let message = json["msg"].stringValue
                TSMessage.showNotification(withTitle: nil, subtitle: message, type: .error)
            }
         }
    }
    
    func webserviceCallForSignin() {
        var phone = (mobileTextField.text ?? "").convertToNumber()
        let prefix = phone.prefix(1)
        if prefix == "0" {
            phone = phone.substring(from: 1)
        }
        guard let country = UserManager.shared.country else {
            return
        }
        let phoneNumber = country.phoneCode + phone
        if !CommonUtils.validatePhone("+\(phoneNumber)") {
            TSMessage.showNotification(withTitle: nil, subtitle: CommonUtils.getStringFromXML(name: "selected_condition_phone"), type: .error)
            return
        }
        let dic = [RequestKey.contactNumber.rawValue: phoneNumber, RequestKey.deviceToken.rawValue: DELEGATE?.deviceToken ?? "", RequestKey.imei.rawValue: UserSessionManager.shared.getUUID(), RequestKey.userType.rawValue: "1", RequestKey.loginType.rawValue: "1"]
        NetworkManager().signIn(param: dic) { json in
            self.showHideProgress(show: false)
            let sucess = json["success"].intValue
            let message = json["msg"].stringValue
            if sucess == 1 {
                let results = json["results"]
                let loginSmsVerificationStatus = results["login_sms_verification_status"].intValue
                if loginSmsVerificationStatus == 0 {
                    self.presentAlertWithTitle(title: "", message: message, options: CommonUtils.getStringFromXML(name: "options_Ok")) { index in
                        return
                    }
                } else {
                    let decoder = JSONDecoder()
                    if let jsonData = try? results.rawData(),
                       let user = try? decoder.decode(User.self, from: jsonData) {
                        UserManager.shared.user = user
                        if let userid = user.userId {
                            UserSessionManager.shared.saveUserId(userid.description)
                        }
                        
                        if user.userType == 1 {
                            if let userid = user.id {
                                CommonUtils.logFacebookCustomEvents("signin", contentType: ["userid": userid.description])
                            }
                            
                            if loginSmsVerificationStatus == 2 {
                                if user.userType == UserType.customer.rawValue {
                                    guard let tabVC = UIStoryboard(storyboard: .tabBar).instantiateViewController(withIdentifier: TabViewController.className) as? TabViewController else {
                                        return
                                    }
                                    self.navigationController?.setViewControllers([tabVC], animated: true)
                                }
                            } else {
                                guard let otpVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: MobileOTPViewController.className) as? MobileOTPViewController else {
                                    return
                                }
                                let number = "+\(country.phoneCode)\(phone)"
                                otpVC.contactNumber = number
                                otpVC.isFromLogin = true
                                otpVC.isContinue = self.isContinue
                                self.navigationController?.pushViewController(otpVC, animated: true)
                            }
                        }
                    }
                }
            } else {
                TSMessage.showNotification(withTitle: nil, subtitle: message, type: .error)
            }
        }
    }
    
    func webserviceCallFoRegisteration() {
        var phone = (mobileTextField.text ?? "").convertToNumber()
        let prefix = phone.prefix(1)
        if prefix == "0" {
            phone = phone.substring(from: 1)
        }
        guard let selectedCity = selectedCity, let selectedCountry = selectedCountry, let selectedArea = selectedArea, let address = address else {
            return
        }
        let phoneNumber = "\(selectedCountry.phoneCode)\(phone)"
        let addressString = isLanguageArabic ? address.addressLineAr: address.addressLineEn

        let dic: [String: Any] = [RequestKey.usersAddress.rawValue: addressString,
                   RequestKey.contactNumber.rawValue: phoneNumber,
                   RequestKey.cityId.rawValue: selectedCity.cityId,
                   RequestKey.countryId.rawValue: selectedCountry.id,
                   RequestKey.latitude.rawValue: address.latitude,
                   RequestKey.longitude.rawValue: address.longitude,
                   RequestKey.deviceToken.rawValue: DELEGATE?.deviceToken ?? "",
                   RequestKey.imei.rawValue: UserSessionManager.shared.getUUID(),
                                  RequestKey.area.rawValue: selectedArea.areaId,
                   "source": "5"]
        self.showHideProgress(show: true)
        NetworkManager().register(param: dic) { json in
            let success = json["success"].intValue
            let results = json["results"]
            let message = json["msg"].stringValue
            switch success {
            case 1:
                self.webserviceCallForSignin()
            
            case 2:
                self.showHideProgress(show: false)
                let decoder = JSONDecoder()
                if let jsonData = try? results.rawData(),
                   let user = try? decoder.decode(User.self, from: jsonData) {
                    UserManager.shared.user = user
                    if let userid = user.id {
                        CommonUtils.logFacebookCustomEvents("registration", contentType: ["userid": userid.description])
                    }
                }
                guard let otpVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: MobileOTPViewController.className) as? MobileOTPViewController else {
                    return
                }
                otpVC.isSkip = true
                let number = "+\(selectedCountry.phoneCode)\(phone)"
                otpVC.contactNumber = number
                otpVC.isContinue = self.isContinue
                self.navigationController?.pushViewController(otpVC, animated: true)
                TSMessage.showNotification(in: DELEGATE?.window?.rootViewController, title: "", subtitle: message, type: .success)
            
            default:
                self.showHideProgress(show: false)
                TSMessage.showNotification(withTitle: nil, subtitle: message, type: .error)
            }
        }
    }
}

extension UserRegistrationViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let newPhone = textField.text {
            self.mobileTextField.text = newPhone.replacingOccurrences(of: " ", with: "")
        }
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        numberView.setBorderColor(color: UIColor(named: "008CE9"))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == mobileTextField {
            let newString = mobileTextField.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(
                separator: "")
            mobileTextField.text = newString
        }
        numberView.setBorderColor(color: UIColor(named: "E8E8E8"))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.length + range.location > (textField.text?.count ?? 0) {
            return false
        }
        if let oldString = textField.text, let countryCode = UserManager.shared.country?.phoneCode {
            let mobileText = oldString.replacingCharacters(in: Range(range, in: oldString)!,
                                                          with: string).replacingOccurrences(of: " ", with: "")
            if mobileText.count > 0 {
                var phone = mobileText.convertToNumber()
                let prefix = phone.prefix(1)
                if prefix == "0" {
                    phone = phone.substring(from: 1)
                }
                
                if countryCode == "966" || countryCode == "962" || countryCode == "593" {
                    return phone.count <= 9
                } else {
                    return phone.count <= 12
                }
            } else {
                if mobileText.count == 0 {
                    return true
                }
            }
        }
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        return newLength <= 13
    }
}
