//
//  SupportTableViewCell.swift
//  PowerShare
//
//  Created by admin on 12/01/22.
//  
//

import UIKit

class SupportTableViewCell: UITableViewCell {
    @IBOutlet weak var leftTimeLabel: UILabel?
    @IBOutlet weak var leftChatView: UIView?
    @IBOutlet weak var leftChatLabel: UILabel?
    @IBOutlet weak var rightTimeLabel: UILabel?
    @IBOutlet weak var rightChatView: UIView?
    @IBOutlet weak var rightChatLabel: UILabel?
    @IBOutlet weak var rightChatTextView: UITextView?
    @IBOutlet weak var leftChatTextView: UITextView?
    @IBOutlet weak var supportProfileView: UIView?
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var oppositeUserLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        oppositeUserLabel?.font = .robotoMedium(ofSize: 14)
        leftTimeLabel?.font = .robotoMedium(ofSize: 12)
        leftChatLabel?.font = .robotoRegular(ofSize: 16)
        leftChatTextView?.font = .robotoRegular(ofSize: 16)
        rightTimeLabel?.font = .robotoRegular(ofSize: 12)
        rightChatTextView?.font = .robotoRegular(ofSize: 16)
        rightChatTextView?.font = .robotoRegular(ofSize: 16)
        rightChatTextView?.textContainerInset = UIEdgeInsets.zero
        leftChatTextView?.textContainerInset = UIEdgeInsets.zero
        // Initialization code
    }
}
