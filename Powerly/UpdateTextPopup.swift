//
//  UpdateTextPopup.swift
//  PowerShare
//
//  Created by ADMIN on 11/08/23.
//  
//

import UIKit

class UpdateTextPopup: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var applyButton: SpinnerButton!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var lblHeader: UILabel!
    
    var titleStr: String = ""
    var completion: ((String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.font = .robotoMedium(ofSize: 18)
        txtCode.font = .robotoRegular(ofSize: 14)
        applyButton.titleLabel?.font = .robotoMedium(ofSize: 18)
        txtCode.delegate = self
        
        if isLanguageArabic {
            txtCode.textAlignment = .right
        } else {
            txtCode.textAlignment = .left
        }
        txtCode.text = titleStr
        txtCode.becomeFirstResponder()
    }
    
    func removeFadeAway() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: { [self] in
            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            view.alpha = 0
        }) { [self] _ in
            dismiss(animated: true)
        }
    }
    
    @IBAction func didTapApplyButton(sender: Any) {
        if let code = txtCode.text, code != "" {
            self.dismiss(animated: true) {
                self.completion?(code)
            }
        }
    }
    
    @IBAction func didTap(onCancelButton sender: Any) {
        removeFadeAway()
    }
}

extension UpdateTextPopup: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        let characterLimit = 50
        if newText.count > characterLimit {
            return false // Prevent further input if above the limit
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.codeView.setBorderColor(color: UIColor(named: "008CE9"))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.codeView.setBorderColor(color: UIColor(named: "D4D4D4"))
    }
}
