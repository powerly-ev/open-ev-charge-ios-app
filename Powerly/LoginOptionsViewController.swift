//
//  LoginOptionsViewController.swift
//  Powerly
//
//  Created by ADMIN on 09/05/24.
//  
//

import UIKit

enum SignInOption {
    case email
    case phone
    case google
    case apple
    case guest
}

class LoginOptionsViewController: UIViewController {
    @IBOutlet weak var signinPhoneLabel: UILabel!
    @IBOutlet weak var signinEmailLabel: UILabel!
    @IBOutlet weak var signinGoogleLabel: UILabel!
    @IBOutlet weak var signinAppleLabel: UILabel!
    @IBOutlet weak var continueAsGuestLabel: UILabel!
    @IBOutlet weak var continueAsGuestView: UIView!
    @IBOutlet weak var appleLogoImageView: UIImageView!
    var completionHandler: ((SignInOption) -> Void)?
    var showGuest = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        continueAsGuestView.isHidden = !showGuest
        if #available(iOS 16.0, *) {
            appleLogoImageView.image = UIImage(systemName: "apple.logo")
        } else {
            appleLogoImageView.image = UIImage(systemName: "applelogo")
        }
    }
    
    func initFont() {
        signinPhoneLabel.font = .robotoMedium(ofSize: 18)
        signinEmailLabel.font = .robotoMedium(ofSize: 18)
        signinGoogleLabel.font = .robotoMedium(ofSize: 18)
        signinAppleLabel.font = .robotoMedium(ofSize: 18)
        continueAsGuestLabel.font = .robotoMedium(ofSize: 18)
    }
    
    @IBAction func didTapOnOutsideButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnSigninWithPhoneButton(_ sender: Any) {
        self.dismiss(animated: false) {
            self.completionHandler?(.phone)
        }
    }
    
    @IBAction func didTapOnSigninWithEmailButton(_ sender: Any) {
        self.dismiss(animated: false) {
            self.completionHandler?(.email)
        }
    }
    
    @IBAction func didTapOnSigninWithGoogleButton(_ sender: Any) {
        self.dismiss(animated: false) {
            self.completionHandler?(.google)
        }
    }
    
    @IBAction func didTapOnSigninWithAppleButton(_ sender: Any) {
        self.dismiss(animated: false) {
            self.completionHandler?(.apple)
        }
    }
    
    @IBAction func didTapOnContinueAsGuest(_ sender: Any) {
        self.dismiss(animated: false) {
            self.completionHandler?(.guest)
        }
    }
    
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
