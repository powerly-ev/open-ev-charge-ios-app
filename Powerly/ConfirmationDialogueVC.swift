//
//  ConfirmationDialogueVC.swift
//  PowerShare
//
//  Created by admin on 31/08/22.
//  
//

import UIKit

class ConfirmationDialogueVC: UIViewController {
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: SpinnerButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var titleStr: String = ""
    var descriptionStr: String = ""
    var yesTitle = ""
    var noTitle = ""
    var completionButton: ((Bool) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        initFont()
        headerLabel.text = titleStr
        descriptionLabel.text = descriptionStr
        yesButton.setTitle(yesTitle, for: .normal)
        noButton.setTitle(noTitle, for: .normal)
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 16)
        descriptionLabel.font = .robotoRegular(ofSize: 18)
        noButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        yesButton.titleLabel?.font = .robotoMedium(ofSize: 16)
    }
    
    func showAnimate() {
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: { [self] in
            view.alpha = 1
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    func removeFadeAway(success: Bool = false) {
        UIView.animate(withDuration: 0.25, animations: { [self] in
            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            view.alpha = 0
        }) { [self] finished in
            dismiss(animated: true) {
                self.completionButton?(success)
            }
        }
    }
    
    @IBAction func didTap(onCloseButton sender: Any) {
        UIView.animate(withDuration: 0.25, animations: { [self] in
            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            view.alpha = 0
        }) { [self] finished in
            dismiss(animated: true) {
                
            }
        }
    }

    @IBAction func didTap(onYesButton sender: Any) {
        removeFadeAway(success: true)
    }
    
    @IBAction func didTap(onNoButton sender: Any) {
        removeFadeAway()
    }
}
