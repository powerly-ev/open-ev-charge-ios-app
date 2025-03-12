//
//  RewardCollectionViewCell.swift
//  PowerShare
//
//  Created by admin on 06/04/23.
//  
//

import UIKit

class SliderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var sliderImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .robotoMedium(ofSize: 28)
        descriptionLabel.font = .robotoRegular(ofSize: 16)
        if isLanguageArabic {
            outView.semanticContentAttribute = .forceRightToLeft
            descriptionLabel.textAlignment = .right
            titleLabel.textAlignment = .right
        }
    }
    
    func setupData(slider: HomeSlider) {
        sliderImageView.image = UIImage(named: slider.image)
        titleLabel.text = slider.title
        descriptionLabel.text = slider.description
    }
}
