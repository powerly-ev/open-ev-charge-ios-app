//
//  EVMeterViewController.swift
//  PowerShare
//
//  Created by admin on 05/05/23.
//  
//
import Combine
import KDCircularProgress
import SwiftyJSON
import UIKit

class EVMeterViewController: UIViewController {
    @IBOutlet weak var progressView: KDCircularProgress!
    var activeSession: ActiveSession!
    @IBOutlet weak var chargingLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var wattLabel: UILabel!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var chargedTitleLabel: UILabel!
    @IBOutlet weak var chargedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    
    @IBOutlet weak var subTitleView: UIView!
    @IBOutlet weak var subValueView: UIView!
    @IBOutlet weak var subPriceTitleLabel: UILabel!
    @IBOutlet weak var priceValueLabel: UILabel!
    @IBOutlet weak var feesTitleLabel: UILabel!
    @IBOutlet weak var feesValueLabel: UILabel!
    
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var subTitleStackView: UIStackView!
    @IBOutlet weak var valueStackView: UIStackView!
    @IBOutlet weak var subValueStackView: UIStackView!
    var timer: Timer?
    var timerToCallOrderDetailsAPI: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initFont()
        initProgress()
        displayData()
        displayTotalTime()

        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
            self.displayTotalTime()
        })
        
        timerToCallOrderDetailsAPI = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
            self.callApi()
        })
        if activeSession.requestedQuantity == "FULL" {
            self.startBlink()
        } else {
            self.startBlinkProgressBar()
        }
        callApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        timer?.invalidate()
    }
    
    @objc func applicationDidBecomeActive() {
        callApi()
    }
    
    func callApi() {
        NetworkManager().getSessionByOrderId(orderId: activeSession.id) { _, _, session in
            if let session = session {
                self.activeSession = session
                self.displayData()
                if session.status == OrderStatus.completed.rawValue {
                    self.dismissMeterScreen(selection: .past)
                }
            }
        }
    }
    
    func initUI() {
        if isLanguageArabic {
            totalView.semanticContentAttribute = .forceRightToLeft
            titleStackView.alignment = .trailing
            valueStackView.alignment = .leading
            subTitleStackView.alignment = .trailing
            subValueStackView.alignment = .leading
        }
        feesTitleLabel.isHidden = true
        feesValueLabel.isHidden = true
    }
    
    func initFont() {
        stationLabel.font = .robotoMedium(ofSize: 18)
        wattLabel.font = .robotoMedium(ofSize: 48)
        priceTitleLabel.font = .robotoMedium(ofSize: 16)
        subPriceTitleLabel.font = .robotoRegular(ofSize: 14)
        feesTitleLabel.font = .robotoRegular(ofSize: 14)
        chargedTitleLabel.font = .robotoMedium(ofSize: 16)
        timeLabel.font = .robotoMedium(ofSize: 16)
        chargingLabel.font = .robotoMedium(ofSize: 16)
        priceLabel.font = .robotoMedium(ofSize: 16)
        priceValueLabel.font = .robotoRegular(ofSize: 14)
        feesValueLabel.font = .robotoRegular(ofSize: 14)
        chargedLabel.font = .robotoMedium(ofSize: 16)
        timeValueLabel.font = .robotoMedium(ofSize: 16)
    }
    
    func initProgress() {
        progressView.startAngle = 0
        progressView.progressThickness = 0.15
        progressView.progress = 0
        progressView.trackThickness = 0.3
        progressView.clockwise = true
        progressView.gradientRotateSpeed = 2
        progressView.roundedCorners = false
        progressView.glowMode = .constant
        progressView.glowAmount = 1.0
        progressView.trackColor = #colorLiteral(red: 0.9490196078, green: 0.9803921569, blue: 1, alpha: 1)
        progressView.set(colors: #colorLiteral(red: 0, green: 0.6, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.6, blue: 1, alpha: 0.75), #colorLiteral(red: 0, green: 0.6, blue: 1, alpha: 0.5), #colorLiteral(red: 0, green: 0.6, blue: 1, alpha: 0.24))
        progressView.center = CGPoint(x: view.center.x, y: view.center.y + 25)
    }
    
    func displayData() {
        guard let chargePoint = activeSession.chargePoint else {
            return
        }
        stationLabel.text = NSLocalizedString("station", comment: "") + " #\(chargePoint.id)"
        feesValueLabel.text = String(format: "%.1f %@", activeSession.appFees, CommonUtils.getCurrency())
        
        self.priceLabel.text = String(format: "%@ %@", activeSession.price.formatted(), CommonUtils.getCurrency())
        self.priceValueLabel.text = String(format: "%@ %@", activeSession.price.formatted(), CommonUtils.getCurrency())
        self.chargedLabel.text = activeSession.chargingSessionEnergy.formatted()
    }
    
    func dismissMeterScreen(selection: MyOrderSelection) {
        self.dismiss(animated: true) {
            if let tabVC = CommonUtils.getTabBarView() {
                tabVC.selectedIndex = 2
                if let navVC = tabVC.viewControllers?.value(at: 2) as? UINavigationController {
                    if let myOrderVC = navVC.viewControllers.first as? MyOrderViewController {
                        myOrderVC.viewModel.updateSelection(selection: selection)
                        guard let controller = UIStoryboard(storyboard: .order).instantiateViewController(withIdentifier: UserFeedBackFormViewController.className) as? UserFeedBackFormViewController else {
                            return
                        }
                        let viewModel = FeedbackViewModel(session: self.activeSession)
                        viewModel.orderID = self.activeSession.id
                        controller.viewModel = viewModel
                        controller.modalPresentationStyle = .overFullScreen
                        navVC.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func startBlink() {
        self.progressView.animate(fromAngle: 0, toAngle: 360, duration: 1) { _ in
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.progressView.alpha = 0.0
            }) { _ in
                UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
                    self.progressView.alpha = 1.0
                }) { _ in
                    self.progressView.progress = 0.0
                    self.startBlink()
                }
            }
        }
    }
    
    func startBlinkProgressBar() {
        UIView.animate(withDuration: 1.0, // Animation duration for each fade
                               delay: 0.0,
                               options: [.curveEaseIn],
                               animations: {
                    self.progressView.alpha = (self.progressView.progress > 0.1) ? 0:1
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, // Animation duration for each fade
                                   delay: 0.0,
                                   options: [.curveEaseIn],
                                   animations: {
                        self.progressView.alpha = 1.0
            }, completion: { _ in
                self.startBlinkProgressBar()
            })
        })
    }
    
    func displayTotalTime() {
        guard let insertDate = activeSession.createdAt.stringToDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", timeZone: TimeZone(identifier: "UTC")) else {
            return
        }

        let difference:(hours: Int, minutes: Int, seconds: Int)
        if let sessionTime = Int(activeSession.requestedQuantity), sessionTime > 0 {
            difference = CommonUtils.getTimeDifference(startDate: Date(), endDate: insertDate.addingTimeInterval(TimeInterval(sessionTime*60)))
        } else {
            difference = CommonUtils.getTimeDifference(startDate: insertDate, endDate: Date())
        }
        
        let time: String
        if difference.hours > 0 {
            time = "\(difference.hours)h \(difference.minutes)m"
        } else if difference.minutes > 0 {
            time = "\(difference.minutes)m"
        } else if difference.seconds > 0 {
            time = "\(difference.seconds)s"
        } else {
            time = "0"
        }
        
        if let sessionTime = Int(activeSession.requestedQuantity), sessionTime > 0 {
            let minutesPassed = ((difference.hours * 60) + (difference.minutes) + (difference.seconds / 60))
            let percentage = Double(minutesPassed) / Double(sessionTime)
            self.progressView.progress = min(1.0, percentage)
            
            wattLabel.text = time
            timeValueLabel.text = String(format: "%ld min", sessionTime)
        } else {
            wattLabel.text = time
            timeValueLabel.text = time
        }
    }

    @IBAction func didTapOnPriceButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        subTitleView.isHidden = !sender.isSelected
        subValueView.isHidden = !sender.isSelected
    }

    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnStopCharging(_ sender: Any) {
        guard let chargePoint = activeSession.chargePoint else {
            return
        }
        let id = chargePoint.id
        self.showDialogue(title: NSLocalizedString("stop_charging", comment: ""), description: NSLocalizedString("stop_charging_note", comment: "")) { success in
            if success {
                CommonUtils.showProgressHud()
                NetworkManager().stopTransaction(id: id, orderId: self.activeSession.id) { success, message, json in
                    CommonUtils.hideProgressHud()
                    if success == 1 {
                        self.dismissMeterScreen(selection: .past)
                    } else {
                        TSMessage.showNotification(in: self, title: "", subtitle: message, type: .error)
                    }
                }
            }
        }
    }
}
