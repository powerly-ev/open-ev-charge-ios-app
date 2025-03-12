//
//  ShowBalanceTableViewCell.swift
//  PowerShare
//
//  Created by admin on 10/01/22.
//  
//

import UIKit

class ShowBalanceTableViewCell: UITableViewCell {
    @IBOutlet var outView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet weak var popularView: UIView!
    @IBOutlet var popularLabel: UILabel!
    @IBOutlet var notAvailableNowView: UIView!
    @IBOutlet var notAvailableNowLabel: UILabel!
    @IBOutlet weak var bonusView: UIView!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet var priceCurrencyStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .robotoRegular(ofSize: 12)
        priceLabel.font = .robotoLight(ofSize: 28)
        currencyLabel.font = .robotoBold(ofSize: 16)
        popularLabel.font = .robotoMedium(ofSize: 12)
        bonusLabel.font = .robotoMedium(ofSize: 12)
        notAvailableNowLabel.font = .robotoRegular(ofSize: 12)
        notAvailableNowLabel.text = CommonUtils.getStringFromXML(name: "not_available")
        notAvailableNowView.layer.cornerRadius = 5
        notAvailableNowView.addDropshadowtoVIEW()
        if isLanguageArabic {
            outView.semanticContentAttribute = .forceRightToLeft
            priceCurrencyStackView.semanticContentAttribute = .forceRightToLeft
        }
        bonusView.isHidden = true
    }


}
