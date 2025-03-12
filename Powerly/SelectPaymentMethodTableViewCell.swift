//
//  SelectPaymentMethodTableViewself.swift
//  PowerShare
//
//  Created by admin on 04/03/22.
//  
//

import UIKit

class SelectPaymentMethodTableViewCell: UITableViewCell {
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var radioImageView: UIImageView!
    @IBOutlet weak var methodImageView: UIImageView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var titleStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        paymentMethodLabel.font = .robotoMedium(ofSize: 16)
        subTitleLabel.font = .robotoMedium(ofSize: 13)
        if isLanguageArabic {
            titleStackView.alignment = .trailing
        }
    }

    func setPaymentCard(card: Card) {
        if card.isDefault == 1 {
            radioImageView.image = UIImage(named: "right_checkmark")
        } else {
            radioImageView.image = nil
        }
        self.subTitleLabel.text = ""
        self.addView.isHidden = true
        switch card.paymentType {
        case .cash:
            self.methodImageView.image = UIImage(named: "cash_icon")
            self.paymentMethodLabel.text = CommonUtils.getStringFromXML(name: "cash_on_delivery")
            
        case .payFort:
            if card.paymentOption == "MADA" {
                self.methodImageView.image = UIImage(named: "madaicon")
                self.paymentMethodLabel.text = CommonUtils.getStringFromXML(name: "mada_card_title")
                self.subTitleLabel.text = "************\(card.cardNumber)"
                //self.subpaymentMethodLabel.text = "************\(cardNumber)"
                //selfMada.madaTextArabicLabel?.text = CommonUtils.getStringFromXML(name: "mada_card_title")
            } else {
                self.methodImageView?.image = UIImage(named: "creditcard")
                self.paymentMethodLabel.text = card.paymentOption
                self.subTitleLabel.text = "************\(card.cardNumber)"
                //self.subpaymentMethodLabel.text = "************\(cardNumber)"
            }
            
        case .pointCheckout:
            self.methodImageView.image = UIImage(named: "epoint_icon")
            self.paymentMethodLabel.text = CommonUtils.getStringFromXML(name: "point_checkout")
            
        case .paypal:
            self.methodImageView.image = UIImage(named: "PayPal-logo")
            self.paymentMethodLabel.text = CommonUtils.getStringFromXML(name: "paypal_title")
            
        case .applePay:
            self.methodImageView.image = UIImage(named: "applepay_icon")
            self.paymentMethodLabel.text = CommonUtils.getStringFromXML(name: "applepay_title")
            
        case .balance:
            self.methodImageView.image = UIImage(named: "balance_icon")
            self.paymentMethodLabel.text = CommonUtils.getStringFromXML(name: "balance_title")
            self.subTitleLabel.text = String(format: "%.2f", CommonUtils.getCurrentUserBalance()) + " " + CommonUtils.getCurrency()
            self.addLabel.text = CommonUtils.getStringFromXML(name: "plus_add_title")
            self.addView.isHidden = false
            
        default:
            break
        }
    }

}
