//
//  MobileOTPViewController.swift
//  PowerShare
//
//  Created by admin on 21/12/21.

//
import IQKeyboardManagerSwift
import UIKit

enum OTPType {
    case email
    case resetEmailPasswordVerification
}

class MobileOTPViewController: UIViewController {
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
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
    @IBOutlet weak var needHelpButton: UIButton!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var btnResendCode: UIButton!
    @IBOutlet weak var enterDegitLabel: UILabel!
    @IBOutlet weak var resendHelpStackView: UIStackView!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var editView: UIView!
    
    var verificationCode = ""
    var timerExample13: MZTimerLabel!
    var bordertxt1: CALayer = CALayer()
    var bordertxt2: CALayer = CALayer()
    var bordertxt3: CALayer = CALayer()
    var bordertxt4: CALayer = CALayer()
    
    var verificationType: OTPType = .email
    var viewModel: EmailViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        setUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // IQKeyboardManager.shared.enable = false
    }
    
    @objc func displayNeedHelperButton() {
        needHelpButton.isHidden = false
    }
    
    func initFont() {
        lblHeader.font = .robotoMedium(ofSize: 16)
        enterDegitLabel.font = .robotoRegular(ofSize: 16)
        contactNumberLabel.font = .robotoBold(ofSize: 18)
        lblTimer.font = .robotoMedium(ofSize: 14)
        btnResendCode.titleLabel?.font = .robotoMedium(ofSize: 16)
        needHelpButton.titleLabel?.font = .robotoRegular(ofSize: 14)
        btnSubmit.titleLabel?.font = .robotoMedium(ofSize: 16)
        editLabel.font = .robotoMedium(ofSize: 12)
    }
    
    
    func setUI() {
        editLabel.text = CommonUtils.getStringFromXML(name: "edit_title")
        enterDegitLabel.text = CommonUtils.getStringFromXML(name: "enter_code_sent_you")
        lblHeader.text = CommonUtils.getStringFromXML(name: "Verification_title")
        needHelpButton.setTitle(CommonUtils.getStringFromXML(name: "need_help_button"), for: .normal)
        btnSubmit.setTitle(CommonUtils.getStringFromXML(name: "next"), for: .normal)
        
        let commentString = NSMutableAttributedString()
            .underlined(CommonUtils.getStringFromXML(name: "resend_code"))
        btnResendCode.setAttributedTitle(commentString, for: .normal)
        btnResendCode.isHidden = true
        
        txtF1.isUserInteractionEnabled = true
        txtF1.becomeFirstResponder()

        timerExample13 = MZTimerLabel(label: lblTimer, andTimerType: MZTimerLabelTypeTimer)
        let seconds:Int
        switch verificationType {
        case .email:
            if let viewModel = self.viewModel?.verificationInfo {
                seconds = viewModel.canResendInSeconds
            } else {
                seconds = 60
            }
        default:
            seconds = 0
            break
        }
        timerExample13.setCountDownTime(Double(seconds))
        let text = CommonUtils.getStringFromXML(name: "resend_code")
        let timestring = "\(seconds)"
        let textwithtime = "\(text) \(timestring)"
        let rrr = (textwithtime as NSString).range(of: timestring)
        lblTimer.isHidden = true
        timerExample13.isHidden = true
        btnResendCode.isHidden = true
        timerExample13.text = textwithtime
        timerExample13.textRange = rrr
        timerExample13.timeFormat = "mm:ss"
        timerExample13.resetTimerAfterFinish = true
        lblTimer.isHidden = false
        timerExample13.isHidden = false
        btnResendCode.isHidden = true
        timerExample13.start() { [self] countTime in
            lblTimer.isHidden = true
            timerExample13.isHidden = true
            btnResendCode.isHidden = false
        }
        
        smsOTPView.isHidden = false
        txtF1.myDelegate = self
        txtF1.delegate = self
        txtF2.myDelegate = self
        txtF2.delegate = self
        txtF3.myDelegate = self
        txtF3.delegate = self
        txtF4.myDelegate = self
        txtF4.delegate = self
        
        needHelpButton.isHidden = true
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(displayNeedHelperButton), userInfo: nil, repeats: false)
    }
    
    func loadData() {
        switch verificationType {
        case .email:
            guard let viewModel = self.viewModel else {
                return
            }
            contactNumberLabel.text = viewModel.email ?? ""
        default: break
        }
    }
    
    @IBAction func didTapOnEditButton(_ sender: Any) {
        if verificationType == .email {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func didTap(onNeedHelpButton sender: Any) {
        if let contactNumber = UserManager.shared.country?.contactNumber , contactNumber != "" {
            let phoneNumber = "telprompt://" + contactNumber
            if let url = URL(string: phoneNumber) {
                UIApplication.shared.open(url, options: [:]) { _ in
                    
                }
            }
        }
    }
    
    @IBAction func btnActionResendCode(_ sender: Any) {
        switch verificationType {
        case .email:
            guard let viewModel = viewModel, let email = viewModel.email else {
                return
            }
            Task {
                if let response = try? await viewModel.resendEmailVerification(email: email) {
                    if response.0 == 1 {
                        if let verification = response.2 {
                            self.viewModel?.verificationInfo = verification
                            let time = verification.canResendInSeconds
                            self.manageTimeoutSeconds(seconds: time)
                        }
                    } else {
                        TSMessage.showNotification(in: self, title: "", subtitle: response.1 ?? "", type: .error)
                    }
                }
            }
            
        default: break
        }
    }
    
    func manageTimeoutSeconds(seconds: Int) {
        self.lblTimer.isHidden = false
        self.timerExample13.isHidden = false
        self.btnResendCode.isHidden = true
       
        self.timerExample13.setCountDownTime(Double(seconds))
        self.timerExample13.start { _ in
            self.lblTimer.isHidden = true
            self.timerExample13.isHidden = true
            self.btnResendCode.isHidden = false
        }
        self.txtF1.text = ""
        self.txtF2.text = ""
        self.txtF3.text = ""
        self.txtF4.text = ""
        self.txtF1.becomeFirstResponder()
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        view.endEditing(true)
        verificationCode = "\(txtF1.text!)\(txtF2.text!)\(txtF3.text!)\(txtF4.text!)"
        if verificationCode.count != 4 {
            TSMessage.showNotification(withTitle: CommonUtils.getStringFromXML(name: "enter_verification"), subtitle: nil, type: .error)
            return
        }
        switch verificationType {
            case .email:
                guard let viewModel = self.viewModel, let email = viewModel.email else {
                    return
                }
                Task {
                    self.showHideProgress(button: btnSubmit, show: true)
                    let response = try? await viewModel.verifyEmail(email: email, code: verificationCode)
                    self.showHideProgress(button: btnSubmit, show: false)
                    if let response = response {
                        if response.0 == 1, let customer = response.2 {
                            UserSessionManager.shared.saveUserId(customer.id.description)
                            self.saveTokenProceedFurther(token: customer.accessToken, isUpdatePassword: false)
                        } else {
                            TSMessage.showNotification(in: self, title: "", subtitle: response.1 ?? "", type: .error)
                        }
                    }
                }
            
            default: break
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
}

extension MobileOTPViewController: UITextFieldDelegate, MyTextFieldDelegate {
    func textFieldDidDelete(_ txt: UITextField?) {
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
                self.btnSubmitAction(self)
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
