//
//  AppDelegate.swift
//  PowerShare
//
//  Created by admin on 14/01/22.
//  
//
import AdSupport
import AEXML
import AppTrackingTransparency
import CoreLocation
import FirebaseCore
import FirebaseMessaging
import Foundation
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import IQKeyboardManagerSwift
import Reachability
import StripePaymentsUI
import SwiftyJSON
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var languageStrings = [String: Any]()
    var window: UIWindow?
    var deviceToken = ""
    var isUnavailable = ""
    var needToFeedback = false
    var isLoadLocalNotification = false
    var locationManager: CLLocationManager?
    var alertController: UIAlertController?
    let userNotificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        StripeAPI.defaultPublishableKey = CommonUtils.getStringFromPlist("STRIPE_PUBLISHED_KEY")
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey(kGMSApiKey)
        GMSServices.provideAPIKey(kGMSApiKey)
        
        if userDefault.object(forKey: UserDefaultKey.languageType.rawValue) == nil {
            let locale = Locale.current
            if let countryCode = locale.regionCode {
                if (countryCode == "SA") || (countryCode == "JO") {
                    userDefault.setValue("ar", forKey: UserDefaultKey.languageType.rawValue)
                } else if countryCode == "EC" {
                    userDefault.setValue("es", forKey: UserDefaultKey.languageType.rawValue)
                } else {
                    userDefault.setValue("en", forKey: UserDefaultKey.languageType.rawValue)
                }
                userDefault.synchronize()
            }
        }
        self.reloadLanguageStrings()
        self.window?.makeKeyAndVisible()
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        if let userActivityDict = launchOptions?[.userActivityDictionary] as? [AnyHashable : Any],
            let userActivity = userActivityDict["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity {
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                if let incomingURL = userActivity.webpageURL {
                    self.proceedUniversalURL(url: incomingURL)
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        // Handle Google Sign-In URL
        let handledGoogleSignIn = GIDSignIn.sharedInstance.handle(url)
        
        let stripeHandled = StripeAPI.handleURLCallback(with: url)
        if (stripeHandled) {
            return true
        }

        // Return true if any of the handlers can handle the URL
        return handledGoogleSignIn
    }
        
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.deviceToken = ""
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        var backgroundTask: UIBackgroundTaskIdentifier!
        backgroundTask = application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        })
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if isUnavailable == "true" {
            checkServiceAvailable()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    break
                
                case .denied:
                    break
                
                default:
                    print("disable tracking")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let incomingURL = userActivity.webpageURL {
                self.proceedUniversalURL(url: incomingURL)
            }
        }
        return true
    }
    
    func proceedUniversalURL(url: URL) {
        // Extract and handle the product ID from the URL.
        if let cpID = extractCPID(from: url) {
            if let vc = self.window?.rootViewController as? AppNavigationController, let currentVC = vc.viewControllers.last, let presentingVC = currentVC.presentedViewController {
                presentingVC.dismiss(animated: true) {
                    if let vc = self.window?.rootViewController {
                        DispatchQueue.main.async {
                            CommonUtils.callGetPowerSourceApiByIdentifier(identifier: cpID, viewController: vc)
                        }
                    }
                }
            } else {
                if let vc = self.window?.rootViewController {
                    DispatchQueue.main.async {
                        CommonUtils.callGetPowerSourceApiByIdentifier(identifier: cpID, viewController: vc)
                    }
                }
            }
        }
    }

    func extractCPID(from url: URL) -> String? {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "cp_id" {
                    if let cpID = queryItem.value {
                        return cpID
                    }
                }
            }
        }
        return nil
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        let jsonInfo = JSON(userInfo)
        let apsInfo = jsonInfo["aps"]
        let notificationType = jsonInfo["notification_type"].stringValue
        if notificationType == "support" {
            
        }
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        self.clickNotification(userInfo)
        completionHandler()
    }
}

extension AppDelegate {
    func checkInternetConnection() {
        alertController = UIAlertController(title: nil, message: CommonUtils.getStringFromXML(name: "internetconnection_erro"), preferredStyle: .alert)
        let retryAction = UIAlertAction(title: DELEGATE?.languageStrings["retry"] as? String, style: .default, handler: { [self] action in
            do {
                let reachability = try Reachability()
                if reachability.connection == .cellular || reachability.connection == .wifi {
                    if let splashVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: SplashViewController.className) as? SplashViewController, let navVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: AppNavigationController.className) as? AppNavigationController {
                        navVC.viewControllers = [splashVC]
                        self.window?.rootViewController = navVC
                    }
                } else {
                    checkInternetConnection()
                }
            } catch {
            }
        })
        alertController?.addAction(retryAction)
        if let alertController = alertController {
            self.window?.rootViewController?.present(alertController, animated: true)
        }
    }
    
    func forceUpdatePopup() {
        guard let updateForceVC = UIStoryboard(storyboard: .popup).instantiateViewController(withIdentifier: UserForceUpdatePopup.className) as? UserForceUpdatePopup else {
            return
        }
        updateForceVC.actualVersion = ""
        updateForceVC.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.present(updateForceVC, animated: true, completion: nil)
    }
    
    func logoutWhenSessionExpire() {
        alertController = UIAlertController(title: "Session expired", message: "your session has expired, please log in again" , preferredStyle: .alert)
        let ok = UIAlertAction(title: "Log in", style: .default, handler: { action in
            let defaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
            for key in defaultsDictionary.keys {
                UserDefaults.standard.removeObject(forKey: key)
            }
            UserManager.shared.clearObjectToLocal()
            UserSessionManager.shared.clearSession()
            guard let splashViewController = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: SplashViewController.className) as? SplashViewController else {
                return
            }
            guard let navVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: AppNavigationController.className) as? AppNavigationController else {
                return
            }
            navVC.setNavigationBarHidden(true, animated: true)
            navVC.viewControllers = [splashViewController]
            DELEGATE?.window?.rootViewController = navVC
        })
        alertController?.addAction(ok)
        if let alertController = alertController {
            self.window?.rootViewController?.present(alertController, animated: true)
        }
    }
        
    func reloadLanguageStrings() {
        var path = ""
        let selectedLanguage = userDefault.value(forKey: UserDefaultKey.languageType.rawValue) as? String ?? "en"
        switch selectedLanguage {
        case "en":
            if let en = Bundle.main.path(forResource: "strings", ofType: "xml") {
                path = en
            }
            
        case "ar":
            if let ar = Bundle.main.path(forResource: "strings_ar", ofType: "xml") {
                path = ar
            }
            
        case "es":
            if let es = Bundle.main.path(forResource: "strings_spanish", ofType: "xml") {
                path = es
            }
            
        case "fr":
            if let fr = Bundle.main.path(forResource: "strings_french", ofType: "xml") {
                path = fr
            }
            
        default:
            break
        }
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        LanguageManager.shared.setLanguage(selectedLanguage)
        
        let options = AEXMLOptions()
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return }

        do {
            let xmlDoc = try AEXMLDocument(xml: data, options: options)
            languageStrings = [String: Any]()
            xmlDoc.children.first?.children.forEach({ element in
                let attributes = element.attributes
                if let name = attributes["name"] {
                    if let value = element.value {
                        languageStrings[name] = value
                    }
                }
            })
        } catch {
            print("\(error)")
        }
    }
    
    func getPresentingViewController() -> UIViewController? {
        return window?.rootViewController?.presentedViewController
    }
    
    func clickNotification(_ dic: [AnyHashable: Any]) {
        let jsonInfo = JSON(dic)
        debugPrint(jsonInfo)
        let apsInfo = jsonInfo["aps"]
        let notificationType = apsInfo["notification_type"].stringValue
        let notificationTypeOutside = jsonInfo["notification_type"].stringValue
        if notificationTypeOutside == "support" || notificationTypeOutside == "chat" {      return
        }

        if notificationType == "admin" || notificationType == "smart_engagement" || notificationType == "payment_failed" {
        } else {
            let title = apsInfo["alert"]["title"].stringValue
            let msgBody = apsInfo["msg_body"].stringValue
            self.window?.rootViewController?.alertWithTitle(title: title, message: msgBody, completion: {
                if let orderStatus = apsInfo["order_status"].int {
                    switch OrderStatus(rawValue: orderStatus) {
                    case .open, .completed:
                        if let tabVC = CommonUtils.getTabBarView() {
                            tabVC.selectedIndex = 0
                            if let navVC = tabVC.viewControllers?.first as? UINavigationController {
                                navVC.popToRootViewController(animated: true)
                            }
                        }
                        
                    case .none:
                        break
                    }
                }
            })
        }
    }
    
    func checkServiceAvailable() {
        NetworkManager().serviceCheck { success, _, _ in
            if success == 1 {
                self.isUnavailable = ""
                if let splashVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: SplashViewController.className) as? SplashViewController, let navVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: AppNavigationController.className) as? AppNavigationController {
                    navVC.viewControllers = [splashVC]
                    self.window?.rootViewController = navVC
                }
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        if let token = fcmToken {
            self.deviceToken = token
        }
    }
}
