//
//  PaymentFailedPopUP.swift
//  PowerShare
//
//  Created by admin on 07/01/22.
//  
//

import UIKit

class PaymentFailedPopUP: UIViewController {
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var okayButton: UIButton!
    var headerString: String = ""
    var errorMessage: String = ""
    var sendDataPaymentFailedOkay: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUIColor()
        outView.layer.cornerRadius = 8
        outView.layer.masksToBounds = true
        showAnimate()

        okayButton.setTitle(CommonUtils.getStringFromXML(name: "options_Ok"), for: .normal)
        descLabel.text = CommonUtils.getStringFromXML(name: "payment_method_failed")
        dateLabel.text = CommonUtils.getStringFromXML(name: "payment_method_cash")
        headerLabel.text = headerString
        topView.addDropshadowtoVIEW()
        if isLanguageArabic {
            descLabel.textAlignment = .right
            dateLabel.textAlignment = .right
        } else {
            descLabel.textAlignment = .left
            dateLabel.textAlignment = .left
        }
    }
    
    func initUIColor() {
        headerLabel.textColor = UIColor(named: "HEADER_TEXT")
        descLabel.textColor = UIColor(named: "HEADER_TEXT")
        dateLabel.textColor = UIColor(named: "HEADER_TEXT")
        okayButton.backgroundColor = UIColor(named: "APP_MAIN")
    }
    
    func showAnimate() {
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: { [self] in
            view.alpha = 1
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    func removeFadeAway() {
        UIView.animate(withDuration: 0.25, animations: { [self] in
            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            view.alpha = 0
        }) { [self] finished in
            view.removeFromSuperview()
            dismiss(animated: true) {

            }
        }
    }
    
    @IBAction func didTap(onOkayButton sender: Any) {
        self.sendDataPaymentFailedOkay?()
        removeFadeAway()
    }

}
