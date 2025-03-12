//
//  DoubleActionPopup.swift
//  PowerShare
//
//  Created by admin on 14/02/22.
//  
//

import UIKit

class DoubleActionPopup: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    var descriptionString = ""
    var yesString = ""
    var noString = ""
    var completionYes:(() -> Void)?
    var completionNo:(() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.font = .robotoRegular(ofSize: 18)
        noButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        yesButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = descriptionString
        yesButton.setTitle(yesString, for: .normal)
        noButton.setTitle(noString, for: .normal)
    }
    
    @IBAction func didTapOnNoButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.completionNo?()
        }
    }
    
    
    @IBAction func didTapOnYesButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.completionYes?()
        }
    }
}
