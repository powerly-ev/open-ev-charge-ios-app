//
//  ConfirmFeesCell.swift
//  PowerShare
//
//  Created by admin on 18/02/22.
//  
//

import UIKit

class ConfirmFeesCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var topSaparator: UIView!
    @IBOutlet weak var bottomSaparator: UIView!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var closeIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isLanguageArabic {
            outView.semanticContentAttribute = .forceRightToLeft
        }
    }

    func setSubTotal(total: SubTotal) {
        let type = total.type
        if type == .total {
            self.topSaparator.isHidden = true
            self.bottomSaparator.isHidden = true
            self.titleLabel.font = .robotoBold(ofSize: 14)
            self.titleLabel.textColor = UIColor(named: "222222")
            self.priceLabel.font = .robotoBold(ofSize: 14)
            self.priceLabel.textColor = UIColor(named: "222222")
        } else {
            self.topSaparator.isHidden = true
            self.bottomSaparator.isHidden = true
            self.titleLabel.font = .robotoRegular(ofSize: 14)
            self.titleLabel.textColor = UIColor(named: "7A7A7A")
            self.priceLabel.font = .robotoRegular(ofSize: 14)
            self.priceLabel.textColor = UIColor(named: "7A7A7A")
        }
        titleLabel.text = total.name
        if type == .discount {
            priceLabel.text = "-" + total.price + " " + CommonUtils.getCurrency()
        } else {
            priceLabel.text = total.price
        }
       
        closeIcon.isHidden = total.type != .installationFees
    }
    
    func setSubTotalFromInvoice(total: SubTotal) {
        let type = total.type
        if type == .total {
            self.topSaparator.isHidden = false
            self.bottomSaparator.isHidden = false
            self.titleLabel.font = .robotoBold(ofSize: 14)
            self.titleLabel.textColor = UIColor(named: "222222")
        } else {
            self.topSaparator.isHidden = true
            self.bottomSaparator.isHidden = true
            self.titleLabel.font = .robotoRegular(ofSize: 14)
            self.titleLabel.textColor = UIColor(named: "7A7A7A")
        }
        titleLabel.text = total.name
        
        let priceAttributed = NSMutableAttributedString().normal(String(format: "%@", total.price), color: UIColor(named: "7A7A7A"))
         priceAttributed.colorRange(value: total.price, color: UIColor(named: "222222") ?? .black)
         priceLabel.attributedText = priceAttributed
    }
    
}
