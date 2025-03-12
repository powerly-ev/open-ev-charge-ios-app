//
//  PaymentMethodTableViewCell.swift
//  PowerShare
//
//  Created by admin on 28/02/22.
//  
//

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {
    @IBOutlet weak var defaultMethodView: UIView?
    @IBOutlet weak var defaultLabel: UILabel?
    @IBOutlet weak var methodImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var menuIcon: UIButton!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var titleStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        defaultLabel?.font = .robotoRegular(ofSize: 12)
        titleLabel.font = .robotoMedium(ofSize: 16)
        subTitleLabel.font = .robotoRegular(ofSize: 14)
        addLabel.font = .robotoRegular(ofSize: 14)
        defaultLabel?.text = CommonUtils.getStringFromXML(name: "default_method")
        addLabel.text = CommonUtils.getStringFromXML(name: "plus_add_title")
        if isLanguageArabic {
            outView.semanticContentAttribute = .forceRightToLeft
            titleStackView.alignment = .trailing
        }
    }
    
    func setupWallet(wallet: Wallet) {
        titleLabel.text = wallet.name
        subTitleLabel.text = wallet.balance + " " + CommonUtils.getCurrency()
        addView.isHidden = true
        defaultMethodView?.isHidden = true
        menuIcon.isHidden = !wallet.withdrawable
        menuIcon.setImage(UIImage(named: "radio_fill_big"), for: .normal)
        methodImageView.image = UIImage(named: "cash_icon")
    }
}
