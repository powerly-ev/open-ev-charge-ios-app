//
//  UIViewController.swift
//  PowerShare
//
//  Created by admin on 28/10/21.

//
import AudioToolbox
import Foundation
import Lottie
import UIKit

extension UIViewController {
    @MainActor
    func startAnimation(isCurrentView: Bool) {
        var lottieAnimation: LottieAnimationView?
        lottieAnimation = LottieAnimationView(frame: CGRect(x: self.view.frame.width/2 - 75, y: self.view.frame.height/2 - 75, width: 150, height: 150))
        lottieAnimation?.animation = LottieAnimation.named("done_animation")
        lottieAnimation?.contentMode = .scaleAspectFit
        if let animationView = lottieAnimation {
            if isCurrentView {
                self.view.addSubview(animationView)
            } else {
                DELEGATE?.window?.rootViewController?.view.addSubview(animationView)
            }
        }
        lottieAnimation?.play(completion: { _ in
            lottieAnimation?.removeFromSuperview()
        })
    }
    
    @MainActor
    func startAnimation() async {
        var lottieAnimation: LottieAnimationView?
        lottieAnimation = LottieAnimationView(frame: CGRect(x: self.view.frame.width / 2 - 75, y: self.view.frame.height / 2 - 75, width: 150, height: 150))
        lottieAnimation?.animation = LottieAnimation.named("done_animation")
        lottieAnimation?.contentMode = .scaleAspectFit

        if let animationView = lottieAnimation {
            self.view.addSubview(animationView)
        }

        await withCheckedContinuation { continuation in
            lottieAnimation?.play(completion: { _ in
                lottieAnimation?.removeFromSuperview()
                continuation.resume()
            })
        }
    }

    func enableDisableInteraction(enable: Bool) {
        self.view.isUserInteractionEnabled = enable
    }
    
    func showHideProgress(button: SpinnerButton, show: Bool) {
        if show {
            button.showLoading()
            enableDisableInteraction(enable: false)
        } else {
            button.hideLoading()
            enableDisableInteraction(enable: true)
        }
    }
    
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction(title: option, style: .default, handler: {_ in
                completion(index)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertWithTitle(title: String, message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: CommonUtils.getStringFromXML(name: "rateapp_ok"), style: .default, handler: { _ in
            completion()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showDialogue(title: String, description: String, yesTitle: String = CommonUtils.getStringFromXML(name: "Yes"), noTitle: String =  CommonUtils.getStringFromXML(name: "No"), completion: @escaping (Bool) -> Void) {
        guard let confirmationPopup = UIStoryboard(storyboard: .popup).instantiateViewController(withIdentifier: ConfirmationDialogueVC.className) as? ConfirmationDialogueVC else {
            return
        }
        confirmationPopup.titleStr = title
        confirmationPopup.descriptionStr = description
        confirmationPopup.yesTitle = yesTitle
        confirmationPopup.noTitle = noTitle
        confirmationPopup.completionButton = { success in
            completion(success)
        }
        confirmationPopup.modalPresentationStyle = .overFullScreen
        self.present(confirmationPopup, animated: true) {
        }
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        self.presentAlertWithTitle(title: "Permission Denied", message: "We need camera access permission to scan QR code. please allow camera permission under the app settings", options: CommonUtils.getStringFromXML(name: "No"), CommonUtils.getStringFromXML(name: "go_settings")) { index in
            if index == 1 {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

extension UIViewController {
    // see ObjectAssociation<T> class below
    private static let association = ObjectAssociation<UIActivityIndicatorView>()

    var indicator: UIActivityIndicatorView {
        get {
            if let indicator = UIViewController.association[self] {
                return indicator
            } else {
                UIViewController.association[self] = UIActivityIndicatorView.customIndicator(at: self.view.center)
                return UIViewController.association[self]!
            }
        }
        set { UIViewController.association[self] = newValue }
    }

    // MARK: - Acitivity Indicator
    public func startIndicatingActivity(touchEnabled: Bool) {
        DispatchQueue.main.async {
            self.view.addSubview(self.indicator)
            self.indicator.startAnimating()
            if !touchEnabled {
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
        }
    }

    public func stopIndicatingActivity() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    public final class ObjectAssociation<T: AnyObject> {

        private let policy: objc_AssociationPolicy

        /// - Parameter policy: An association policy that will be used when linking objects.
        public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {

            self.policy = policy
        }

        /// Accesses associated object.
        /// - Parameter index: An object whose associated object is to be accessed.
        public subscript(index: AnyObject) -> T? {

            get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? T }
            set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
        }
    }
    
    func supportRequest() {
        let phoneNumber = "telprompt://" + supportNumber
        if let url = URL(string: phoneNumber) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func updateLanguage(selectedLanguage: String) {
        let languageMap = [
            "English": "en",
            "العربية": "ar",
            "Español": "es",
            "Français": "fr"
        ]
        
        guard let strLanguage = languageMap[selectedLanguage] else { return }

        if !CommonUtils.isUserLoggedIn() {
            // Update the language setting and synchronize
            userDefault.setValue(strLanguage, forKey: UserDefaultKey.languageType.rawValue)
            userDefault.synchronize()
            
            // Reload language strings and reset navigation
            DELEGATE?.reloadLanguageStrings()
            resetRootViewController()
        } else {
            let uuid = UserSessionManager.shared.getUUID()
            let currSysVer = UIDevice.current.systemVersion
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            
            let dict: [String: Any] = [
                "imei": uuid,
                "device_type": "2",
                "device_version": currSysVer,
                "device_language": strLanguage,
                "app_version": version
            ]
            
            NetworkManager().updateDeviceInfo(params: dict) { success, _, _ in
                if success == 1 {
                    // Update the language setting and synchronize
                    userDefault.setValue(strLanguage, forKey: UserDefaultKey.languageType.rawValue)
                    userDefault.synchronize()
                    
                    // Reload language strings and reset navigation
                    DELEGATE?.reloadLanguageStrings()
                    self.resetRootViewController()
                }
            }
        }
    }

    private func resetRootViewController() {
        guard let splashViewController = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: SplashViewController.className) as? SplashViewController,
              let navVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: AppNavigationController.className) as? AppNavigationController else {
            return
        }

        navVC.setNavigationBarHidden(true, animated: true)
        navVC.viewControllers = [splashViewController]
        DELEGATE?.window?.rootViewController = navVC
    }
}

extension UIActivityIndicatorView {
    public static func customIndicator(at center: CGPoint) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        indicator.layer.cornerRadius = 10
        indicator.center = center
        indicator.hidesWhenStopped = true
        indicator.style = .large
        indicator.color = .gray
        return indicator
    }
}

extension UIViewController {
    func checkScanAction(name: String) -> Bool {
        if !CommonUtils.isUserLoggedIn() {
            self.showLoginScreen()
            return true
        }
        if name.hasPrefix("logintoken") {
            if let confirmVC = UIStoryboard(storyboard: .QRStory).instantiateViewController(withIdentifier: ConfirmWebLoginViewController.className) as? ConfirmWebLoginViewController {
                confirmVC.modalPresentationStyle = .overFullScreen
                confirmVC.completion = {
                    Task {
                        CommonUtils.showProgressHud()
                        _ = try? await NetworkManager().loginQRCodeUrl(token: name)
                        CommonUtils.hideProgressHud()
                        // For a basic vibration
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    }
                }
                self.present(confirmVC, animated: true)
            }
            return true
        }
        if name.contains("cp_id") {
            CommonUtils.callGetPowerSourceApiByIdentifier(identifier: extractCPID(from: name), viewController: self)
        }
        guard let action = ScanAction(rawValue: name) else {
            return true
        }
        switch action {
        case .openSensor:
            return true
            
        case .openSupport:
            supportRequest()
            return true
            
        case .changeLanguageArabic:
            updateLanguage(selectedLanguage: "العربية")
            return true
            
        case .changeLanguageEnglish:
            updateLanguage(selectedLanguage: "English")
            return true
            
        case .changeLanguageSpanish:
            updateLanguage(selectedLanguage: "Español")
            return true
        }
    }
    
    func extractCPID(from urlString: String) -> String {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count))

            for match in matches {
                if let url = match.url,
                   let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems {
                    for queryItem in queryItems {
                        if queryItem.name == "cp_id", let cpid = queryItem.value {
                            return cpid
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        return urlString
    }
    
    func shareAPP() {
        if let name = URL(string: shareURL), !name.absoluteString.isEmpty {
            let objectsToShare = [NSLocalizedString("share_earn", comment: "").replacingOccurrences(of: "[Referral Link]", with: name.absoluteString)]
            showActivityViewController(data: objectsToShare)
        }
    }
    
    func showActivityViewController(data: [Any]) {
    let activityVC = UIActivityViewController(activityItems: data, applicationActivities: nil)
    // Exclude all activities except specific social media apps
    activityVC.excludedActivityTypes = [
      .message,
      .mail,
      .saveToCameraRoll,
      .addToReadingList,
      .print,
      .postToFlickr,
      .postToVimeo,
      .postToTencentWeibo,
      .airDrop,
      .openInIBooks,
      .markupAsPDF,
      UIActivity.ActivityType(rawValue: "com.apple.reminders.sharingextension"),
      UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")
      ]
    self.present(activityVC, animated: true, completion: nil)
    }

    func showLoginScreen() {
        if let languageVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: LanguageSelectionViewController.className) as? LanguageSelectionViewController {
            languageVC.openOtherLoginOption = true
            self.navigationController?.setViewControllers([languageVC], animated: true)
        }
    }
}
