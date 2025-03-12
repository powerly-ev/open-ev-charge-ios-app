import UIKit
import AVKit

class SplashViewController: UIViewController {
    var avPlayer:AVPlayer!
    var videoLayer:AVPlayerLayer!
    var isLoadAPI = true;
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //@IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
        } catch {
        }
        let filepath = Bundle.main.path(forResource: "NewSplashVideo1", ofType: "mp4")
        let fileURL = URL(fileURLWithPath: filepath ?? "")
        avPlayer = AVPlayer(url: fileURL)
        avPlayer.actionAtItemEnd = .none
        videoLayer = AVPlayerLayer(player: avPlayer)
        videoLayer.frame = imageView.bounds
        videoLayer.videoGravity = .resizeAspectFill
        videoLayer.backgroundColor = UIColor.clear.cgColor
        //view.layer.addSublayer(videoLayer)
        self.view.layer.insertSublayer(self.videoLayer, at:0)
        videoLayer.position = CGPointMake(view.layer.bounds.midX, view.layer.bounds.midY-50)
        avPlayer.currentItem?.seek(to: CMTime(value: 1, timescale: 1),completionHandler: { _ in

        })
        self.avPlayer.play()
        navigationController?.isNavigationBarHidden = true
//        self.versionLabel.isHidden = true
//        let infoDict = Bundle.main.infoDictionary
//        let appVersion = infoDict?["CFBundleShortVersionString"] as? String
        //versionLabel.text = "V \(appVersion ?? "")"
        /*avPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 2), queue: nil) { time in
            if time.seconds > 0.9 && time.seconds < 5 {
                self.versionLabel.isHidden = false
            } else if time.seconds > 5 {
                self.versionLabel.isHidden = true
            }

        }*/
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webserviceCallCountry()
    }
    
    func webserviceCallCountry() {
        NetworkManager().countryList { success, message, countryList in
            if success == 1 {
                UserManager.shared.countryList = countryList
                
                if let countryCode = UserManager.shared.country?.phoneCode {
                    if let matchedCountry = UserManager.shared.countryList.first(where: { $0.phoneCode == countryCode }) {
                        UserManager.shared.country = matchedCountry
                    }
                } else if let countryId = UserManager.shared.user?.location?.country?.id {
                    if let matchedCountry = UserManager.shared.countryList.first(where: { $0.id == countryId }) {
                        UserManager.shared.country = matchedCountry
                    }
                } else if UserManager.shared.country == nil {
                    if let country = countryList.first(where: { $0.iso == Locale.current.regionCode }) {
                        UserManager.shared.country = country
                    } else if let country = countryList.first(where: { $0.iso == "GB" }) {
                        UserManager.shared.country = country
                    } else {
                        UserManager.shared.country = countryList.first
                    }
                }
                self.gotoNextScene()
            } else {
                TSMessage.showNotification(in: self, title: "", subtitle: message, type: .error)
            }
        }
    }
    
    func gotoNextScene() {
        if DELEGATE?.isLoadLocalNotification == true {
            DELEGATE?.isLoadLocalNotification = false
            self.loadLocalNotification()
            return
        }
        if CommonUtils.isUserLoggedIn() {
            Task {
                await self.webserviceCallForUserDetails()
            }
        } else {
            Task {
                let remainingTime = getRemainingTime()
                debugPrint(remainingTime)
                await navigateToLanguageSelection(after: remainingTime)
            }
        }
        DELEGATE?.needToFeedback = false
    }
    
    func loadLocalNotification() {
        DELEGATE?.isLoadLocalNotification = false
        let user = UserManager.shared.user
        let lastPageSaved = CommonUtils.getLastPageSaved()
        if user == nil {
            if lastPageSaved == "login" {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.getRemainingTime()) {
                    guard let languageVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: LanguageSelectionViewController.className) as? LanguageSelectionViewController else {
                        return
                    }
                    languageVC.openOtherLoginOption = true
                    self.navigationController?.setViewControllers([languageVC], animated: true)
                }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.getRemainingTime()) {
                guard let tabVC = UIStoryboard(storyboard: .tabBar).instantiateViewController(withIdentifier: TabViewController.className) as? TabViewController else {
                    return
                }
                self.navigationController?.setViewControllers([tabVC], animated: false)
            }
            return
        }
        if CommonUtils.isUserLoggedIn() {
            Task {
                await self.webserviceCallForUserDetails()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.getRemainingTime()) {
                if let user = user {
                    self.moveToMapView(user: user)
                } else {
                    guard let languageVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: LanguageSelectionViewController.className) as? LanguageSelectionViewController else {
                        return
                    }
                    self.navigationController?.setViewControllers([languageVC], animated: true)
                }
            }
        }
        DELEGATE?.needToFeedback = false
    }
    
    func webserviceCallForUserDetails() async {
        if let response = try? await NetworkManager().userDetails() {
            if response.success == 1 {
                if let user = response.data {
                    UserManager.shared.saveUserToDefault(userCurrent: user)
                    if user.currency != "" {
                        userDefault.set(user.currency, forKey: UserDefaultKey.kUserDefaultCurrency.rawValue)
                        userDefault.synchronize()
                    }
                    if user.totalBalance != "" {
                        CommonUtils.setCurrentUserBalance(user.totalBalance)
                    }
                    if let countryId = UserManager.shared.user?.location?.country?.id {
                        if let matchedCountry = UserManager.shared.countryList.first(where: { $0.id == countryId }) {
                            UserManager.shared.country = matchedCountry
                        }
                    }
                    let updated = await LocationManager.shared.updateCurrencyCountry()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.getRemainingTime()) {
                        self.moveToMapView(user: user)
                    }
                }
            } else {
                if let message = response.message {
                    TSMessage.showNotification(in: DELEGATE?.window?.rootViewController, title: "", subtitle: message, type: .error)
                }
            }
        }
    }
    
    @MainActor
    private func moveToMapView(user: User) {
        if user.maintenanceMode {
            activityIndicator.stopAnimating()
            guard let maintananceVC = UIStoryboard(storyboard: .popup).instantiateViewController(withIdentifier: MaintanancePopup.className) as? MaintanancePopup else {
                return
            }
            maintananceVC.modalPresentationStyle = .fullScreen
            self.present(maintananceVC, animated: true, completion: nil)
            return
        }
        guard let tabVC = UIStoryboard(storyboard: .tabBar).instantiateViewController(withIdentifier: TabViewController.className) as? TabViewController else {
            return
        }
        self.navigationController?.setViewControllers([tabVC], animated: false)
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification?) {
        avPlayer.pause()
        videoLayer.removeFromSuperlayer()
        activityIndicator.startAnimating()
    }
    
    func moveToOnboardingLanguageScreen() {
        guard let onboardingVC = UIStoryboard(storyboard: .onboarding).instantiateViewController(withIdentifier: OnboardingViewController.className) as? OnboardingViewController else {
            return
        }
        self.navigationController?.setViewControllers([onboardingVC], animated: false)
    }
    
    func getRemainingTime() -> Double {
        guard let totalDuration = avPlayer.currentItem?.duration.seconds,
              let currentTime = avPlayer.currentItem?.currentTime().seconds else {
            return 0.0
        }
        let timeValue = totalDuration - currentTime
        
        if timeValue.isNaN || timeValue.isInfinite {
            return 1.0
        } else if timeValue > 1 {
            return timeValue
        } else if timeValue < 0 {
            return 0.0
        } else {
            return timeValue + 0.1
        }
    }

    // Updated async/await usage

    func navigateToLanguageSelection(after delay: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) // Convert delay to nanoseconds
        if let languageVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: LanguageSelectionViewController.className) as? LanguageSelectionViewController {
            self.navigationController?.setViewControllers([languageVC], animated: false)
        }
    }
}
