//
//  AddBalanceViewController.swift
//  PowerShare
//
//  Created by admin on 09/01/22.
//  
//
import PassKit
import RxSwift
import SafariServices
import Stripe
import SwiftyJSON
import UIKit



class AddBalanceViewController: UIViewController, STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var selectedCellView: UIView!
    @IBOutlet weak var selectedBalanceLabel: UILabel!
    @IBOutlet weak var selectedCurrencyLabel: UILabel!
    @IBOutlet weak var popularLabel: UILabel!
    @IBOutlet weak var popularView: UIView!
    @IBOutlet weak var selectedDiscountLabel: UILabel!
    @IBOutlet weak var selectedDiscountView: UIView!
    
    @IBOutlet weak var addBalanceStackView: UIStackView!
    @IBOutlet weak var addBalanceLabel: UILabel!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var wilAddStackView: UIStackView!
    @IBOutlet weak var willAddLabel: UILabel!
    
    @IBOutlet weak var totalBalance: UILabel!
    @IBOutlet weak var subTotalView: UIView!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var vatLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var subTotalPriceLabel: UILabel!
    @IBOutlet weak var discountStackView: UIStackView!
    @IBOutlet weak var discountImageView: UIImageView!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var vatPriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalParentStackView: UIStackView!
    @IBOutlet weak var totalLabelStackView: UIStackView!
    @IBOutlet weak var totalValueStackView: UIStackView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var balanceNoteLabel: UILabel!
    @IBOutlet var agreeContinueLabel: UILabel!
    @IBOutlet var agreeContinueButton: SpinnerButton!
    @IBOutlet var leftArrowImageView: UIImageView!
    @IBOutlet var rightArrowImageView: UIImageView!
   
    @IBOutlet weak var methodImageView: UIImageView!
    @IBOutlet weak var paymentMethodTitleLabel: UILabel!
    @IBOutlet weak var selectedMethodLabel: UILabel!
    @IBOutlet weak var paymentMethodView: UIView!
    @IBOutlet var changeLabel: UILabel!
    
    var balance: Balance?
    var applePayButton = PKPaymentButton()
    var orderid: String?
    var paymentToken: String?
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = AddBalanceViewModel()
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        loadData()
        bindView()
        viewModel.retrieveCards()
        CommonUtils.logFacebookCustomEvents("add_balance_open", contentType: [:])
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 16)
        selectedBalanceLabel.font = .robotoLight(ofSize: 28)
        selectedCurrencyLabel.font = .robotoBold(ofSize: 16)
        selectedDiscountLabel.font = .robotoMedium(ofSize: 12)
        popularLabel.font = .robotoMedium(ofSize: 12)
        addBalanceLabel.font = .robotoRegular(ofSize: 14)
        currentBalanceLabel.font = .robotoBold(ofSize: 14)
        willAddLabel.font = .robotoRegular(ofSize: 14)
        totalBalance.font = .robotoBold(ofSize: 14)
        
        subTotalLabel.font = .robotoRegular(ofSize: 14)
        discountLabel.font = .robotoRegular(ofSize: 14)
        vatLabel.font = .robotoRegular(ofSize: 14)
        totalLabel.font = .robotoMedium(ofSize: 14)
                                        
        subTotalPriceLabel.font = .robotoRegular(ofSize: 14)
        discountPriceLabel.font = .robotoRegular(ofSize: 14)
        vatPriceLabel.font = .robotoRegular(ofSize: 14)
        totalPriceLabel.font = .robotoMedium(ofSize: 14)
        
        balanceNoteLabel.font = .robotoLight(ofSize: 15)
        agreeContinueLabel.font = .robotoMedium(ofSize: 16)
    }

    func initUI() {
        balanceNoteLabel.text = CommonUtils.getStringFromXML(name: "balance_note")
        agreeContinueLabel.text = CommonUtils.getStringFromXML(name: "agree_continue")
        headerLabel.text = CommonUtils.getStringFromXML(name: "add_balance")
        willAddLabel.text = CommonUtils.getStringFromXML(name: "we_will_add_balance")
        addBalanceLabel.text = CommonUtils.getStringFromXML(name: "add_balance")
        subTotalLabel.text = CommonUtils.getStringFromXML(name: "subtotal_title")
        discountLabel.text = CommonUtils.getStringFromXML(name: "discount_title")
        vatLabel.text = CommonUtils.getStringFromXML(name: "vat_title")
        totalLabel.text = CommonUtils.getStringFromXML(name: "total_price_title")
        if isLanguageArabic {
            selectedCellView.semanticContentAttribute = .forceRightToLeft
            addBalanceStackView.insertArrangedSubview(addBalanceLabel, at: 1)
            addBalanceStackView.insertArrangedSubview(currentBalanceLabel, at: 0)
            wilAddStackView.insertArrangedSubview(willAddLabel, at: 1)
            wilAddStackView.insertArrangedSubview(totalBalance, at: 0)

            totalParentStackView.insertArrangedSubview(totalLabelStackView, at: 1)
            totalParentStackView.insertArrangedSubview(totalValueStackView, at: 0)
            totalLabelStackView.alignment = UIStackView.Alignment.trailing
            totalValueStackView.alignment = UIStackView.Alignment.leading

            discountStackView.insertArrangedSubview(discountPriceLabel, at: 0)
            discountStackView.insertArrangedSubview(discountImageView, at: 1)
            rightArrowImageView.isHidden = true
            paymentMethodView.semanticContentAttribute = .forceRightToLeft
        } else {
            leftArrowImageView.isHidden = true
        }
    }
    
    func loadData() {
        guard let balance = balance else {
            return
        }
        self.selectedBalanceLabel.text = balance.price
        self.selectedDiscountLabel.text = "+ " + balance.bonus + " " + balance.currency
        self.popularView.isHidden = balance.popular != 1
        self.popularLabel.text = CommonUtils.getStringFromXML(name: "popular_text")
        currentBalanceLabel.text = "+ \(balance.totalPrice) \(balance.currency)"
        subTotalPriceLabel.text = "\(balance.totalBalance) \(balance.currency)"
        totalBalance.text = "+ \(balance.totalBalance) \(balance.currency)"
        discountPriceLabel.text = "\(balance.bonus) \(balance.currency)"
        vatPriceLabel.text = "\(balance.vat) \(balance.currency)"
        totalPriceLabel.text = "\(balance.totalPrice) \(balance.currency)"
        selectedCurrencyLabel.text = CommonUtils.getCurrency()
    }
    
    func bindView() {
        self.viewModel.cards.asObservable().subscribe { [weak self] cards in
            guard let elements = cards.element, let cards = elements else {
                return
            }
            if let defaultCard = cards.first(where: { $0.isDefault == 1 && $0.paymentType != PaymentMethod.cash && $0.paymentType != PaymentMethod.balance }) {
                self?.viewModel.defaultCard = defaultCard
                self?.setDataForDefaultCard(defaultCard: defaultCard)
            } else {
                self?.viewModel.defaultCard = nil
                self?.setDateToSelectCard()
            }
            if self?.viewModel.isShowAddCardView ?? false && cards.count == 0 {
                self?.viewModel.isShowAddCardView = false
                self?.addNewCard()
            }
        }.disposed(by: disposeBag)
    }
    
    func extractClientSecret(from url: URL) -> String? {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for queryItem in queryItems where queryItem.name == "payment_intent_client_secret" {
                if let cpID = queryItem.value {
                    return cpID
                }
            }
        }
        return nil
    }
    
    func webserviceCallForRefillBalance() {
        guard let balance = balance else {
            return
        }
        guard let card = self.viewModel.defaultCard else {
            return
        }
        showHideProgress(show: true)
        NetworkManager().refillBalance(params: ["offer_id": balance.id, "payment_method_id": card.id]) { [weak self] success, message, json in
            self?.showHideProgress(show: false)
            guard let self = self else { return }
            if success == 1 {
                let results = json["data"]
                let nextAction = results["next_action"]
                let type = nextAction["type"].stringValue
                if type == "redirect_to_url" {
                    let redirectURL = nextAction["redirect_to_url"]["url"].stringValue
                    if redirectURL != "" {
                        if let url = URL(string: redirectURL) {
                            if let secret = self.extractClientSecret(from: url) {
                                STPPaymentHandler.shared().confirmPayment(STPPaymentIntentParams(clientSecret: secret), with: self) { status, _, error in
                                    switch status {
                                    case .succeeded:
                                        self.paymentSuccessPopup(message)
                                        let newBalance = results["new_balance"].stringValue
                                        CommonUtils.setCurrentUserBalance(newBalance)
                                        self.loadData()
                                        
                                    case .canceled:
                                        if let errorDesc = error?.localizedDescription {
                                            self.paymentFailedPopup(errorDesc)
                                        }
                                        
                                    case .failed:
                                        if let errorDesc = error?.localizedDescription {
                                            self.paymentFailedPopup(errorDesc)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.paymentSuccessPopup(message)
                    let newBalance = results["new_balance"].stringValue
                    CommonUtils.setCurrentUserBalance(newBalance)
                    self.loadData()
                }
            } else {
                self.showHideProgress(show: false)
                self.paymentFailedPopup(message)
            }
        }
    }

    func paymentSuccessPopup(_ message: String) {
        Task {
            await self.startAnimation()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func paymentFailedPopup(_ message: String) {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
            guard let singlePopup = UIStoryboard(storyboard: .popup).instantiateViewController(withIdentifier: SingleActionPopup.className) as? SingleActionPopup else {
                return
            }
            singlePopup.titleString = CommonUtils.getStringFromXML(name: "payment_failed")
            singlePopup.completionOkay = {
            }
            singlePopup.descriptionString = message
            singlePopup.okButtonString = CommonUtils.getStringFromXML(name: "okay_title")
            self.present(singlePopup, animated: true)
        }
    }
    
    private func showHideProgress(show: Bool) {
        if show {
            agreeContinueButton.showLoading()
            agreeContinueLabel.isHidden = true
            leftArrowImageView.isHidden = true
            rightArrowImageView.isHidden = true
            enableDisableInteraction(enable: false)
        } else {
            agreeContinueButton.hideLoading()
            agreeContinueLabel.isHidden = false
            if isLanguageArabic {
                leftArrowImageView.isHidden = false
            } else {
                rightArrowImageView.isHidden = false
            }
            enableDisableInteraction(enable: true)
        }
    }
    
    @IBAction func didTap(onBackButton sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnChangePaymentMethod(_ sender: Any) {
        CommonUtils.logFacebookCustomEvents("change_payment_method_tap", contentType: ["from": "add_balance"])
        guard let paymentMethodVC = UIStoryboard(storyboard: .payment).instantiateViewController(withIdentifier: PaymentMethodViewController.className) as? PaymentMethodViewController else {
            return
        }
        paymentMethodVC.modalPresentationStyle = .overFullScreen
        if let cards = try? self.viewModel.cards.value() {
            paymentMethodVC.cardArray = cards.filter({ $0.paymentType != PaymentMethod.cash && $0.paymentType != PaymentMethod.balance })
        }
        paymentMethodVC.completionSetDefaultMethod = {card in
            self.viewModel.defaultCard = card
            self.setDataForDefaultCard(defaultCard: card)
        }
        self.present(paymentMethodVC, animated: true, completion: nil)
    }
    
    func setDateToSelectCard() {
        self.paymentMethodTitleLabel.text = CommonUtils.getStringFromXML(name: "select_payment_method")
        self.changeLabel.text = CommonUtils.getStringFromXML(name: "select_title")
    }
    
    func setDataForDefaultCard(defaultCard: Card) {
        self.changeLabel.text = CommonUtils.getStringFromXML(name: "change_title")
        self.selectedMethodLabel.text = ""
        switch defaultCard.paymentType {
        case .cash:
            self.methodImageView.image = UIImage(named: "cash_icon")
            self.paymentMethodTitleLabel.text = CommonUtils.getStringFromXML(name: "cash_on_delivery")
            
        case .payFort:
            if defaultCard.paymentOption == "MADA" {
                self.methodImageView.image = UIImage(named: "madaicon")
            } else {
                self.methodImageView.image = UIImage(named: "creditcard")
            }
            self.paymentMethodTitleLabel.text = defaultCard.paymentOption + " - " + defaultCard.cardNumber
            
        case .pointCheckout:
            self.methodImageView.image = UIImage(named: "epoint_icon")
            self.paymentMethodTitleLabel.text = CommonUtils.getStringFromXML(name: "point_checkout")
            
        case .paypal:
            self.methodImageView.image = UIImage(named: "PayPal-logo")
            self.paymentMethodTitleLabel.text = CommonUtils.getStringFromXML(name: "paypal_title")
            
        case .applePay:
            self.methodImageView.image = UIImage(named: "applepay_icon")
            self.paymentMethodTitleLabel.text = CommonUtils.getStringFromXML(name: "applepay_title")
            
        case .balance:
            self.methodImageView.image = UIImage(named: "balance_icon")
            self.paymentMethodTitleLabel.text = CommonUtils.getStringFromXML(name: "balance_title")
            
        default:
            break
        }
    }

    @IBAction func didTap(onAgreeContinueButton sender: Any) {
        if self.viewModel.defaultCard == nil {
            return
        }
        CommonUtils.logFacebookCustomEvents("agree_continue_refill_balance", contentType: [:])
        webserviceCallForRefillBalance()
    }
    
    func addNewCard() {
        guard let addCard = UIStoryboard(storyboard: .payment).instantiateViewController(withIdentifier: StripeAddPaymentViewController.className) as? StripeAddPaymentViewController else {
            return
        }
        addCard.modalPresentationStyle = .overFullScreen
        addCard.completionToken = {
            self.startAnimation(isCurrentView: true)
            self.viewModel.retrieveCards()
        }
        self.present(addCard, animated: true)
    }
}

extension AddBalanceViewController: PaymentMethodDelegate {
    func didTapOnPaymentMethodView() {
    }
    
    func getDefaultPaymentMethod(card: Card) {
    }
}
