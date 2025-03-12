//
//  TutorialViewController.swift
//  GasBottle
//
//  Created by admin on 04/10/22.
//  
//

import UIKit

class TutorialViewController: UIViewController {
    var tutorialImage = UIImage(named: "tutorial_1")
    var attrTitle: NSAttributedString?
    var strDescription = ""
    var attrDescription: NSAttributedString?
    @IBOutlet var tutorialImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialImageView.image = tutorialImage
        titleLabel.font = .robotoBold(ofSize: 28)
        descriptionLabel.font = .robotoMedium(ofSize: 16)
        if let attrTitle = attrTitle {
            titleLabel.attributedText = attrTitle
        }
        if let attrDescription = attrDescription {
            descriptionLabel.attributedText = attrDescription
        } else {
            descriptionLabel.text = strDescription
        }
    }
}
