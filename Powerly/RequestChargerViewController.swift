//
//  RequestChargerViewController.swift
//  PowerShare
//
//  Created by ADMIN on 08/08/23.
//  
//

import UIKit

class RequestChargerViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var fillOutNoteLabel: UILabel!
    @IBOutlet weak var selectLocationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTypeTitleLabel: UILabel!
    @IBOutlet weak var addressTypeLabel: UILabel!
    @IBOutlet weak var addressNoteLabel: UILabel!
    @IBOutlet weak var yesView: UIView!
    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noView: UIView!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var continueLabel: UILabel!
    @IBOutlet weak var selectLocationView: UIView!
    @IBOutlet weak var addressTypeView: UIView!
    
    @IBOutlet weak var countryDropDownArrowImageView: UIImageView!
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var continueButton: UIView!
    
    var selectedCountry: Country? = UserManager.shared.country
    var requestAddress = RequestAddress()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        self.didTapOnYesButton(self)
        self.mobileTextField.delegate = self
        self.setupCountry()
        continueButtonValidation()
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 18)
        fillOutNoteLabel.font = .robotoRegular(ofSize: 16)
        selectLocationLabel.font = .robotoRegular(ofSize: 14)
        addressLabel.font = .robotoRegular(ofSize: 14)
        addressTypeLabel.font = .robotoRegular(ofSize: 14)
        addressTypeTitleLabel.font = .robotoRegular(ofSize: 14)
        addressNoteLabel.font = .robotoMedium(ofSize: 16)
        yesLabel.font = .robotoMedium(ofSize: 14)
        noLabel.font = .robotoMedium(ofSize: 14)
        mobileTextField.font = .robotoRegular(ofSize: 16)
        continueLabel.font = .robotoMedium(ofSize: 16)
    }
    
    func initUI() {
        if isLanguageArabic {
            mobileTextField.textAlignment = .left
            fillOutNoteLabel.textAlignment = .right
            selectLocationLabel.textAlignment = .right
            addressLabel.textAlignment = .right
            addressTypeLabel.textAlignment = .right
            addressTypeTitleLabel.textAlignment = .right
            addressNoteLabel.textAlignment = .right
//            numberView.semanticContentAttribute = .forceRightToLeft
            selectLocationView.semanticContentAttribute = .forceRightToLeft
            addressTypeView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func setupCountry() {
        mobileTextField.placeholder = CommonUtils.getStringFromXML(name: "enter_mobile_number")
        if self.selectedCountry == nil {
            if let countryId = UserManager.shared.country?.id {
                self.selectedCountry = UserManager.shared.countryList.first(where: { $0.id == countryId })
            }
        }
        guard let country = self.selectedCountry else {
            return
        }
        
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
        let imagePath = "CountryPicker.bundle/\(String(describing: country.iso))"
        self.countryFlagImageView.image = UIImage(named: imagePath)
    }

    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnYesButton(_ sender: Any) {
        yesButton.isSelected = true
        noButton.isSelected = false
        numberView.isHidden = true
        
        yesView.borderColor = UIColor(named: "008CE9")
        noView.borderColor = UIColor(named: "BEBEBE")
        self.requestAddress.ownedAddress = 1
        continueButtonValidation()
    }
    
    @IBAction func didTapOnNoButton(_ sender: Any) {
        yesButton.isSelected = false
        noButton.isSelected = true
        numberView.isHidden = false
        
        noView.borderColor = UIColor(named: "008CE9")
        yesView.borderColor = UIColor(named: "BEBEBE")
        self.requestAddress.ownedAddress = 0
        continueButtonValidation()
    }
    
    @IBAction func didTapOnCountryPickButton(_ sender: Any) {
        guard let countryPickVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: SelectCountryViewController.className) as? SelectCountryViewController else {
            return
        }
        if let selectedCountry = selectedCountry, let index = UserManager.shared.countryList.firstIndex(where: { $0.id == selectedCountry.id }) {
            countryPickVC.selectedIndex = index
        }
        countryPickVC.completionSelectedLanguage = { country in
            self.selectedCountry = country
            self.setupCountry()
        }
        self.present(countryPickVC, animated: true) {
        }
    }
    
    func displayFieldError(isError: Bool) {
        if isError {
            numberView.setBorderColor(color: UIColor(named: "CANCEL_TEXT"))
        } else {
            numberView.setBorderColor(color: UIColor(named: "222222"))
        }
    }
    
    func continueButtonValidation() {
        guard requestAddress.address != "", requestAddress.addressType != ""  else {
            continueButton.backgroundColor = UIColor(named: "7A7A7A")
            return
        }
        if requestAddress.ownedAddress == 0 {
            if (mobileTextField.text?.count ?? 0) <= 6 || (mobileTextField.text?.count ?? 0) >= 15 {
                continueButton.backgroundColor = UIColor(named: "7A7A7A")
                return
            } else {
                guard selectedCountry != nil else {
                    continueButton.backgroundColor = UIColor(named: "7A7A7A")
                    return
                }
            }
        }
        continueButton.backgroundColor = UIColor(named: "222222")
    }
     
    @IBAction func didTapOnContinueButton(_ sender: Any) {
        guard requestAddress.address != "", requestAddress.addressType != "" else {
            return
        }
        if requestAddress.ownedAddress == 0 {
            mobileTextField.text = mobileTextField.text?.replacingOccurrences(of: "  ", with: " ")
            if (mobileTextField.text?.count ?? 0) <= 6 || (mobileTextField.text?.count ?? 0) >= 15 {
                self.displayFieldError(isError: true)
                return
            } else {
                self.displayFieldError(isError: false)
                var phone = (mobileTextField.text ?? "").convertToNumber()
                let prefix = phone.prefix(1)
                if prefix == "0" {
                    phone = phone.substring(from: 1)
                }
                guard let selectedCountry = selectedCountry else {
                    return
                }
                let phoneNumber = "\(selectedCountry.phoneCode)\(phone)"
                requestAddress.contactNumber = phoneNumber
            }
            
            if requestAddress.contactNumber == "" {
                return
            }
        }
        CommonUtils.showProgressHud()
        NetworkManager().addRequestPowerSource(requestPowerSource: self.requestAddress) { success, message, _ in
            CommonUtils.hideProgressHud()
            if success == 1 {
                self.startAnimation(isCurrentView: false)
                self.dismiss(animated: true) {
                }
            } else {
                TSMessage.showNotification(in: self, title: "", subtitle: message, type: .error)
            }
        }
    }
    
    @IBAction func didTapOnSelectLocationButton(_ sender: Any) {
        guard let addMapVC = UIStoryboard(storyboard: .request).instantiateViewController(withIdentifier: SelectAddressViewController.className) as? SelectAddressViewController else {
            return
        }
        addMapVC.modalPresentationStyle = .overFullScreen
        addMapVC.requestedAddress = self.requestAddress
        addMapVC.completionSaveNext = { requestAddress in
            self.requestAddress = requestAddress
            self.addressLabel.text = self.requestAddress.address
            self.continueButtonValidation()
        }
        self.present(addMapVC, animated: true)
    }
    
    @IBAction func didTapOnSelectAddressTypeButton(_ sender: UIButton) {
        let list = [NSLocalizedString("Parking Area", comment: ""),
                    NSLocalizedString("Shopping Mall", comment: ""),
                    NSLocalizedString("Park", comment: ""),
                    NSLocalizedString("Restaurant", comment: ""),
                    NSLocalizedString("Apartment", comment: ""),
                    NSLocalizedString("Other", comment: "")]
        let point = sender.convert(CGPoint.zero, to: self.view)
        guard let dropVC = UIStoryboard(storyboard: .common).instantiateViewController(withIdentifier: DropDownListViewController.className) as? DropDownListViewController else {
            return
        }
        dropVC.modalPresentationStyle = .overCurrentContext
        dropVC.yValue = point.y
        dropVC.popUpRect = CGRect(x: point.x, y: point.y, width: self.view.frame.width-32, height: CGFloat(50*list.count))
        dropVC.list = list
        dropVC.completionSelectedIndex = { index in
            if let value = list.value(at: index) {
                self.requestAddress.addressType = value
                self.addressTypeLabel.text = value
                self.continueButtonValidation()
            }
        }
        self.present(dropVC, animated: false)
    }
}

extension RequestChargerViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        continueButtonValidation()
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
