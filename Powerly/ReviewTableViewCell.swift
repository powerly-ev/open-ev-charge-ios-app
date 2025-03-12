//
//  ReviewTableViewCell.swift
//  PowerShare
//
//  Created by ADMIN on 27/07/23.
//  
//
import CoreGraphics
import UIKit

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingView: StarRatingView!
    @IBOutlet weak var reviewMessageLabel: UILabel!
    @IBOutlet weak var helpFulLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var thumbButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileNameLabel.font = .robotoBold(ofSize: 20)
        nameLabel.font = .robotoRegular(ofSize: 16)
        dateLabel.font = .robotoRegular(ofSize: 14)
        reviewMessageLabel.font = .robotoRegular(ofSize: 14)
        helpFulLabel.font = .robotoRegular(ofSize: 12)
        if isLanguageArabic {
            outView.semanticContentAttribute = .forceRightToLeft
            headerView.semanticContentAttribute = .forceRightToLeft
            reviewMessageLabel.textAlignment = .right
        }
    }

    func setUpData(review: RatingReview) {
        profileImageView.image = nil
        profileImageView.backgroundColor = UIColor(named: "F8F8F8")
        if let firstChar = review.user?.firstName.first {
            profileNameLabel.text = String(firstChar).uppercased()
        } else {
            profileNameLabel.text = "P"
        }
        profileNameLabel.textColor = UIColor(named: "222222")
        nameLabel.text = review.user?.fullName ?? ""
        let isoFormatter = ISO8601DateFormatter()
        debugPrint(review.createdAt)
        if let date = isoFormatter.date(from: review.createdAt) {
            dateLabel.text = date.string(format: "yyyy-MM-dd")
        } else {
            dateLabel.text = ""
        }
        ratingView.rating = Float(review.rating) ?? 0.0
        reviewMessageLabel.text = review.content
    }
    
    @IBAction func didTapOnhelpfulButton(_ sender: UIButton) {
        sender.isSelected = true
        self.thumbImageView.image = UIImage(systemName: "hand.thumbsup.fill")
        self.thumbImageView.tintColor = UIColor(named: "008CE9")
    }
}
