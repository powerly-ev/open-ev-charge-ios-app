//
//  CategoryTableViewCell.swift
//  PowerShare
//
//  Created by admin on 13/02/22.
//  
//

import UIKit
import StoreKit

class CategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categoryDescriptionLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var outView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryTitleLabel.font = .robotoMedium(ofSize: 14)
        if isLanguageArabic {
            outView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    /*func configCell(product: Product) {
        self.categoryTitleLabel.text = product.title
        self.categoryImageView.sd_setImage(with: URL(string: product.img), completed: nil)
    }*/
}
