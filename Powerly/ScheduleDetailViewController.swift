//
//  ScheduleDetailViewController.swift
//  PowerShare
//
//  Created by ADMIN on 23/10/23.
//  
//

import UIKit

class ScheduleDetailViewController: UIViewController {
    var reservation: Reservation?
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deliveryAddressTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var paymentTitleLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editMenuView: UIView!
    @IBOutlet weak var paymentMethodImageView: UIImageView!
    @IBOutlet weak var balanceStackView: UIStackView!
    @IBOutlet weak var topDetailView: UIView!
    // to manage arabic layout
    @IBOutlet weak var orderStatusView: UIView!
    @IBOutlet weak var orderStatusMainView: UIStackView!
    @IBOutlet weak var orderStatusStackView: UIStackView!
    var subtotalArray = [SubTotal]()
    
    var completionCancelBooking:(() -> Void)?
    var completionStartCharging:(() -> Void)?
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
        startButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        cancelButton.titleLabel?.font = .robotoMedium(ofSize: 16)
    }
    
    func initLoadData() {
        deliveryAddressTitleLabel.text = CommonUtils.getStringFromXML(name: "delivery_address")
        paymentTitleLabel.text = CommonUtils.getStringFromXML(name: "paymentMethod_title")
        guard let reservation = reservation else {
            return
        }
        //invoiceButton.isHidden = order.invoice_link == ""
        let orderIdAttributed = NSMutableAttributedString()
        orderIdAttributed.custom(NSLocalizedString("booking_id", comment: ""), font: .robotoMedium(ofSize: 14), color: UIColor(named: "222222") ?? .black)
        orderIdAttributed.custom(" \(reservation.id)", font: .robotoMedium(ofSize: 14), color: UIColor(named: "7A7A7A") ?? .black)
        self.orderIdLabel.attributedText = orderIdAttributed
        //self.invoiceButton.isHidden = order.status != 2
        statusLabel.text = NSLocalizedString("scheduled", comment: "")
        
        if let date = reservation.reservationDatetime.stringToDate(format: "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone(identifier: "UTC")) {
            dateLabel.text = date.string(format: "yyyy-MM-dd")
            self.timeLabel.text = date.string(format: "hh:mm a")
        }
        if let address = reservation.chargePoint?.address {
        
            self.addressLabel.text = CommonUtils.getFullAddress(from: address)
        } else {
            self.addressLabel.text = ""
        }
        self.paymentMethodImageView.image = UIImage(named: "balance_icon")
        self.paymentTitleLabel.text = CommonUtils.getStringFromXML(name: "balance_title")
        
        guard let chargePoint = reservation.chargePoint else {
            return
        }
        let quantity = reservation.quantity == "FULL" ? reservation.quantity:"\(reservation.quantity) \(reservation.chargePoint?.priceUnit ?? "")"
        subtotalArray = [SubTotal]()
        subtotalArray.append(SubTotal(name: NSLocalizedString("station_id", comment: ""), type: .productPrice, price: String(format: "# %@", chargePoint.id)))
        subtotalArray.append(SubTotal(name: NSLocalizedString("Price", comment: ""), type: .productPrice, price: String(format: "%.2f %@/%@", chargePoint.price, CommonUtils.getCurrency(), chargePoint.priceUnit.getPriceUnitName())))
        subtotalArray.append(SubTotal(name: NSLocalizedString("booked_slot", comment: ""), type: .productPrice, price: String(format: "%@", quantity)))
        subtotalArray.append(SubTotal(name: NSLocalizedString("reservation_fees", comment: ""), type: .productPrice, price: String(format: "%.2f", chargePoint.reservationFee)))
        cancelButton.setTitle(NSLocalizedString("cancel_booking", comment: ""), for: .normal)
        if let userId = UserManager.shared.user?.id, reservation.userId != userId {
            self.editMenuView.isHidden = true
        }
        if isLanguageArabic {
            deliveryAddressTitleLabel.textAlignment = .right
            addressLabel.textAlignment = .right
            paymentTitleLabel.textAlignment = .right
            topDetailView.semanticContentAttribute = .forceRightToLeft
            orderStatusView.semanticContentAttribute = .forceRightToLeft
            orderStatusStackView.semanticContentAttribute = .forceRightToLeft
            orderStatusMainView.alignment = .trailing
            balanceStackView.semanticContentAttribute = .forceRightToLeft
        }
    }

    @IBAction func didTapOnInvoiceButton(_ sender: Any) {
    }
    
    @IBAction func didTapOnClosebutton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func didTapOnCancelButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.completionCancelBooking?()
        }
    }
    
    @IBAction func didTapOnStartButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.completionStartCharging?()
        }
    }
}

extension ScheduleDetailViewController: UITableViewDelegate, UITableViewDataSource {
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
