//
//  SideMenuViewController.swift
//  PowerShare
//
//  Created by admin on 07/01/22.
//  
//
import IQKeyboardManagerSwift
import RxSwift
import UIKit

class SideMenuViewController: UIViewController {
    @IBOutlet weak var tblMenu: UITableView!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblName: UITextField!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var logoutStackView: UIStackView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var objActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var balanceView: UIView!
    
    @IBOutlet var seeProfileButton: UIButton!
    var titles: [String] = [String]()
    var images: [String] = [String]()
    var isUpdatePassword = false
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let infoDict = Bundle.main.infoDictionary
        let appVersion = infoDict?["CFBundleShortVersionString"] as? String
        let buildNumber = infoDict?["CFBundleVersion"] as? String
        versionLabel.text = "Version: \(CommonUtils.getStringFromPlist("VERSION_LABEL")) \(appVersion ?? "")(\(buildNumber ?? ""))"
        CommonUtils.logFacebookCustomEvents("account_open", contentType: [:])
        if isUpdatePassword {
            self.selectedItem(item: "profile")
            self.isUpdatePassword = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewBinding()
        memoryAllocations()
        initUI()
        initialSetups()
        webServiceCallForUserDetails()
    }
    
    func viewBinding() {
        seeProfileButton.rx.tap.subscribe { event in
            self.selectedItem(item: "profile")
        }.disposed(by: disposeBag)
    }
    
    func initFont() {
        lblName.font = .robotoMedium(ofSize: 14)
        balanceLabel.font = .robotoMedium(ofSize: 12)
        btnLogout.titleLabel?.font = .robotoMedium(ofSize: 14)
        seeProfileButton.titleLabel?.font = .robotoMedium(ofSize: 14)
    }

    func memoryAllocations() {
        images = [String]()
        titles = [String]()
        tblMenu.separatorColor = .clear
        tblMenu.isOpaque = false
    }
    
    func initUI() {
        seeProfileButton.setTitle(CommonUtils.getStringFromXML(name: "see_profile"), for: .normal)
        if !CommonUtils.isUserLoggedIn() {
            balanceView.isHidden = true
            logoutView.isHidden = true
            seeProfileButton.isHidden = true
            titles.append(CommonUtils.getStringFromXML(name: "support"))
            titles.append(CommonUtils.getStringFromXML(name: "lanugage"))
            images.append("support_map_icon")
            images.append("language")
        } else {
            logoutView.isHidden = true
            seeProfileButton.isHidden = false
            btnLogout.setTitle(CommonUtils.getStringFromXML(name: "logout_title"), for: .normal)
            titles.append(CommonUtils.getStringFromXML(name: "wallet_title"))
            images.append("cash")
            titles.append(NSLocalizedString("my_vehicles", comment: ""))
            images.append("electric-car")
            titles.append(CommonUtils.getStringFromXML(name: "support"))
            images.append("support_map_icon")
            if CommonUtils.getCurrentCustomerType() != "R" {
                titles.append(CommonUtils.getStringFromXML(name: "invite"))
                images.append("invite")
            }
            titles.append(CommonUtils.getStringFromXML(name: "lanugage"))
            images.append("language")
        }
        tblMenu.reloadData()
        balanceLabel.isUserInteractionEnabled = true
        if isLanguageArabic {
            headerView.semanticContentAttribute = .forceRightToLeft
            logoutView.semanticContentAttribute = .forceRightToLeft
            logoutStackView.semanticContentAttribute = .forceRightToLeft
            lblName.textAlignment = .right
        }
    }
    
    @MainActor
    func initialSetups() {
        if let firstName = UserManager.shared.user?.firstName, firstName != "" {
            lblName.text = firstName
        } else {
            lblName.text = CommonUtils.getStringFromXML(name: "guest_title")
        }

        let balanceAttributed = NSMutableAttributedString()
        balanceAttributed.custom(String(format: "%.1f ", CommonUtils.getCurrentUserBalance()), font: .robotoMedium(ofSize: 16), color: UIColor(named: "008CE9") ?? .green)
        balanceAttributed.custom(CommonUtils.getCurrency(), font: .robotoBold(ofSize: 12), color: UIColor(named: "7A7A7A") ?? .green)
        balanceLabel.attributedText = balanceAttributed
        imgViewProfile.image = UIImage(named: "user_avtar")
        imgViewProfile.layer.cornerRadius = imgViewProfile.frame.size.width / 2
        imgViewProfile.layer.masksToBounds = true
    }
    
    func webServiceCallForUserDetails() {
        if CommonUtils.isUserLoggedIn() {
            Task.detached {
                let isSuccess = try? await UserManager.webserviceCallForUserDetails()
                if (isSuccess ?? false) == true && UserManager.shared.user != nil {
                    await MainActor.run {
                        self.initialSetups()
                    }
                }
            }
        }
    }

    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.className) as? SideMenuTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let image = images[indexPath.row]
        if isLanguageArabic {
            cell.imgTailing.image = UIImage(named: image)?.templateImage()
            cell.imgLedding.isHidden = true
            cell.imgTailing.isHidden = false
            cell.lblTitle.textAlignment = .right
            cell.badgeStackView.alignment = .leading
        } else {
            cell.imgLedding.image = UIImage(named: image)?.templateImage()
            cell.imgLedding.isHidden = false
            cell.imgTailing.isHidden = true
            cell.lblTitle.textAlignment = .left
            cell.badgeStackView.alignment = .trailing
        }
        cell.lblTitle.text = titles[indexPath.row]
        cell.badgeTitleView.isHidden = true
        if images[indexPath.row] == "language" {
            cell.badgeTitleView.isHidden = false
            switch isLanguageType {
            case "en":
                cell.badgeLabel.text = "English"
                
            case "ar":
                cell.badgeLabel.text = "العربية"
                
            case "es":
                cell.badgeLabel.text = "Español"
                
            case "fr":
                cell.badgeLabel.text = "Français"
                
            default:
                cell.badgeLabel.text = "English"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageName = images[indexPath.row]
        self.selectedItem(item: imageName)
    }
    
    @IBAction func btnActionBalance(_ sender: Any) {
        guard let balanceVC = UIStoryboard(storyboard: .balance).instantiateViewController(withIdentifier: UserShowBalanceViewController.className) as? UserShowBalanceViewController else {
            return
        }
        let navBalance = CommonUtils.navigationToController()
        navBalance.setViewControllers([balanceVC], animated: true)
        self.present(navBalance, animated: true, completion: nil)
    }
    
    @IBAction func btnActionLogout(_ sender: Any) {
    }
    
    func selectedItem(item: String) {
        switch item {
        case "profile":
            presentProfileViewController()
            
        case "electric-car":
            presentVehicleViewController()
            
        case "support_map_icon":
            supportRequest()
            
        case "invite":
            presentInviteViewController()
            
        case "language":
            presentSelectLanguageViewController()
            
        case "cash":
            presentWalletViewController()
            
        case "balance":
            presentBalanceViewController()
            
        default:
            break
        }
    }

    private func presentProfileViewController() {
        guard let editProfileVC = UIStoryboard(storyboard: .profile).instantiateViewController(withIdentifier: ProfileViewController.className) as? ProfileViewController else {
            return
        }
        editProfileVC.isResetPassword = isUpdatePassword
        editProfileVC.modalPresentationStyle = .fullScreen
        let nav = CommonUtils.navigationToController()
        nav.setViewControllers([editProfileVC], animated: true)
        self.present(nav, animated: true, completion: nil)
    }

    private func presentVehicleViewController() {
        guard let myEVVC = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: MyVehicleViewController.className) as? MyVehicleViewController else {
            return
        }
        myEVVC.modalPresentationStyle = .fullScreen
        let navEV = CommonUtils.navigationToController()
        navEV.setViewControllers([myEVVC], animated: true)
        self.present(navEV, animated: true, completion: nil)
    }

    private func presentInviteViewController() {
        guard let invitationVC = UIStoryboard(storyboard: .invite).instantiateViewController(withIdentifier: InviteViewController.className) as? InviteViewController else {
            return
        }
        invitationVC.modalPresentationStyle = .fullScreen
        let navInvitation = CommonUtils.navigationToController()
        navInvitation.setViewControllers([invitationVC], animated: true)
        self.present(navInvitation, animated: true, completion: nil)
    }

    private func presentSelectLanguageViewController() {
        guard let selectVC = UIStoryboard(storyboard: .authentication).instantiateViewController(withIdentifier: SelectLanguageViewController.className) as? SelectLanguageViewController else {
            return
        }
        selectVC.completionSelectedLanguage = { language in
            self.updateLanguage(selectedLanguage: language)
        }
        self.present(selectVC, animated: true, completion: nil)
    }

    private func presentWalletViewController() {
        guard let walletVC = UIStoryboard(storyboard: .payment).instantiateViewController(withIdentifier: MyWalletViewController.className) as? MyWalletViewController else {
            return
        }
        walletVC.modalPresentationStyle = .fullScreen
        let navWallet = CommonUtils.navigationToController()
        navWallet.setViewControllers([walletVC], animated: true)
        self.present(navWallet, animated: true, completion: nil)
    }

    private func presentBalanceViewController() {
        guard let balanceVC = UIStoryboard(storyboard: .balance).instantiateViewController(withIdentifier: UserShowBalanceViewController.className) as? UserShowBalanceViewController else {
            return
        }
        let navBalance = CommonUtils.navigationToController()
        navBalance.setViewControllers([balanceVC], animated: true)
        self.present(navBalance, animated: true, completion: nil)
    }
}
