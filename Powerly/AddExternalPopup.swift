//
//  AddExternalPopup.swift
//  PowerShare
//
//  Created by ADMIN on 16/08/23.
//  
//

import UIKit

class AddExternalPopup: UIViewController {
    
    @IBOutlet weak var syncView: UIView!
    @IBOutlet weak var syncLabel: UILabel!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var syncRadioImageView: UIImageView!
    @IBOutlet weak var syncLine1: UILabel!
    @IBOutlet weak var syncLine2: UILabel!
    @IBOutlet weak var syncLine3: UILabel!
    
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var reportChargerLabel: UILabel!
    @IBOutlet weak var reportRadioImageView: UIImageView!
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var reportLine1: UILabel!
    @IBOutlet weak var reportLine2: UILabel!
    @IBOutlet weak var reportLine3: UILabel!
    
    @IBOutlet weak var continueArrow: UIImageView!
    @IBOutlet weak var continueStackView: UIStackView!
    var completion: ((Bool) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.didTapOnSyncButton(self)
        initUI()
    }
    
    func initUI() {
        if isLanguageArabic {
            reportView.semanticContentAttribute = .forceRightToLeft
            reportChargerLabel.textAlignment = .right
            outView.semanticContentAttribute = .forceRightToLeft
            reportLine1.textAlignment = .right
            reportLine2.textAlignment = .right
            reportLine3.textAlignment = .right
            
            syncView.semanticContentAttribute = .forceRightToLeft
            syncLabel.textAlignment = .right
            syncLine1.textAlignment = .right
            syncLine2.textAlignment = .right
            syncLine3.textAlignment = .right
            continueStackView.semanticContentAttribute = .forceRightToLeft
            continueArrow.image = UIImage(named: "left-arrow")
        }
    }
    
    @IBAction func didTapOnReportButton(_ sender: Any) {
        reportButton.isSelected = true
        syncButton.isSelected = false
        
        reportRadioImageView.image = UIImage(named: "radio_fill_big")
        syncRadioImageView.image = UIImage(named: "radio_unfill_big")
    }
    
    @IBAction func didTapOnSyncButton(_ sender: Any) {
        reportButton.isSelected = false
        syncButton.isSelected = true
        
        syncRadioImageView.image = UIImage(named: "radio_fill_big")
        reportRadioImageView.image = UIImage(named: "radio_unfill_big")
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnContinueButton(_ sender: Any) {
        self.dismiss(animated: true) {
            self.completion?(self.reportButton.isSelected)
        }
    }
}
