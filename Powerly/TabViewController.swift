//
//  TabViewController.swift
//  PowerShare
//
//  Created by admin on 24/01/23.
//  
//
import RxSwift
import UIKit

class TabViewController: UITabBarController {
    private let disponseBag = DisposeBag()
    var isPresentItem = false
    var isUpdatePassword = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor(named: "008CE9")
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "222222")
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font: UIFont.robotoMedium(ofSize: 11)]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        
        guard let homeVC = UIStoryboard(storyboard: .home).instantiateViewController(withIdentifier: HomeViewController.className) as? HomeViewController else { return }
        let navHome = CommonUtils.navigationToController()
        navHome.viewControllers = [homeVC]
        navHome.tabBarItem.title = CommonUtils.getStringFromXML(name: "home_text")
        navHome.tabBarItem.image = UIImage(named: "home_tab")
        
        guard let qrVC = UIStoryboard(storyboard: .QRStory).instantiateViewController(withIdentifier: ScanActionViewController.className) as? ScanActionViewController else { return }
        let navQR = CommonUtils.navigationToController()
        navQR.viewControllers = [qrVC]
        navQR.tabBarItem.title = CommonUtils.getStringFromXML(name: "scan_text")
        navQR.tabBarItem.image = UIImage(named: "qr-code")
        
        guard let cartVC = UIStoryboard(storyboard: .myOrder).instantiateViewController(withIdentifier: MyOrderViewController.className) as? MyOrderViewController else { return }
        let navCart = CommonUtils.navigationToController()
        navCart.viewControllers = [cartVC]
        navCart.tabBarItem.title = CommonUtils.getStringFromXML(name: "orders_text")
        navCart.tabBarItem.image = UIImage(named: "cart_icon")
        navCart.tabBarItem.badgeColor = .clear
        navCart.tabBarItem.setBadgeTextAttributes([.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.red], for: .normal)
        
        guard let accountVC = UIStoryboard(storyboard: .main).instantiateViewController(withIdentifier: SideMenuViewController.className) as? SideMenuViewController else { return }
        accountVC.isUpdatePassword = isUpdatePassword
        let navAccount = CommonUtils.navigationToController()
        navAccount.viewControllers = [accountVC]
        navAccount.tabBarItem.title = CommonUtils.getStringFromXML(name: "account_text")
        navAccount.tabBarItem.image = UIImage(named: "account_tab")
        
        if CommonUtils.isUserLoggedIn() {
            self.viewControllers = [navHome, navQR, navCart, navAccount]
            if isUpdatePassword {
                self.selectedIndex = 3
            }
        } else {
            self.viewControllers = [navHome, navQR, navAccount]
        }
    }
}

@IBDesignable class TabBarWithCorners: UITabBar {
    @IBInspectable var color: UIColor?
    @IBInspectable var radii: CGFloat = 15.0

    private var shapeLayer: CALayer?

    override func draw(_ rect: CGRect) {
        addShape()
    }

    private func addShape() {
        let shapeLayer = CAShapeLayer()

        shapeLayer.path = createPath()
        shapeLayer.strokeColor = (UIColor(named: "D4D4D4") ?? .black).withAlphaComponent(0.2).cgColor
        shapeLayer.fillColor = color?.cgColor ?? UIColor.white.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.shadowColor = (UIColor(named: "999999") ?? .black).cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: -5)
        shapeLayer.shadowOpacity = 0.1
        shapeLayer.shadowPath =  UIBezierPath(roundedRect: bounds, cornerRadius: radii).cgPath
        
        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
    }

    private func createPath() -> CGPath {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radii, height: 0.0))

        return path.cgPath
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.isTranslucent = true
        var tabFrame = self.frame
        tabFrame.size.height = 65 + (UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.bottom ?? CGFloat.zero)
        tabFrame.origin.y = self.frame.origin.y + (self.frame.height - 65 - (UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.bottom ?? CGFloat.zero))
        self.layer.cornerRadius = 20
        self.frame = tabFrame
        self.items?.forEach({ $0.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -5.0) })
    }
}
