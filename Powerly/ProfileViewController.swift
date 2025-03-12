//
//  ProfileViewController.swift
//  PowerShare
//
//  Created by admin on 21/10/21.

//
import IQKeyboardManagerSwift
import JVFloatLabeledTextField
import SDWebImage
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var myProfileView: UIView!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var vatIdView: UIView!
    @IBOutlet weak var imageProfileView: UIImageView!
    @IBOutlet weak var myProfileLabel: UILabel!
    @IBOutlet weak var nameTextField: JVFloatLabeledTextField!
    @IBOutlet weak var lastNameTextField: JVFloatLabeledTextField!
    @IBOutlet weak var emailTextField: JVFloatLabeledTextField!
    @IBOutlet var vatIdTextField: JVFloatLabeledTextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: JVFloatLabeledTextField!
    @IBOutlet weak var phoneNumberTextField: JVFloatLabeledTextField!
    @IBOutlet weak var saveButton: SpinnerButton!
    @objc var isUpdate = false
    @IBOutlet weak var lockPhoneRightImageView: UIImageView!
    @IBOutlet weak var lockPhoneLeftImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryEditIcon: UIImageView!
    @IBOutlet weak var countryEditButton: UIButton!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var currencyView: UIView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var eyePasswordRightButton: UIButton!
    @IBOutlet weak var eyePasswordLeftButton: UIButton!
    var isResetPassword = false
    
    var selectedCountry: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        setUpUI()
        CommonUtils.logFacebookCustomEvents("profile_open", contentType: [:])
    }
    
    func initFont() {
        myProfileLabel.font = .robotoMedium(ofSize: 16)
        nameTextField.font = .robotoMedium(ofSize: 16)
        lastNameTextField.font = .robotoMedium(ofSize: 16)
        emailTextField.font = .robotoMedium(ofSize: 16)
        passwordTextField.font = .robotoMedium(ofSize: 16)
        vatIdTextField.font = .robotoMedium(ofSize: 16)
        phoneNumberTextField.font = .robotoMedium(ofSize: 16)
        saveButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        signoutButton.titleLabel?.font = .robotoMedium(ofSize: 14)
        countryNameLabel.font = .robotoRegular(ofSize: 14)
    }
    
    func setUpUI() {
        guard let user = UserManager.shared.user else {
            return
        }
        if isLanguageArabic {
            lastNameTextField.textAlignment = .right
            nameTextField.textAlignment = .right
            emailTextField.textAlignment = .right
            vatIdTextField.textAlignment = .right
            passwordTextField.textAlignment = .right
            phoneNumberTextField.textAlignment = .right
            lockPhoneRightImageView.isHidden = true
            lockPhoneLeftImageView.isHidden = false
            eyePasswordRightButton.isHidden = true
            eyePasswordLeftButton.isHidden = false
            eyePasswordLeftButton.isSelected = false
        } else {
            lastNameTextField.textAlignment = .left
            nameTextField.textAlignment = .left
            emailTextField.textAlignment = .left
            vatIdTextField.textAlignment = .left
            passwordTextField.textAlignment = .left
            phoneNumberTextField.textAlignment = .left
            lockPhoneRightImageView.isHidden = false
            lockPhoneLeftImageView.isHidden = true
            eyePasswordRightButton.isHidden = false
            eyePasswordLeftButton.isHidden = true
            eyePasswordRightButton.isSelected = false
        }
        
        phoneNumberTextField.text = user.contactNumber
        nameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        if let country = UserManager.shared.countryList.first(where: {$0.id == user.countryId}) {
            countryNameLabel.text = country.name
        } else {
            countryNameLabel.text = NSLocalizedString("Select country", comment: "")
        }
        
        nameTextField.placeholder = CommonUtils.getStringFromXML(name: "first_name_title")
        lastNameTextField.placeholder = CommonUtils.getStringFromXML(name: "last_name_title")
        emailTextField.placeholder = CommonUtils.getStringFromXML(name: "email_title")
        vatIdTextField.placeholder = CommonUtils.getStringFromXML(name: "vatId_title")
        passwordTextField.placeholder = CommonUtils.getStringFromXML(name: "password_title")
        myProfileLabel.text = CommonUtils.getStringFromXML(name: "myProfile_title")
        phoneNumberTextField.placeholder = CommonUtils.getStringFromXML(name: "regis_phone")
        saveButton.setTitle(CommonUtils.getStringFromXML(name: "save"), for: .normal)
        signoutButton.setTitle(CommonUtils.getStringFromXML(name: "logout"), for: .normal)
        
        nameTextField.floatingLabelActiveTextColor = UIColor.gray
        lastNameTextField.floatingLabelActiveTextColor = UIColor.gray
        emailTextField.floatingLabelActiveTextColor = UIColor.gray
        vatIdTextField.floatingLabelActiveTextColor = UIColor.gray
        passwordTextField.floatingLabelActiveTextColor = UIColor.gray
        phoneNumberTextField.floatingLabelActiveTextColor = UIColor.gray
        
        if user.contactNumber == "" {
            phoneNumberTextField.isUserInteractionEnabled = true
            lockPhoneRightImageView.isHidden = true
            lockPhoneLeftImageView.isHidden = true
        } else {
            phoneNumberTextField.isUserInteractionEnabled = false
        }
        phoneNumberView.isHidden = true
        
        if user.countryId == nil {
            countryEditIcon.isHidden = false
            countryEditButton.isUserInteractionEnabled = true
        } else {
            countryEditIcon.isHidden = true
            countryEditButton.isUserInteractionEnabled = false
        }
        
        if let email = UserManager.shared.user?.email {
            emailTextField.text = email
        }
        
        if let vatId = UserManager.shared.user?.vatId {
            vatIdTextField.text = vatId
        }
        
        self.imageProfileView.image = UIImage(systemName: "bolt.circle")
        
        self.imageProfileView.setCornerRadius(radius: self.imageProfileView.frame.size.width/2)
        if isResetPassword {
            self.passwordTextField.becomeFirstResponder()
        }
        currencyLabel.text = CommonUtils.getCurrency()
    }
    
    @IBAction func didTapOnSaveButton (sender: Any) {
        self.view.endEditing(true)
        if !CommonUtils.isUserLoggedIn() {
            return
        }
        var updateProfile = UpdateProfile()
        if nameTextField.text != "" {
            updateProfile.firstName = nameTextField.text
        } else {
            TSMessage.showNotification(in: self, title: nil, subtitle: CommonUtils.getStringFromXML(name: "enteryourfirstname"), type: .error, duration: 5)
            return
        }
        
        if lastNameTextField.text != "" {
            updateProfile.lastName = lastNameTextField.text
        } else {
            TSMessage.showNotification(in: self, title: nil, subtitle: CommonUtils.getStringFromXML(name: "enteryourlastname"), type: .error, duration: 5)
            return
        }
        
        updateProfile.vatId = vatIdTextField.text
        if passwordTextField.text != "" {
            updateProfile.password = passwordTextField.text
        }
        if let countryId = self.selectedCountry?.id {
            updateProfile.countryId = countryId
        }
        showHideProgress(button: saveButton, show: true)
        NetworkManager().updateProfile(updateProfile: updateProfile) { response in
            self.showHideProgress(button: self.saveButton, show: false)
            if response.success == 1 {
                self.startAnimation(isCurrentView: true)
                UserManager.shared.user?.firstName = self.nameTextField.text ?? ""
                UserManager.shared.user?.email = self.emailTextField.text ?? ""
                UserManager.shared.user?.vatId = self.vatIdTextField.text ?? ""
                if self.isUpdate {
                    self.dismiss(animated: true)
                }
                if let userId = UserManager.shared.user?.id {
                    CommonUtils.logFacebookCustomEvents("Save_Profile", contentType: ["userid": userId.description, "device": "iOS"])
                }
                if let selectedCountry = self.selectedCountry {
                    UserManager.shared.country = selectedCountry
                }
            } else {
                TSMessage.showNotification(in: self, title: nil, subtitle: response.message, type: .error, duration: 5)
            }
        }
    }
    
    @IBAction func didTapOnBackButton(sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func didTapOnSignoutButton(_ sender: Any) {
        self.showDialogue(title: CommonUtils.getStringFromXML(name: "logout_title"), description: CommonUtils.getStringFromXML(name: "sure_logout")) { success in
            if success {
                self.webserviceCallForLogout()
                let defaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
                for key in defaultsDictionary.keys {
                    UserDefaults.standard.removeObject(forKey: key)
                }
                UserManager.shared.clearObjectToLocal()
                UserSessionManager.shared.clearSession()
                if let splashViewController = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: SplashViewController.className) as? SplashViewController, let navVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: AppNavigationController.className) as? AppNavigationController {
                    navVC.setNavigationBarHidden(true, animated: true)
                    navVC.viewControllers = [splashViewController]
                    DELEGATE?.window?.rootViewController = navVC
                }
            }
        }
    }
    
    @IBAction func didTapOnDeleteButton(_ sender: UIButton) {
        let list = [CommonUtils.getStringFromXML(name: "delete_account")]
        let point = sender.convert(CGPoint.zero, to: self.view)
        guard let serviceVC = UIStoryboard(storyboard: .common).instantiateViewController(withIdentifier: DropDownListViewController.className) as? DropDownListViewController else {
            return
        }
        serviceVC.modalPresentationStyle = .overCurrentContext
        serviceVC.yValue = point.y
        serviceVC.popUpRect = CGRect(x: point.x, y: point.y, width: self.view.frame.width-32, height: 50)
        serviceVC.list = list
        serviceVC.completionSelectedIndex = {[weak self] _ in
            self?.showDialogue(title: "", description: CommonUtils.getStringFromXML(name: "are_you_sure_delete_account") + "\n\n" + CommonUtils.getStringFromXML(name: "delete_account_description")) { success in
                if success {
                    guard let userId = UserSessionManager.shared.getUserId() else {
                        return
                    }
                    NetworkManager().deleteUser(id: userId) { _, _ in
                        self?.webserviceCallForLogout()
                        let defaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
                        for key in defaultsDictionary.keys {
                            UserDefaults.standard.removeObject(forKey: key)
                        }
                        UserManager.shared.clearObjectToLocal()
                        UserSessionManager.shared.clearSession()
                        if let splashViewController = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: SplashViewController.className) as? SplashViewController, let navVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: AppNavigationController.className) as? AppNavigationController {
                            navVC.setNavigationBarHidden(true, animated: true)
                            navVC.viewControllers = [splashViewController]
                            DELEGATE?.window?.rootViewController = navVC
                        }
                    }
                }
            }
        }
        self.present(serviceVC, animated: false)
    }
    
    @IBAction func didTapOnPrefferedDriverButton(_ sender: Any) {
    }
    
    @IBAction func didTapOnCountryButton(_ sender: Any) {
        guard let countryPickVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: SelectCountryViewController.className) as? SelectCountryViewController else {
            return
        }
        countryPickVC.completionSelectedLanguage = { country in
            self.selectedCountry = country
            self.countryNameLabel.text = country.name
        }
        self.present(countryPickVC, animated: true) {
        }
    }
    
    @IBAction func didTapOnCurrencyButton(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: self.view)
        guard let dropVC = UIStoryboard(storyboard: .common).instantiateViewController(withIdentifier: CurrencyListViewController.className) as? CurrencyListViewController else {
            return
        }
        dropVC.modalPresentationStyle = .overCurrentContext
        dropVC.yValue = point.y
        dropVC.popUpRect = CGRect(x: point.x, y: point.y, width: self.view.frame.width-32, height: CGFloat(250))
        dropVC.completionSelectedIndex = { [weak self] currency in
            Task {
                self?.currencyLabel.text = currency.currencyIso
                var updateProfile = UpdateProfile()
                updateProfile.currency = currency.currencyIso
                CommonUtils.showProgressHud()
                let response = try? await NetworkManager().updateProfile(updateProfile: updateProfile)
                CommonUtils.hideProgressHud()
                if response?.success == 1 {
                    self?.startAnimation(isCurrentView: true)
                    userDefault.setValue(currency.currencyIso, forKey: UserDefaultKey.kSavedCurrency.rawValue)
                    userDefault.synchronize()
                }
            }
        }
        self.present(dropVC, animated: false)
    }
    
    func webserviceCallForLogout() {
        let uuid = UserSessionManager.shared.getUUID()
        guard let userId = UserManager.shared.user?.id else {
            return
        }
        CommonUtils.logFacebookCustomEvents("Logout", contentType: [
            "userid": userId.description,
            "device": "iOS"
        ])
        var dict = [
            "device_imei": uuid,
            "device_type": "2",
            "user_id": userId.description
        ]
        if let userType = UserManager.shared.user?.userType {
            dict["user_type"] = userType.description
        }
        NetworkManager().logout(params: dict) { _, _, _ in
        }
    }
    
    @IBAction func didTapOnEyeButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = !sender.isSelected
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            firstNameView.setBorderColor(color: UIColor(named: "008CE9"))
            
        case lastNameTextField:
            lastNameView.setBorderColor(color: UIColor(named: "008CE9"))
            
        case emailTextField:
            emailView.setBorderColor(color: UIColor(named: "008CE9"))
            
        case vatIdTextField:
            vatIdView.setBorderColor(color: UIColor(named: "008CE9"))
            
        case passwordTextField:
            passwordView.setBorderColor(color: UIColor(named: "008CE9"))
            
        default:
            firstNameView.setBorderColor(color: UIColor(named: "E8E8E8"))
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            firstNameView.setBorderColor(color: UIColor(named: "E8E8E8"))
            
        case lastNameTextField:
            lastNameView.setBorderColor(color: UIColor(named: "E8E8E8"))
            
        case emailTextField:
            emailView.setBorderColor(color: UIColor(named: "E8E8E8"))
            
        case vatIdTextField:
            vatIdView.setBorderColor(color: UIColor(named: "E8E8E8"))
            
        case passwordTextField:
            passwordView.setBorderColor(color: UIColor(named: "E8E8E8"))
            
        default:
            firstNameView.setBorderColor(color: UIColor(named: "E8E8E8"))
        }
    }
}
