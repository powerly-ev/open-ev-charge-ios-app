//
//  GuestCommonViewController.swift
//  Powerly
//
//  Created by ADMIN on 29/05/24.
//  
//
import AuthenticationServices
import GoogleSignIn
import UIKit

class GuestCommonViewController: UIViewController {
    let viewModel1 = EmailViewModel()
    
    func showListOfOtherOptions(showGuest: Bool) {
        guard let loginOptionsVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: LoginOptionsViewController.className) as? LoginOptionsViewController else {
            return
        }
        loginOptionsVC.showGuest = showGuest
        loginOptionsVC.modalPresentationStyle = .overFullScreen
        loginOptionsVC.completionHandler = { selectedOptions in
            self.openLoginOptions(option: selectedOptions)
        }
        self.present(loginOptionsVC, animated: true, completion: nil)
    }
    
    func signinWithApplePay() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func openLoginOptions(option: SignInOption) {
        switch option {
        case .apple:
            self.signinWithApplePay()
            
        case .email:
            guard let loginOptionsVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: CheckEmailAddressViewController.className) as? CheckEmailAddressViewController else {
                return
            }
            self.navigationController?.pushViewController(loginOptionsVC, animated: true)
            
        case .google:
            self.googleSignin()

        case .guest:
            CommonUtils.logFacebookCustomEvents("get_started", contentType: [:])
            guard let tabVC = UIStoryboard(storyboard: .tabBar).instantiateViewController(withIdentifier: TabViewController.className) as? TabViewController else {
                return
            }
            self.navigationController?.setViewControllers([tabVC], animated: true)
            
        case .phone:
            guard let registerCtrl = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: UserRegistrationViewController.className) as? UserRegistrationViewController else {
                return
            }
            navigationController?.pushViewController(registerCtrl, animated: true)
        }
    }
}

extension GuestCommonViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if let idTokenData = appleIDCredential.identityToken, let jwtToken = String(data: idTokenData, encoding: .utf8) {
                Task {
                    CommonUtils.showProgressHud()
                    if let response = try? await self.viewModel1.socialLogin(type: .apple, idToken: jwtToken, countryId: self.viewModel1.getCountryId()) {
                        CommonUtils.hideProgressHud()
                        if response.0 == 1 {
                            if let customer = response.2 {
                                UserSessionManager.shared.saveUserId(customer.id.description)
                                self.saveTokenProceedFurther(token: customer.accessToken)
                            }
                        } else {
                            TSMessage.showNotification(in: self, title: "", subtitle: response.1, type: .error)
                        }
                    }
                }
            }
        }
    }
    
    func saveTokenProceedFurther(token: String) {
        UserSessionManager.shared.saveToken(token)
        self.removeLocalNotification()
        CommonUtils.logFacebookCustomEvents("verification", contentType: ["type": "login"])
        UserManager.shared.setDefaultMethodToApplePay()
        CommonUtils.showProgressHud()
        Task {
            let isSuccess = try? await UserManager.webserviceCallForUserDetails()
            CommonUtils.hideProgressHud()
            if isSuccess ?? false {
                self.moveUserToHomeScreen()
            }
        }
    }
    
    func removeLocalNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func moveUserToHomeScreen() {
        if !CommonUtils.isUserLoggedIn() {
            return
        }
        guard let tabVC = UIStoryboard(storyboard: .tabBar).instantiateViewController(withIdentifier: TabViewController.className) as? TabViewController else {
            return
        }
        CommonUtils.navigationToController(controllers: [tabVC])
        self.startAnimation(isCurrentView: false)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
        print("Authorization failed: \(error.localizedDescription)")
    }
}

extension GuestCommonViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension GuestCommonViewController {
    func googleSignin() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }

            guard let user = signInResult?.user else {
                return
            }
            let idToken = user.idToken
            guard let idTokenString = idToken?.tokenString else {
                return
            }
            Task {
                CommonUtils.showProgressHud()
                if let response = try? await self.viewModel1.socialLogin(type: .google, idToken: idTokenString, countryId: self.viewModel1.getCountryId()) {
                    CommonUtils.hideProgressHud()
                    if response.0 == 1 {
                        if let customer = response.2 {
                            UserSessionManager.shared.saveUserId(customer.id.description)
                            self.saveTokenProceedFurther(token: customer.accessToken)
                        }
                    } else {
                        TSMessage.showNotification(in: self, title: "", subtitle: response.1, type: .error)
                    }
                }
            }
        }
    }
}
