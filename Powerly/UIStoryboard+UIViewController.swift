import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController: StoryboardIdentifiable { }

extension UIStoryboard {
    // The uniform place where we state all the storyboard we have in our application

    enum Storyboard: String {
        case main    = "Main"
        case payment = "Payment"
        case authentication = "Authentication"
        case order = "Order"
        case popup = "Popup"
        case message = "Message"
        case request = "Request"
        case track = "Track"
        case balance = "Balance"
        case payfort = "PayFort"
        case reward = "Reward"
        case invite = "Invite"
        case map = "Map"
        case profile = "Profile"
        case myOrder = "MyOrder"
        case common = "Common"
        case store = "Store"
        case onboarding = "Onboarding"
        case QRStory = "QR"
        case tabBar = "Tabbar"
        case home = "Home"
        case charger = "Charger"
        case vehicle = "Vehicle"
        case external = "External"
        var filename: String {
            return rawValue
        }
    }

    // MARK: - Convenience Initializers

    convenience init(storyboard: Storyboard) {
        self.init(name: storyboard.filename, bundle: nil)
    }

    // MARK: - Class Functions

    class func storyboard(_ storyboard: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: storyboard.filename, bundle: nil)
    }

    // MARK: - View Controller Instantiation from Generics

    func instantiate<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }

        return viewController
    }
}
