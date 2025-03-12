//
//  CurrentPastOrderDetailViewController.swift
//  PowerShare
//
//  Created by admin on 03/03/22.
//  
//

import UIKit

class CurrentPastOrderDetailViewController: UIViewController {
    var session: ActiveSession?
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deliveryAddressTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var paymentTitleLabel: UILabel!
    @IBOutlet weak var paymentMethodImageView: UIImageView!
    @IBOutlet weak var topDetailView: UIView!
   
    @IBOutlet weak var paymentStackView: UIStackView!
    @IBOutlet weak var orderStatusView: UIView!
    @IBOutlet weak var orderStatusMainView: UIStackView!
    @IBOutlet weak var orderStatusStackView: UIStackView!
    var subtotalArray = [SubTotal]()
    var isFromCurrent = false
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        tableView.register(UINib(nibName: ConfirmFeesCell.className, bundle: nil), forCellReuseIdentifier: ConfirmFeesCell.className)
        initLoadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentingViewController?.viewWillDisappear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presentingViewController?.viewWillAppear(true)
    }
    
    func initFont() {
        orderIdLabel.font = .robotoMedium(ofSize: 14)
        statusLabel.font = .robotoMedium(ofSize: 12)
        dateLabel.font = .robotoMedium(ofSize: 12)
        timeLabel.font = .robotoMedium(ofSize: 12)
        deliveryAddressTitleLabel.font = .robotoMedium(ofSize: 16)
        addressLabel.font = .robotoRegular(ofSize: 14)
        paymentTitleLabel.font = .robotoMedium(ofSize: 16)
    }
    
    func initLoadData() {
        deliveryAddressTitleLabel.text = CommonUtils.getStringFromXML(name: "delivery_address")
        paymentTitleLabel.text = CommonUtils.getStringFromXML(name: "paymentMethod_title")
        guard let session = session else {
            return
        }
        // invoiceButton.isHidden = order.invoice_link == ""
        let orderIdAttributed = NSMutableAttributedString()
        orderIdAttributed.custom(CommonUtils.getStringFromXML(name: "ID_order"), font: .robotoMedium(ofSize: 14), color: UIColor(named: "222222") ?? .black)
        orderIdAttributed.custom(" \(session.id)", font: .robotoMedium(ofSize: 14), color: UIColor(named: "7A7A7A") ?? .black)
        self.orderIdLabel.attributedText = orderIdAttributed
        // self.invoiceButton.isHidden = order.status != 2
        switch OrderStatus(rawValue: session.status) {
        case .open:
            statusLabel.text = NSLocalizedString("Open", comment: "")
        
        case .completed:
            statusLabel.text = NSLocalizedString("Completed", comment: "")
        
        default:
            break
        }
        
        if let date = session.deliveryDate.stringToDate(format: "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone(identifier: "UTC")) {
            dateLabel.text = date.string(format: "yyyy-MM-dd")
            self.timeLabel.text = date.string(format: "hh:mm a")
        }
        if let address = session.chargePoint?.address {
            self.addressLabel.text = CommonUtils.getFullAddress(from: address)
        } else {
            self.addressLabel.text = ""
        }
        self.paymentMethodImageView.image = UIImage(named: "balance_icon")
        self.paymentTitleLabel.text = CommonUtils.getStringFromXML(name: "balance_title")
        
        subtotalArray = [SubTotal]()
        if let prices = session.prices {
            if prices.count == 1, let price = prices.first {
                subtotalArray.append(SubTotal(name: CommonUtils.getStringFromXML(name: "product_title"), type: .productPrice, price: String(format: "%.2f %@/%@ X %@", price.price, CommonUtils.getCurrency(), session.unit.getPriceUnitName(), quantityInMinutes(session: session))))
            } else {
                if let lowestPrice = prices.min(by: { $0.price < $1.price })?.price,
                   let highestPrice = prices.max(by: { $0.price < $1.price })?.price {
                    subtotalArray.append(SubTotal(name: CommonUtils.getStringFromXML(name: "product_title"), type: .productPrice, price: String(format: "%.2f-%.2f %@/%@ X %@", lowestPrice, highestPrice, CommonUtils.getCurrency(), session.unit.getPriceUnitName(), quantityInMinutes(session: session))))
                }
            }
        }
        
        //subtotalArray.append(SubTotal(name: NSLocalizedString("app_fees", comment: ""), type: .deliveryFees, price: session.appFees.description))
        subtotalArray.append(SubTotal(name: CommonUtils.getStringFromXML(name: "total_title"), type: .total, price: session.price.description))
        if isLanguageArabic {
            deliveryAddressTitleLabel.textAlignment = .right
            addressLabel.textAlignment = .right
            paymentTitleLabel.textAlignment = .right
            // paymentDetailStackView.alignment = .trailing
            topDetailView.semanticContentAttribute = .forceRightToLeft
            orderStatusView.semanticContentAttribute = .forceRightToLeft
            orderStatusStackView.semanticContentAttribute = .forceRightToLeft
            orderStatusMainView.alignment = .trailing
            paymentStackView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func convertToHoursMinutesAndSeconds(_ decimalMinutes: Double) -> String {
        let totalSeconds = Int(decimalMinutes * 60)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return hours > 0 ? "\(hours) h \(minutes) m \(seconds) s":"\(minutes) m \(seconds) s"
    }

    // Update quantityInMinutes to use the new function
    func quantityInMinutes(session: ActiveSession) -> String {
        if let priceUnit = PriceUnit(rawValue: session.unit) {
            switch priceUnit {
            case .energy:
                return session.quantity
            case .minutes:
                return convertToHoursMinutesAndSeconds(Double(session.quantity) ?? 0)
            }
        }
        return ""
    }

    @IBAction func didTapOnInvoiceButton(_ sender: Any) {
    }
    
    @IBAction func didTapOnClosebutton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
}

extension CurrentPastOrderDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subtotalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConfirmFeesCell.className) as? ConfirmFeesCell else {
            return UITableViewCell()
        }
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        let total = subtotalArray[indexPath.row]
        cell.setSubTotal(total: total)
        return cell
    }
}
