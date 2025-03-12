//
//  SignInEmailPasswordViewController.swift
//  Powerly
//
//  Created by ADMIN on 15/05/24.
//  
//

import JVFloatLabeledTextField
import UIKit

class SignInEmailPasswordViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var enterPasswordLabel: UILabel!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: JVFloatLabeledTextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var signinButton: SpinnerButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    var viewModel: EmailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        setupData()
    }
    
    private func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 18)
        enterPasswordLabel.font = .robotoBold(ofSize: 20)
        passwordTextField.font = .robotoMedium(ofSize: 16)
        signinButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        forgotPasswordButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        passwordErrorLabel.font = .robotoRegular(ofSize: 14)
    }
    
    private func initUI() {
        if isLanguageArabic {
            enterPasswordLabel.textAlignment = .right
            passwordView.semanticContentAttribute = .forceRightToLeft
            passwordTextField.textAlignment = .right
        }
        eyeButton.isSelected = false
    }
    
    private func setupData() {
        passwordTextField.becomeFirstResponder()
        guard let viewModel = self.viewModel, let email = viewModel.email else {
            return
        }
        headerLabel.text = email
    }
   
    @IBAction func didTapOnBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnEyeButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func didTapOnSigninButton(_ sender: Any) {
        passwordTextField.resignFirstResponder()
        guard let password = passwordTextField.text else {
            return
        }
        if password == "" {
            self.showError(showError: true, error: NSLocalizedString("Please enter password", comment: ""))
            return
        }
        if password.count < 8 {
            self.showError(showError: true, error: NSLocalizedString("The password must be at least 8 characters.", comment: ""))
            return
        }
        guard let email = viewModel?.email else {
            return
        }
        self.showHideProgress(button: signinButton, show: true)
        viewModel?.loginByEmail(email: email, password: password, completion: { success, message, customer, verification in
            self.showHideProgress(button: self.signinButton, show: false)
            if success == 1 {
                if let customer = customer {
                    UserSessionManager.shared.saveUserId(customer.id.description)
                    Task {
                        await self.saveTokenProceedFurther(token: customer.accessToken)
                    }
                } else if let verificationInfo = verification {
                    self.viewModel?.verificationInfo = verificationInfo
                    guard let otpVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: MobileOTPViewController.className) as? MobileOTPViewController else {
                        return
                    }
                    otpVC.viewModel = self.viewModel
                    otpVC.verificationType = .email
                    self.navigationController?.pushViewController(otpVC, animated: true)
                }
            } else {
                TSMessage.showNotification(in: self, title: "", subtitle: message, type: .error)
            }
        })
    }
    
    func saveTokenProceedFurther(token: String) async {
        UserSessionManager.shared.saveToken(token)
        self.removeLocalNotification()
        CommonUtils.logFacebookCustomEvents("verification", contentType: ["type": "login"])
        UserManager.shared.setDefaultMethodToApplePay()
        self.showHideProgress(button: self.signinButton, show: true)
        let isSuccess = try? await UserManager.webserviceCallForUserDetails()
        self.showHideProgress(button: self.signinButton, show: false)
        if isSuccess ?? false {
            self.moveUserToHomeScreen()
        }
    }
    
    func removeLocalNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func moveUserToHomeScreen(isUpdatePassword: Bool = false) {
        let user = UserManager.shared.user
        let userid = user?.id
        if userid == nil {
            return
        }
        guard let tabVC = UIStoryboard(storyboard: .tabBar).instantiateViewController(withIdentifier: TabViewController.className) as? TabViewController else {
            return
        }
        CommonUtils.navigationToController(controllers: [tabVC])
        self.startAnimation(isCurrentView: false)
    }
    
    @IBAction func didTapOnForgotPasswordButton(_ sender: Any) {
        guard let viewModel = self.viewModel, let email = viewModel.email else {
            return
        }
        self.showDialogue(title: CommonUtils.getStringFromXML(name: "forgot_password"), description: NSLocalizedString("no_problem_forgot_password", comment: "")) {[weak self] success in
            if success {
                Task {
                    CommonUtils.showProgressHud()
                    if let response = try? await viewModel.forgotPassword(email: email) {
                        CommonUtils.hideProgressHud()
                        if response.0 == 1 {
                            self?.viewModel?.verificationInfo = response.2
                            guard let otpVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: ResetPasswordViewController.className) as? ResetPasswordViewController else {
                                return
                            }
                            otpVC.viewModel = self?.viewModel
                            otpVC.verificationType = .resetEmailPasswordVerification
                            self?.navigationController?.pushViewController(otpVC, animated: true)
                        } else {
                            TSMessage.showNotification(in: self, title: "", subtitle: response.1, type: .error)
                        }
                    }
                }
            }
        }
    }
    
    func showError(showError: Bool, error: String) {
        if showError {
            passwordErrorLabel.isHidden = false
            passwordErrorLabel.text = error
            passwordView.setBorderColor(color: UIColor(named: "DE2929"))
        } else {
            passwordErrorLabel.isHidden = true
            passwordView.setBorderColor(color: UIColor(named: passwordTextField.isFirstResponder ? "222222":"E8E8E8"))
        }
    }
}

extension SignInEmailPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !passwordErrorLabel.isHidden {
            passwordErrorLabel.isHidden = true
            passwordView.setBorderColor(color: UIColor(named: "222222"))
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        passwordView.setBorderColor(color: UIColor(named: "222222"))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        passwordView.setBorderColor(color: UIColor(named: "E8E8E8"))
    }
}
