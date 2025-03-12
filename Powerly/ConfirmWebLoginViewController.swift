//
//  ConfirmWebLoginViewController.swift
//  Powerly
//
//  Created by ADMIN on 21/11/23.
//  
//

import UIKit

class ConfirmWebLoginViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var denyLabel: UILabel!
    
    var completion: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        
    }
    
    func initFont() {
        titleLabel.font = .robotoRegular(ofSize: 18)
        confirmLabel.font = .robotoMedium(ofSize: 16)
        denyLabel.font = .robotoMedium(ofSize: 16)
        
    }

    @IBAction func didTapOnConfirmButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.completion?()
        }
    }
    
    @IBAction func didTapOnDenyButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
