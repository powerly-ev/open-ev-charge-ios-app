//
//  RegisterEmailPasswordViewController.swift
//  Powerly
//
//  Created by ADMIN on 15/05/24.
//  
//
import JVFloatLabeledTextField
import UIKit

class RegisterEmailPasswordViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var createPasswordLabel: UILabel!
    @IBOutlet weak var passwordDescriptionLabel: UILabel!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: JVFloatLabeledTextField!
    @IBOutlet weak var passwordEyeButton: UIButton!
    @IBOutlet weak var strengthOneView: UIView!
    @IBOutlet weak var strengthTwoView: UIView!
    @IBOutlet weak var strengthThreeView: UIView!
    @IBOutlet weak var strengthLabel: UILabel!
    @IBOutlet weak var createAccountButton: SpinnerButton!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var outView: UIView!
    
    var viewModel = EmailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initData()
        initUI()
    }
    
    private func initData() {
        passwordTextField.becomeFirstResponder()
        if let country = viewModel.getCountry() {
            countryLabel.text = country.name
        } else {
            countryLabel.text = NSLocalizedString("Select country", comment: "")
        }
    }
    
    private func initUI() {
        if isLanguageArabic {
            outView.semanticContentAttribute = .forceRightToLeft
            createPasswordLabel.textAlignment = .right
            passwordDescriptionLabel.textAlignment = .right
            passwordTextField.textAlignment = .right
            passwordView.semanticContentAttribute = .forceRightToLeft
        }
        passwordEyeButton.isSelected = false
    }
    
    private func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 18)
        createPasswordLabel.font = .robotoBold(ofSize: 20)
        passwordDescriptionLabel.font = .robotoRegular(ofSize: 16)
        passwordTextField.font = .robotoMedium(ofSize: 16)
        strengthLabel.font = .robotoRegular(ofSize: 14)
        createAccountButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        countryLabel.font = .robotoRegular(ofSize: 14)
    }
    
    func showError(error: String) {
        TSMessage.showNotification(in: self, title: "", subtitle: error, type: .error)
    }
    
    @IBAction func didTapOnPasswordEyeButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func didTapOnCreateAccountButton(_ sender: Any) {
        guard let password = passwordTextField.text else {// , let confirmPassword = confirmPasswordTextField.text
            self.showError(error: NSLocalizedString("Please enter passwrod", comment: ""))
            return
        }
        // TODO: handle error
        if password.count < 8 {
            self.showError(error: NSLocalizedString("The password must be at least 8 characters.", comment: ""))
            return
        }
        guard let email = viewModel.email else {
            return
        }
        guard let country = viewModel.getCountry()  else {
            TSMessage.showNotification(in: self, title: "", subtitle: "Please select country", type: .error)
            return
        }
        let register = RegisterEmail(email: email, password: password, countryId: country.id, deviceImei: UserSessionManager.shared.getUUID(), deviceToken: DELEGATE?.deviceToken ?? "")
        Task {
            showHideProgress(button: createAccountButton, show: true)
            let response = try? await self.viewModel.registerByEmail(register: register)
            showHideProgress(button: createAccountButton, show: false)
            if let response = response {
                if response.0 == 1 {
                    self.viewModel.verificationInfo = response.2
                    guard let otpVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: MobileOTPViewController.className) as? MobileOTPViewController else {
                        return
                    }
                    otpVC.viewModel = self.viewModel
                    otpVC.verificationType = .email
                    self.navigationController?.pushViewController(otpVC, animated: true)
                } else {
                    TSMessage.showNotification(in: self, title: "", subtitle: response.1, type: .error)
                }
            }
        }
    }
    
    @IBAction func didTapOnBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnCountryButton(_ sender: Any) {
        guard let countryPickVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: SelectCountryViewController.className) as? SelectCountryViewController else {
            return
        }
        countryPickVC.completionSelectedLanguage = { country in
            UserManager.shared.country = country
            self.countryLabel.text = country.name
        }
        self.present(countryPickVC, animated: true) {
        }
    }
}

extension RegisterEmailPasswordViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
            case passwordTextField:
                passwordView.setBorderColor(color: UIColor(named: "222222"))
//            case confirmPasswordTextField:
//                confirmPasswordView.setBorderColor(color: UIColor(named: "222222"))
            default:
                passwordView.setBorderColor(color: UIColor(named: "E8E8E8"))
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
            case passwordTextField:
                passwordView.setBorderColor(color: UIColor(named: "E8E8E8"))
//            case confirmPasswordTextField:
//                confirmPasswordView.setBorderColor(color: UIColor(named: "E8E8E8"))
            default:
                passwordView.setBorderColor(color: UIColor(named: "E8E8E8"))
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if confirmPasswordTextField == textField {
//            if !errorConfimLabel.isHidden {
//                errorConfimLabel.isHidden = true
//                confirmPasswordView.setBorderColor(color: UIColor(named: "222222"))
//                passwordView.setBorderColor(color: UIColor(named: "222222"))
//            }
//            return true
//        }
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if newText.count == 0 {
            strengthOneView.backgroundColor = UIColor(named: "E8E8E8")
            strengthTwoView.backgroundColor = UIColor(named: "E8E8E8")
            strengthThreeView.backgroundColor = UIColor(named: "E8E8E8")
            strengthLabel.text = ""
            return true
        }
        let strength = checkPasswordStrength(password: newText)
        switch strength {
            case .weak:
                strengthOneView.backgroundColor = UIColor(named: "008CE9")
                strengthTwoView.backgroundColor = UIColor(named: "E8E8E8")
                strengthThreeView.backgroundColor = UIColor(named: "E8E8E8")
                strengthLabel.text = NSLocalizedString("Weak", comment: "")
                break
            case .medium:
                strengthOneView.backgroundColor = UIColor(named: "008CE9")
                strengthTwoView.backgroundColor = UIColor(named: "008CE9")
                strengthThreeView.backgroundColor = UIColor(named: "E8E8E8")
                strengthLabel.text = NSLocalizedString("Medium", comment: "")
                break
            case .strong:
                strengthOneView.backgroundColor = UIColor(named: "008CE9")
                strengthTwoView.backgroundColor = UIColor(named: "008CE9")
                strengthThreeView.backgroundColor = UIColor(named: "008CE9")
                strengthLabel.text = NSLocalizedString("Strong", comment: "")
                break
        }
        return true
    }
    
    func checkPasswordStrength(password: String) -> PasswordStrength {
        // Criteria for password strength
        let minLength = 8
        let mediumLength = 12
        
        // Regular expressions for various character sets
        let uppercaseRegex = ".*[A-Z]+.*"
        let lowercaseRegex = ".*[a-z]+.*"
        let numberRegex = ".*[0-9]+.*"
        let specialCharRegex = ".*[!@#$%^&*(),.?\":{}|<>]+.*"
        
        // Evaluate password
        let lengthScore = password.count >= minLength ? 1 : 0
        let mediumLengthScore = password.count >= mediumLength ? 1 : 0
        let uppercaseScore = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password) ? 1 : 0
        let lowercaseScore = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: password) ? 1 : 0
        let numberScore = NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: password) ? 1 : 0
        let specialCharScore = NSPredicate(format: "SELF MATCHES %@", specialCharRegex).evaluate(with: password) ? 1 : 0
        
        let score = lengthScore + mediumLengthScore + uppercaseScore + lowercaseScore + numberScore + specialCharScore
        
        // Determine password strength based on score
        switch score {
        case 0...2:
            return .weak
        case 3...4:
            return .medium
        case 5...6:
            return .strong
        default:
            return .weak
        }
    }
}


enum PasswordStrength {
    case weak
    case medium
    case strong
}
