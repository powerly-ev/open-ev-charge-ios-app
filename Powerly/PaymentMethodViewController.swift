//
//  PaymentMethodViewControllerController.swift
//  PowerShare
//
//  Created by admin on 01/02/23.
//  
//
import SwiftyJSON
import UIKit

class PaymentMethodViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var addPaymentMethodLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    
    var sdkToken: String?
    var isExpanded = false
    var cardArray = [Card]()
    var completionCards: (([Card]) -> Void)?
    var completionSetDefaultMethod: ((Card) -> Void)?
    var getTableViewHeight: CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        retrieveCards()
    }

    fileprivate func initUI() {
        titleLabel.font = .robotoMedium(ofSize: 16)
        titleLabel.text = CommonUtils.getStringFromXML(name: "select_payment_title")
        addPaymentMethodLabel.text = CommonUtils.getStringFromXML(name: "add_payment_title")
        if isLanguageArabic {
            titleLabel.textAlignment = .right
            tableView.semanticContentAttribute = .forceRightToLeft
            footerView.semanticContentAttribute = .forceRightToLeft
        }
        tableView.register(UINib(nibName: SelectPaymentMethodTableViewCell.className, bundle: nil), forCellReuseIdentifier: SelectPaymentMethodTableViewCell.className)
    }
    
    func retrieveCards() {
        NetworkManager().getCards { success, _, cards in
            if success == 1 {
                self.cardArray = cards.filter({ $0.paymentType != PaymentMethod.cash && $0.paymentType != PaymentMethod.balance })
                self.completionCards?(cards)
            }
            self.tableView.reloadData()
        }
    }
    
    func setDefaultCards(_ card: Card, paymentType: PaymentMethod) {
        NetworkManager().setDefaultCard(cardId: card.id) { success, message in
            if success == 1 {
                self.completionSetDefaultMethod?(card)
                self.dismiss(animated: true)
            } else {
                TSMessage.showNotification(in: DELEGATE?.window?.rootViewController, title: "", subtitle: message, type: .error)
            }
        }
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnAddPaymentMethodButton(_ sender: Any) {
        guard let addCard = UIStoryboard(storyboard: .payment).instantiateViewController(withIdentifier: StripeAddPaymentViewController.className) as? StripeAddPaymentViewController else {
            return
        }
        addCard.modalPresentationStyle = .overFullScreen
        addCard.completionToken = {
            self.startAnimation(isCurrentView: true)
        }
        self.present(addCard, animated: true)
    }
    
    @IBAction func didTapOnAddBalanceButton(_ sender: UIButton) {
        guard let balanceVC = UIStoryboard(storyboard: .balance).instantiateViewController(withIdentifier: UserShowBalanceViewController.className) as? UserShowBalanceViewController else {
            return
        }
        let navBalance = CommonUtils.navigationToController()
        navBalance.setViewControllers([balanceVC], animated: true)
        self.present(navBalance, animated: true, completion: nil)
    }
}

extension PaymentMethodViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cardArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectPaymentMethodTableViewCell.className, for: indexPath) as? SelectPaymentMethodTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let card = cardArray[indexPath.row]
        cell.setPaymentCard(card: card)
        cell.addButton.addTarget(self, action: #selector(didTapOnAddBalanceButton(_:)), for: .touchUpInside)
        cell.contentView.alpha = 1
        if card.paymentType == .cash || card.paymentType == .balance {
            cell.contentView.alpha = 0.5
            cell.isUserInteractionEnabled = false
        } else {
            cell.isUserInteractionEnabled = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cardArray[indexPath.row]
        self.setDefaultCards(card, paymentType: card.paymentType)
    }
}
