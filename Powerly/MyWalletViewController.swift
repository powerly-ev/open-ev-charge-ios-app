//
//  MyWalletViewController.swift
//  PowerShare
//
//  Created by admin on 08/01/22.
//  
//


import PassKit
import SkeletonView
import SwiftyJSON
import UIKit

enum MenuOption: String {
    case edit
    case makeDefault
    case remove
    case evCharger
    case powerMeter
    case smartPlug
    
    var localizedText: String {
        switch self {
            case .edit: return CommonUtils.getStringFromXML(name: "edit_title")
            
            case .makeDefault: return CommonUtils.getStringFromXML(name: "make_default")
            
            case .remove: return CommonUtils.getStringFromXML(name: "remove_title")
            
            case .evCharger: return NSLocalizedString("ev_charger", comment: "")
            
            case .powerMeter: return NSLocalizedString("power_meter", comment: "")
            
            case .smartPlug: return NSLocalizedString("smart_plug", comment: "")
        }
    }
}

class MyWalletViewController: UIViewController {
    @IBOutlet var objTableView: UITableView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var addNewCardButton: SpinnerButton!
    @IBOutlet var headerView: UIView!
    @IBOutlet var backButton: UIButton!
    
    var sdkToken: String?
    var getCardsArray: [Card] = [Card]()
    var isDefaultIndex: Int = -1
    var isAddNewCard: Bool = true
    var isShowAddPopup = true
    var oldCardId: String?
    var oldTokenName: String?
    var applePayButton: PKPaymentButton = PKPaymentButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveCards()
        initUI()
        CommonUtils.logFacebookCustomEvents("wallet_open", contentType: [:])
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func initUI() {
        headerLabel.font = .robotoMedium(ofSize: 16)
        addNewCardButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        headerLabel.text = CommonUtils.getStringFromXML(name: "wallet_title")
        addNewCardButton.setTitle(CommonUtils.getStringFromXML(name: "add_new_card"), for: .normal)
        if isLanguageArabic {
            objTableView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func retrieveCards() {
        objTableView.startSkeletonAnimation()
        objTableView.showGradientSkeleton()
        NetworkManager().getCards { success, _, cards in
            self.objTableView.stopSkeletonAnimation()
            self.objTableView.hideSkeleton()
            if success == 1 {
                self.getCardsArray = cards
                if let index = self.getCardsArray.firstIndex(where: { card in
                    return card.isDefault == 1
                }) {
                    self.isDefaultIndex = index
                }
                if cards.count == 0 && self.isShowAddPopup {
                    self.isShowAddPopup = false
                    self.didTap(onAddNewCardButton: self)
                }
            }
            self.objTableView.reloadData()
        }
    }
    
    func setDefaultCards(_ cardId: String, paymentType: Int) {
        NetworkManager().setDefaultCard(cardId: cardId) { success, message in
            if success == 1 {
                self.retrieveCards()
                self.startAnimation(isCurrentView: true)
            } else {
                self.alertWithTitle(title: "", message: message) {
                }
            }
        }
    }
    
    @IBAction func didTap(onDeleteCard sender: UIButton) {
        let card = getCardsArray[sender.tag]
        let strId = card.id
        if !CommonUtils.isUserLoggedIn() {
            return
        }
        self.showDialogue(title: "", description: CommonUtils.getStringFromXML(name: "delete_card_warning")) { success in
            if success {
                NetworkManager().deleteCard(cardId: strId) { success, message, _ in
                    if success == 1 {
                        self.retrieveCards()
                        self.startAnimation(isCurrentView: true)
                    } else {
                        self.alertWithTitle(title: "", message: message) {
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func didTap(onAddNewCardButton sender: Any) {
        guard let addCard = UIStoryboard(storyboard: .payment).instantiateViewController(withIdentifier: StripeAddPaymentViewController.className) as? StripeAddPaymentViewController else {
            return
        }
        addCard.modalPresentationStyle = .overFullScreen
        addCard.completionToken = {
            self.startAnimation(isCurrentView: true)
        }
        self.present(addCard, animated: true)
    }
    
    @IBAction func didTap(onBackButton sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTap(onCloseButton sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapOnMenuButton(sender: UIButton) {
        let index = sender.tag
        let card = getCardsArray[index]
        guard let multiItemPopup = UIStoryboard(storyboard: .popup).instantiateViewController(withIdentifier: MultiItemPopup.className) as? MultiItemPopup else {
            return
        }
        multiItemPopup.modalPresentationStyle = .overCurrentContext
        switch card.paymentType {
        case .payFort:
            multiItemPopup.options = [MenuOption.makeDefault, MenuOption.remove]
            
        default:
            multiItemPopup.options = [MenuOption.makeDefault]
        }
        multiItemPopup.completionItem = { option in
            switch option {
                
            case .makeDefault:
                self.setDefaultCards(card.id, paymentType: card.paymentType.rawValue)
                
            case .remove:
                self.didTap(onDeleteCard: sender)
                
            default:
                break
            }
        }
        self.present(multiItemPopup, animated: true)
    }

    @objc func didTapOnBalanceButton(sender: UIButton) {
        guard let balanceVC = UIStoryboard(storyboard: .balance).instantiateViewController(withIdentifier: UserShowBalanceViewController.className) as? UserShowBalanceViewController else {
            return
        }
        let navBalance = CommonUtils.navigationToController()
        navBalance.setViewControllers([balanceVC], animated: true)
        self.present(navBalance, animated: true, completion: nil)
    }
}

extension MyWalletViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCardsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = getCardsArray[indexPath.row]
        let paymentType = card.paymentType
        let cardNumber = card.cardNumber
        let paymentOption = card.paymentOption
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodTableViewCell.className, for: indexPath) as? PaymentMethodTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        if card.isDefault == 1 {
            cell.defaultMethodView?.isHidden = false
        } else {
            cell.defaultMethodView?.isHidden = true
        }
        cell.menuIcon.tag = indexPath.row
        cell.menuIcon.addTarget(self, action: #selector(self.didTapOnMenuButton(sender:)), for: .touchUpInside)
        cell.addView.isHidden = true
        switch paymentType {
        case .cash:
            cell.methodImageView.image = UIImage(named: "cash_icon")
            cell.titleLabel.text = CommonUtils.getStringFromXML(name: "cash_on_delivery")
            cell.subTitleLabel.text = ""
            return cell
            
        case .payFort:
            if paymentOption == "MADA" {
                cell.methodImageView.contentMode = .scaleAspectFit
                cell.methodImageView?.image = UIImage(named: "madaicon")
                cell.titleLabel.text = CommonUtils.getStringFromXML(name: "mada_card_title")
                cell.subTitleLabel.text = "************\(cardNumber)"
                // cellMada.madaTextArabicLabel?.text = CommonUtils.getStringFromXML(name: "mada_card_title")
                return cell
            } else {
                cell.methodImageView?.image = UIImage(named: "creditcard")
                cell.titleLabel.text = paymentOption
                cell.subTitleLabel.text = "************\(cardNumber)"
                return cell
            }
            
        case .pointCheckout:
            cell.methodImageView.image = UIImage(named: "epoint_icon")
            cell.titleLabel.text = CommonUtils.getStringFromXML(name: "point_checkout")
            cell.subTitleLabel.text = ""
            return cell
            
        case .paypal:
            cell.methodImageView.image = UIImage(named: "PayPal-logo")
            cell.titleLabel.text = CommonUtils.getStringFromXML(name: "paypal_title")
            cell.subTitleLabel.text = ""
            return cell
            
        case .applePay:
            cell.methodImageView.image = UIImage(named: "applepay_icon")
            cell.titleLabel.text = CommonUtils.getStringFromXML(name: "applepay_title")
            cell.subTitleLabel.text = ""
            if let appleImage = applePayButton.currentImage {
                cell.methodImageView.image = appleImage
            }
            return cell
            
        case .balance:
            cell.methodImageView.image = UIImage(named: "balance_icon")
            cell.titleLabel.text = CommonUtils.getStringFromXML(name: "balance_title")
            if isLanguageArabic {
                cell.subTitleLabel.text = "\u{202A} " + CommonUtils.getCurrency() + " \u{202A}" + card.balance
            } else {
                cell.subTitleLabel.text =  card.balance + " " + CommonUtils.getCurrency()
            }
            cell.addView.isHidden = false
            cell.addButton.addTarget(self, action: #selector(didTapOnBalanceButton(sender:)), for: .touchUpInside)
            return cell
            
            default:
                break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = getCardsArray[indexPath.row]
        let paymentType = card.paymentType
        if paymentType == .applePay {
            
        }
        isDefaultIndex = indexPath.row
        self.objTableView.reloadData()
    }
}

extension MyWalletViewController: SkeletonTableViewDataSource {
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return PaymentMethodTableViewCell.className
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        guard let cell = skeletonView.dequeueReusableCell(withIdentifier: PaymentMethodTableViewCell.className, for: indexPath) as? PaymentMethodTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, prepareCellForSkeleton cell: UITableViewCell, at indexPath: IndexPath) {
    }
}
