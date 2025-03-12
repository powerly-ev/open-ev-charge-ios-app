//
//  UserRegistrationConfirmPopup.swift
//  PowerShare
//
//  Created by admin on 30/11/21.

//

import UIKit

class UserRegistrationConfirmPopup: UIViewController {
    @objc var mobileNumber: String = ""
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var correctButton: UIButton!
    @IBOutlet weak var viewOut: UIView!
    @IBOutlet weak var descNumberStackView: UIStackView!
    @objc var continueHandler: ()-> Void = {}
    @objc var editHandler: ()-> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        numberLabel.text = mobileNumber
        viewOut.layer.cornerRadius = 8
        viewOut.layer.masksToBounds = true
        showAnimate()
        titleLabel.text = CommonUtils.getStringFromXML(name: "mobile_number_check")
        let value = CommonUtils.getStringFromXML(name: "verifying_number_title")
        let value1 = CommonUtils.getStringFromXML(name: "is_it_correct_title")
        descLabel.text = "\(value)\n\(value1)"
        if isLanguageArabic {
            descLabel.textAlignment = .right
        }
        correctButton.setTitle(CommonUtils.getStringFromXML(name: "correct_title"), for: .normal)
    }
    
    func initFont() {
        titleLabel.font = .robotoMedium(ofSize: 16)
        descLabel.font = .robotoRegular(ofSize: 18)
        numberLabel.font = .robotoBold(ofSize: 18)
        correctButton.titleLabel?.font = .robotoMedium(ofSize: 16)
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
    
    @IBAction func didTap(onCorrectButton sender: Any) {
        continueHandler()
        removeFadeAway()
    }

    @IBAction func didTap(onEditButton sender: Any) {
        editHandler()
        removeFadeAway()
    }

}
