//
//  ResetPasswordSuccessViewController.swift
//  Powerly
//
//  Created by ADMIN on 30/05/24.
//  
//
import JVFloatLabeledTextField
import UIKit

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var lblHeader: UILabel!
    var contactNumber = ""
    var isFromLogin = false
    var isFromForgotPassword = false
    @IBOutlet var btnSubmit: SpinnerButton!
    @IBOutlet weak var txtF1: MyTextField!
    @IBOutlet weak var txtF2: MyTextField!
    @IBOutlet weak var txtF3: MyTextField!
    @IBOutlet weak var txtF4: MyTextField!
    @IBOutlet var smsOTPView: UIView!
    var isSkip = false
    var isContinue = false
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var enterDegitLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var editView: UIView!
    
    var verificationCode = ""
    var bordertxt1: CALayer = CALayer()
    var bordertxt2: CALayer = CALayer()
    var bordertxt3: CALayer = CALayer()
    var bordertxt4: CALayer = CALayer()
    
    var verificationType: OTPType = .email
    var viewModel: EmailViewModel?
    @IBOutlet weak var passwordTextField: JVFloatLabeledTextField!
    @IBOutlet weak var passwordEyeButton: UIButton!
    @IBOutlet weak var confirmPasswordTextField: JVFloatLabeledTextField!
    @IBOutlet weak var confirmPassEyeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        setUI()
        loadData()
    }
    
    func initFont() {
        lblHeader.font = .robotoMedium(ofSize: 16)
        enterDegitLabel.font = .robotoRegular(ofSize: 16)
        contactNumberLabel.font = .robotoBold(ofSize: 18)
        btnSubmit.titleLabel?.font = .robotoMedium(ofSize: 16)
        editLabel.font = .robotoMedium(ofSize: 12)
    }
    
    func setUI() {
        editLabel.text = CommonUtils.getStringFromXML(name: "edit_title")
        enterDegitLabel.text = CommonUtils.getStringFromXML(name: "enter_code_sent_you")
        lblHeader.text = CommonUtils.getStringFromXML(name: "Verification_title")
        passwordTextField.placeholder = NSLocalizedString("new_password", comment: "")
        confirmPasswordTextField.placeholder = NSLocalizedString("confirm_password", comment: "")
        btnSubmit.setTitle(CommonUtils.getStringFromXML(name: "next"), for: .normal)
        
        txtF1.isUserInteractionEnabled = true
        txtF1.becomeFirstResponder()

        smsOTPView.isHidden = false
        txtF1.myDelegate = self
        txtF1.delegate = self
        txtF2.myDelegate = self
        txtF2.delegate = self
        txtF3.myDelegate = self
        txtF3.delegate = self
        txtF4.myDelegate = self
        txtF4.delegate = self
    }
    
    func loadData() {
        guard let viewModel = self.viewModel else {
            return
        }
        contactNumberLabel.text = viewModel.email ?? ""
    }
    
    @IBAction func didTapOnEditButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func manageTimeoutSeconds(seconds: Int) {
        self.txtF1.text = ""
        self.txtF2.text = ""
        self.txtF3.text = ""
        self.txtF4.text = ""
        self.txtF1.becomeFirstResponder()
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        view.endEditing(true)
        guard let email = self.viewModel?.email else {
            return
        }
        verificationCode = "\(txtF1.text!)\(txtF2.text!)\(txtF3.text!)\(txtF4.text!)"
        if verificationCode.count != 4 {
            TSMessage.showNotification(withTitle: CommonUtils.getStringFromXML(name: "enter_verification"), subtitle: nil, type: .error)
            return
        }
        if passwordTextField.text == "" {
            TSMessage.showNotification(withTitle: NSLocalizedString("Please enter password", comment: ""), subtitle: nil, type: .error)
            return
        }
        if passwordTextField.text != confirmPasswordTextField.text {
            TSMessage.showNotification(withTitle: NSLocalizedString("passwordd_confirm_password_no_match", comment: ""), subtitle: nil, type: .error)
            return
        }
        guard let viewModel = self.viewModel, let token = viewModel.verificationInfo?.verificationToken else {
            return
        }
        Task {
            self.showHideProgress(button: btnSubmit, show: true)
            let response = try? await viewModel.resetPassword(code: verificationCode, email: email, password: passwordTextField.text ?? "")
            self.showHideProgress(button: btnSubmit, show: false)
            if let response = response {
                if response.0 == 1 {
                    if let viewControllers = navigationController?.viewControllers {
                        for vc in viewControllers {
                            if let signinVC = vc as? CheckEmailAddressViewController {
                                let viewModel = EmailViewModel()
                                signinVC.viewModel = viewModel
                                navigationController?.popToViewController(signinVC, animated: true)
                                break
                            }
                        }
                    }
                    TSMessage.showNotification(in: DELEGATE?.window?.rootViewController, title: "", subtitle: response.1 ?? "", type: .success)
                } else {
                    TSMessage.showNotification(in: self, title: "", subtitle: response.1 ?? "", type: .error)
                }
            }
        }
    }
    
    func saveTokenProceedFurther(token: String, isUpdatePassword: Bool) {
        UserSessionManager.shared.saveToken(token)
        self.removeLocalNotification()
        CommonUtils.logFacebookCustomEvents("verification", contentType: ["type": "login"])
        UserManager.shared.setDefaultMethodToApplePay()
        self.showHideProgress(button: self.btnSubmit, show: true)
        Task {
            let isSuccess = try? await UserManager.webserviceCallForUserDetails()
            self.showHideProgress(button: self.btnSubmit, show: false)
            if (isSuccess ?? false) {
                self.moveUserToHomeScreen(isUpdatePassword: isUpdatePassword)
            }
        }
    }
    
    func removeLocalNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func moveUserToHomeScreen(isUpdatePassword: Bool = false) {
        if !CommonUtils.isUserLoggedIn() {
            return
        }
        guard let tabVC = UIStoryboard(storyboard: .tabBar).instantiateViewController(withIdentifier: TabViewController.className) as? TabViewController else {
            return
        }
        tabVC.isUpdatePassword = isUpdatePassword
        CommonUtils.navigationToController(controllers: [tabVC])
        self.startAnimation(isCurrentView: false)
    }
    
    @IBAction func didTapOnPasswordEyeButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func didTapOnResetPasswordEyeButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        confirmPasswordTextField.isSecureTextEntry = !sender.isSelected
    }
}

extension ResetPasswordViewController: UITextFieldDelegate, MyTextFieldDelegate {
    func textFieldDidDelete(_ txt: UITextField?) {
        if(txt == passwordTextField || txt == confirmPasswordTextField) {
            return
        }
        if (txt?.text?.count ?? 0) == 0 {
            guard let tag = txt?.tag else {
                return
            }
            switch tag {
            case 4:
                txtF3.isUserInteractionEnabled = true
                txtF3.becomeFirstResponder()
                
            case 3:
                txtF2.isUserInteractionEnabled = true
                txtF2.becomeFirstResponder()
                
            case 2:
                txtF1.isUserInteractionEnabled = true
                txtF1.becomeFirstResponder()
                
            case 1:
                txtF1.isUserInteractionEnabled = true
                txtF1.becomeFirstResponder()
                
            default:
                break
            }
        }
    }
    
    @IBAction func txtVerification(_ sender: UITextField) {
        if(sender == passwordTextField || sender == confirmPasswordTextField) {
            return
        }
        if (sender.text?.count ?? 0) >= 1 {
            sender.text = (sender.text as NSString?)?.substring(from: (sender.text?.count ?? 0) - 1)
        } else if (sender.text?.count ?? 0) == 0 {
            switch sender.tag {
            case 4:
                txtF3.isUserInteractionEnabled = true
                txtF3.becomeFirstResponder()
                
            case 3:
                txtF2.isUserInteractionEnabled = true
                txtF2.becomeFirstResponder()
                
            case 2:
                txtF1.isUserInteractionEnabled = true
                txtF1.becomeFirstResponder()
                
            case 1:
                txtF1.isUserInteractionEnabled = true
                txtF1.becomeFirstResponder()
                
            default:
                break
            }
            return
        }
        switch sender.tag {
        case 1:
            txtF2.isUserInteractionEnabled = true
            txtF2.becomeFirstResponder()
            
        case 2:
            txtF3.isUserInteractionEnabled = true
            txtF3.becomeFirstResponder()
            
        case 3:
            txtF4.isUserInteractionEnabled = true
            txtF4.becomeFirstResponder()
            
        case 4:
            txtF1.isUserInteractionEnabled = true
            txtF4.resignFirstResponder()
            
        default:
            break
        }
        
        if sender.tag == 4 {
            verificationCode = "\(txtF1.text!)\(txtF2.text!)\(txtF3.text!)\(txtF4.text!)"
            if verificationCode.count == 4 {
                passwordTextField.becomeFirstResponder()
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        changeBorderColor(textField)
        return true
    }
    
    func changeBorderColor(_ textField: UITextField?) {
        txtF1.layer.borderColor = UIColor.clear.cgColor
        txtF2.layer.borderColor = UIColor.clear.cgColor
        txtF3.layer.borderColor = UIColor.clear.cgColor
        txtF4.layer.borderColor = UIColor.clear.cgColor
        
        txtF1.backgroundColor = UIColor(named: "F3F3F3")
        txtF2.backgroundColor = UIColor(named: "F3F3F3")
        txtF3.backgroundColor = UIColor(named: "F3F3F3")
        txtF4.backgroundColor = UIColor(named: "F3F3F3")
        switch textField?.tag ?? 0 {
        case 1:
            txtF1.layer.borderColor = UIColor(named: "008CE9")?.cgColor
            txtF1.backgroundColor = UIColor.white
            
        case 2:
            txtF2.layer.borderColor = UIColor(named: "008CE9")?.cgColor
            txtF2.backgroundColor = UIColor.white
            
        case 3:
            txtF3.layer.borderColor = UIColor(named: "008CE9")?.cgColor
            txtF3.backgroundColor = UIColor.white
            
        case 4:
            txtF4.layer.borderColor = UIColor(named: "008CE9")?.cgColor
            txtF4.backgroundColor = UIColor.white
            
        default:
            break
        }
    }
}
