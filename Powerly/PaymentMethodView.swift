//
//  PaymentMethodView.swift
//  PowerShare
//
//  Created by admin on 04/03/22.
//  
//
import SwiftyJSON
import UIKit

protocol PaymentMethodDelegate: Any {
    func didTapOnPaymentMethodView()
    func getDefaultPaymentMethod(card: Card)
}

class PaymentMethodView: UIView {
    @IBOutlet weak var methodImageView: UIImageView!
    @IBOutlet weak var paymentMethodTitleLabel: UILabel!
    @IBOutlet weak var selectedMethodLabel: UILabel!
    @IBOutlet weak var paymentMethodView: UIView!
    @IBOutlet var dropDownArrow: UIImageView!
    @IBOutlet var changeLabel: UILabel!
    
    var isForBalance = false
    var orderId: String?
    var completionSetDefaultMethod: ((Card)->Void)?
    var delegate: PaymentMethodDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
    }
    
    fileprivate func xibSetup() {
        self.loadViewFromNib()
        self.backgroundColor = UIColor.clear
        //paymentMethodTitleLabel.text = CommonUtils.getStringFromXML(name: "paymentMethod_title")
        if isLanguageArabic {
            paymentMethodView.semanticContentAttribute = .forceRightToLeft
        }
        self.changeLabel.font = .robotoMedium(ofSize: 12)
        self.paymentMethodTitleLabel.font = .robotoMedium(ofSize: 14)
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
    
    func setDateToSelectCard() {
        self.paymentMethodTitleLabel.text = CommonUtils.getStringFromXML(name: "select_payment_method")
        self.changeLabel.text = CommonUtils.getStringFromXML(name: "select_title")
    }
    
    
    @IBAction func didTapOnPaymentMethodView(_ sender: Any) {
        delegate?.didTapOnPaymentMethodView()
    }
}
