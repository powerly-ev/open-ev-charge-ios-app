//
//  UserShowBalanceViewController.swift
//  PowerShare
//
//  Created by admin on 08/01/22.
//  
//

import UIKit

class UserShowBalanceViewController: UIViewController {
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var availableTitleLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var objTableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addBalancetitleLabel: UILabel!
    @IBOutlet weak var currentBalanceView: UIView!
    @IBOutlet var currentBalanceStackView: UIStackView!
    @IBOutlet weak var withdrawLabel: UILabel!
    @IBOutlet weak var withdrawView: UIView!
    
    var balanceArray = [Balance]()
    @IBOutlet var backButton: UIButton!
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        selectedIndex = -1
        if balanceArray.count == 0 {
            webserviceCallForGetBalance()
        } else {
            objTableView.reloadData()
        }
        CommonUtils.logFacebookCustomEvents("show_balance_open", contentType: [:])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI()
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 16)
        balanceLabel.font = .robotoMedium(ofSize: 28)
        currencyLabel.font = .robotoBold(ofSize: 16)
        addBalancetitleLabel.font = .robotoRegular(ofSize: 16)
        withdrawLabel.font = .robotoMedium(ofSize: 14)
        availableTitleLabel.font = .robotoMedium(ofSize: 17)
    }
    
    func initUI() {
        headerLabel.text = CommonUtils.getStringFromXML(name: "show_balance")
        addBalancetitleLabel.text = CommonUtils.getStringFromXML(name: "add_balance")
        availableTitleLabel.text = CommonUtils.getStringFromXML(name: "available_balance")
        withdrawLabel.text = NSLocalizedString("withdraw", comment: "")
        let currency = CommonUtils.getCurrency()
        balanceLabel.text = String(format: "%.2f", CommonUtils.getCurrentUserBalance())
        currencyLabel.text = currency
        if isLanguageArabic {
            availableTitleLabel.textAlignment = .right
            currentBalanceView.semanticContentAttribute = .forceRightToLeft
            currentBalanceStackView.semanticContentAttribute = .forceRightToLeft
            addBalancetitleLabel.textAlignment = .right
        }
        //withdrawView.isHidden = CommonUtils.getCurrentUserBalance() <= 0
    }
    
    func webserviceCallForGetBalance() {
        let countryID = LocationManager.shared.currentCountry?.id
        NetworkManager().getBalances(countryId: countryID) { success, message, balances in
            if success == 1 {
                if let balances = balances {
                    self.balanceArray = balances
                }
                self.objTableView.reloadData()
            } else {
                TSMessage.showNotification(in: DELEGATE?.window?.rootViewController, title: "", subtitle: message, type: .error)
            }
        }
    }
    
    @IBAction func didTap(onBackButton sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapOnTransferButton(_ sender: Any) {
        guard let walletVC = UIStoryboard(storyboard: .payment).instantiateViewController(withIdentifier: TransferBalanceViewController.className) as? TransferBalanceViewController else {
            return
        }
        self.navigationController?.pushViewController(walletVC, animated: true)
    }
}

extension UserShowBalanceViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return balanceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShowBalanceTableViewCell.className) as? ShowBalanceTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let balance = balanceArray[indexPath.row]
        cell.currencyLabel?.text = CommonUtils.getCurrency()
        cell.titleLabel?.text = balance.title
        cell.priceLabel?.text = balance.price
        cell.bonusLabel.text = "+ " + balance.bonus + " " + balance.currency
        cell.popularView.isHidden = balance.popular != 1
        cell.notAvailableNowView?.isHidden = balance.active == true
        cell.popularLabel?.text = CommonUtils.getStringFromXML(name: "popular_text")
        if isLanguageArabic {
            cell.titleLabel?.textAlignment = .right
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let balance = balanceArray[indexPath.row]
        if balance.active == true {
            guard let addBalanceVC = UIStoryboard(storyboard: .balance).instantiateViewController(withIdentifier: AddBalanceViewController.className) as? AddBalanceViewController else {
                return
            }
            addBalanceVC.balance = balance
            self.navigationController?.pushViewController(addBalanceVC, animated: true)
        }
    }
}
