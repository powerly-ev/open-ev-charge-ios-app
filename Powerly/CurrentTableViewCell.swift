//
//  CurrentTableViewCell.swift
//  PowerShare
//
//  Created by admin on 27/12/22.
//  
//

import UIKit

class CurrentTableViewCell: UITableViewCell {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceStackView: UIStackView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var leftButtonView: UIView!
    @IBOutlet weak var leftIconView: UIImageView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var leftActionButton: UIButton!
    
    @IBOutlet weak var ratingView: StarRatingView!
    @IBOutlet weak var checkMarkIcon: UIImageView!
    @IBOutlet weak var dollarStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        orderIdLabel.font = .robotoMedium(ofSize: 14)
        statusLabel.font = .robotoMedium(ofSize: 12)
        priceLabel.font = .robotoBold(ofSize: 14)
        currencyLabel.font = .robotoMedium(ofSize: 14)
        
        if isLanguageArabic {
            priceStackView.semanticContentAttribute = .forceRightToLeft
            headerView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func setUpSession(session: ActiveSession) {
        guard let chargePoint = session.chargePoint else {
            leftButtonView.isHidden = true
            titleLabel.text = ""
            currencyLabel.text = ""
            priceLabel.text = ""
            dollarStackView.isHidden = true
            statusView.isHidden = true
            ratingView.rating = 0
            //TODO: set here default value
            return
        }
        dollarStackView.isHidden = false
        orderIdLabel.text = NSLocalizedString("order_id", comment: "") + " " + session.id.description
        var countedPrice = session.price
        if session.requestedQuantity == "FULL" && chargePoint.priceUnit == "minutes" && session.status == 0 {
            guard let insertDate = session.createdAt.stringToDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", timeZone: TimeZone(identifier: "UTC")) else {
                return
            }
            let totalMinutes = CommonUtils.getTimeDifferenceInMinutes(startDate: insertDate, endDate: Date())
            countedPrice = session.price * Float(totalMinutes)
        }
        let fees = countedPrice+session.appFees
        priceLabel.text = String(format: "%@ %.2f", NSLocalizedString("total", comment: ""), fees)
        currencyLabel.text = CommonUtils.getCurrency()
        titleLabel.text = chargePoint.title
        statusLabel.text = NSLocalizedString("charging", comment: "")
        if session.status == 1 {
            leftButtonView.backgroundColor = UIColor(named: "F3F3F3")
            leftLabel.text = NSLocalizedString("recharge", comment: "")
            leftLabel.textColor = UIColor(named: "222222")
            leftIconView.isHidden = false
            leftButtonView.isHidden = false
            
            if let date = session.deliveryDate.stringToDate(format: "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone(identifier: "UTC")) {
                statusLabel.text = date.string(format: "yyyy-MM-dd")
            }
            
            statusLabel.textColor = UIColor(named: "7A7A7A")
            checkMarkIcon.isHidden = false
            statusIcon.isHidden = true
            statusView.borderWidth = 0
        } else {
            leftButtonView.backgroundColor = UIColor(named: "CANCEL_TEXT")
            leftLabel.text = NSLocalizedString("stop_charging", comment: "")
            leftLabel.textColor = UIColor(named: "WHITE")
            leftIconView.isHidden = true
            leftButtonView.isHidden = false
            
            statusView.borderColor = UIColor(named: "008CE9")
            statusLabel.textColor = UIColor(named: "008CE9")
            statusView.borderWidth = 1.0
            checkMarkIcon.isHidden = true
            statusIcon.isHidden = false
        }
        ratingView.rating = chargePoint.rating
    }
}

