//
//  AddDeviceIDViewController.swift
//  PowerShare
//
//  Created by ADMIN on 10/07/23.
//  
//
import JVFloatLabeledTextField
import UIKit

class AddDeviceIDViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet weak var ssidTextField: JVFloatLabeledTextField!
    
    var identifier: String?
    var completionDeviceId: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        showAnimate()
        
        okButton.layer.borderWidth = 1
        viewMain.layer.cornerRadius = 5
        viewMain.layer.masksToBounds = true
    }
    
    func initUI() {
        okButton.setTitle(CommonUtils.getStringFromXML(name: "continue"), for: .normal)
        lblHeader.font = .robotoMedium(ofSize: 16)
        passwordLabel.font = .robotoRegular(ofSize: 16)
        okButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        ssidTextField.text = identifier ?? ""
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
            dismiss(animated: true)
        }
    }
    
    @IBAction func didTap(onOKButton sender: Any) {
        guard let ssid = ssidTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) else {
            return
        }
        
        ssidTextField.text = ssid
        if ssid != "" {
            completionDeviceId?(ssid)
            removeFadeAway()
        }
    }

    @IBAction func didTap(onCloseButton sender: Any) {
        removeFadeAway()
    }
}
