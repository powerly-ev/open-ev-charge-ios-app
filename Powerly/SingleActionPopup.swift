//
//  SingleActionPopup.swift
//  PowerShare
//
//  Created by admin on 14/02/22.
//  
//

import UIKit

class SingleActionPopup: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    var titleString = ""
    var descriptionString = ""
    var okButtonString = ""
    
    var completionClose:(() -> Void)?
    var completionOkay:(() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = .robotoMedium(ofSize: 16)
        descriptionLabel.font = .robotoRegular(ofSize: 18)
        okButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        titleLabel.text = titleString
        descriptionLabel.text = descriptionString
        okButton.setTitle(okButtonString, for: .normal)
    }
    

    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.completionClose?()
        }
    }
    
    @IBAction func didTapOnOkayButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.completionOkay?()
        }
    }
    
}
