//
//  CurrentPastOrderTableViewCell.swift
//  PowerShare
//
//  Created by admin on 11/01/22.
//  
//

import UIKit

class CurrentPastOrderTableViewCell: UITableViewCell {
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var orderdetailInvoiceParentStackView: UIStackView!
    @IBOutlet weak var orderDetailStackView: UIStackView!
    @IBOutlet weak var invoiceButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        invoiceButton.setTitle("$ \(CommonUtils.getStringFromXML(name: "invoice_title"))", for: .normal)
        if isLanguageArabic {
            orderDetailStackView.alignment = UIStackView.Alignment.trailing
            orderdetailInvoiceParentStackView.insertArrangedSubview(invoiceButton, at: 0)
            orderdetailInvoiceParentStackView.insertArrangedSubview(orderDetailStackView, at: 1)
        } else {
            orderDetailStackView.alignment = UIStackView.Alignment.leading
            orderdetailInvoiceParentStackView.insertArrangedSubview(orderDetailStackView, at: 0)
            orderdetailInvoiceParentStackView.insertArrangedSubview(invoiceButton, at: 1)
        }
    }
}
