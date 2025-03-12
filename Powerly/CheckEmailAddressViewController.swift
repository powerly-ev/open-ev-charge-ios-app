//
//  CheckEmailAddressViewController.swift
//  Powerly
//
//  Created by ADMIN on 15/05/24.
//  
//
import JVFloatLabeledTextField
import UIKit


class CheckEmailAddressViewController: UIViewController {
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTextField: JVFloatLabeledTextField!
    @IBOutlet weak var continueButton: SpinnerButton!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var enterEmailLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    var viewModel = EmailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 18)
        //enterEmailLabel.font = .robotoBold(ofSize: 20)
        emailTextField.font = .robotoMedium(ofSize: 16)
        continueButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        emailErrorLabel.font = .robotoRegular(ofSize: 14)
    }
    
    func initUI() {
        emailTextField.becomeFirstResponder()
        if isLanguageArabic {
            enterEmailLabel.textAlignment = .right
            emailTextField.textAlignment = .right
        }
        if viewModel.email != "" {
            emailTextField.text = viewModel.email
        }
    }
    
    func showError(showError: Bool, error: String) {
        if showError {
            emailErrorLabel.isHidden = false
            emailErrorLabel.text = error
            emailView.setBorderColor(color: UIColor(named: "DE2929"))
        } else {
            emailErrorLabel.isHidden = true
            emailView.setBorderColor(color: UIColor(named: emailTextField.isFirstResponder ? "222222":"E8E8E8"))
        }
    }
    
    private func showHideProgress(show: Bool) {
        if show {
            continueButton.showLoading()
            self.view.isUserInteractionEnabled = false
        } else {
            continueButton.hideLoading()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func didTapOnBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnContinueButton(_ sender: Any) {
        self.showError(showError: false, error: "")
        guard let email = emailTextField.text else {
            self.showError(showError: true, error: NSLocalizedString("Please enter a email address", comment: ""))
            return
        }
        if CommonUtils.validateEmail(with: emailTextField.text ?? "") {
            Task {
                self.showHideProgress(show: true)
                if let data = try? await viewModel.checkEmailExist(email: email) {
                    self.showHideProgress(show: false)
                    if data.0 && data.1 {
                        self.viewModel.email = emailTextField.text ?? ""
                       let _ = try? await self.viewModel.resendEmailVerification(email: emailTextField.text ?? "")
                        guard let otpVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: MobileOTPViewController.className) as? MobileOTPViewController else {
                            return
                        }
                        otpVC.viewModel = self.viewModel
                        otpVC.verificationType = .email
                        self.navigationController?.pushViewController(otpVC, animated: true)
                        return
                    }
                    if data.0 {
                        self.viewModel.email = email
                        guard let signinVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: SignInEmailPasswordViewController.className) as? SignInEmailPasswordViewController else {
                            return
                        }
                        signinVC.viewModel = self.viewModel
                        self.navigationController?.pushViewController(signinVC, animated: true)
                    } else if data.0 == false {
                        self.viewModel.email = email
                        guard let signupVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: RegisterEmailPasswordViewController.className) as? RegisterEmailPasswordViewController else {
                            return
                        }
                        signupVC.viewModel = self.viewModel
                        self.navigationController?.pushViewController(signupVC, animated: true)
                    }
                }
            }
        } else {
            self.showError(showError: true, error: NSLocalizedString("Please enter valid email address", comment: ""))
        }
    }
}

extension CheckEmailAddressViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !emailErrorLabel.isHidden {
            emailView.setBorderColor(color: UIColor(named: "008CE9"))
            emailErrorLabel.isHidden = true
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailView.setBorderColor(color: UIColor(named: "008CE9"))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        emailView.setBorderColor(color: UIColor(named: "E8E8E8"))
    }
    
}
