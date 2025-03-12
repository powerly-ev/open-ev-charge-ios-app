//
//  UserFeedBackFormViewController.swift
//  PowerShare
//
//  Created by admin on 04/01/22.
//  
//

import UIKit
import StoreKit
import SwiftyJSON
import RxSwift

class UserFeedBackFormViewController: UIViewController {
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var notnowButton: SpinnerButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingTextLabel: UILabel!
    @IBOutlet weak var howExperienceLabel: UILabel!
    @IBOutlet weak var doneButton: SpinnerButton!
    @IBOutlet weak var feedbackCollectionView: UICollectionView!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var feedBackView: UIView!
    @IBOutlet weak var addNoteLabel: UILabel!
    @IBOutlet weak var feedBackCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var oneView: UIView!
    @IBOutlet weak var twoView: UIView!
    @IBOutlet weak var threeView: UIView!
    @IBOutlet weak var fourView: UIView!
    @IBOutlet weak var fiveView: UIView!
    var ratingValue = 1
    
    var getCollectionViewHeight: CGFloat {
        feedbackCollectionView.layoutIfNeeded()
        let height = feedbackCollectionView.contentSize.height
        return height > 400 ? 400:height
    }
    var viewModel = FeedbackViewModel(session: nil)
    let disponseBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        initData()
        bindView()
        viewModel.getFeedbackMessage()
        if (try? viewModel.session.value()) == nil {
            if let orderID = self.viewModel.orderID {
                self.viewModel.getSessionDetailBy(orderId: orderID)
            }
        }
    }
    
    func initFont() {
        howExperienceLabel.font = .robotoRegular(ofSize: 16)
        ratingTextLabel.font = .robotoMedium(ofSize: 18)
        addNoteLabel.font = .robotoRegular(ofSize: 14)
        feedbackTextView.font = .robotoRegular(ofSize: 15)
        doneButton.titleLabel?.font = .robotoMedium(ofSize: 16)
    }
    
    func initUI() {
        howExperienceLabel.text = NSLocalizedString("how_was_experience", comment: "")
        addNoteLabel.text = CommonUtils.getStringFromXML(name: "add_note")
        doneButton.setTitle(CommonUtils.getStringFromXML(name: "done_title"), for: .normal)
        if isLanguageArabic {
            let layout = UICollectionViewRightAlignedLayout()
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            feedbackCollectionView.collectionViewLayout = layout
            addNoteLabel.textAlignment = .right
        } else {
            let layout = UICollectionViewLeftAlignedLayout()
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            feedbackCollectionView.collectionViewLayout = layout
            addNoteLabel.textAlignment = .left
        }
    }
    
    func initData() {
        guard let session = try? viewModel.session.value() else {
            return
        }
        nameLabel.text = session.chargePoint?.title ?? ""
    }
    
    func bindView() {
        self.viewModel.session.asObserver().subscribe { session in
            self.initData()
        }.disposed(by: disponseBag)
    }
   
    
    @IBAction func didChangeValue(_ sender: UIButton) {
        self.ratingValue = sender.tag
        doneButton.isHidden = false
        ratingTextLabel.isHidden = false
        feedbackCollectionView.isHidden = false
        feedbackTextView.text = ""
        self.feedbackCollectionView.reloadData()
        
        oneView.backgroundColor = .clear
        twoView.backgroundColor = .clear
        threeView.backgroundColor = .clear
        fourView.backgroundColor = .clear
        fiveView.backgroundColor = .clear
        switch ratingValue {
        case 1:
            oneView.backgroundColor = UIColor(named: "D4EEFF")
            ratingTextLabel.text = CommonUtils.getStringFromXML(name: "terrible_title")
        case 2:
            twoView.backgroundColor = UIColor(named: "D4EEFF")
            ratingTextLabel.text = CommonUtils.getStringFromXML(name: "bad_title")
        case 3:
            threeView.backgroundColor = UIColor(named: "D4EEFF")
            ratingTextLabel.text = CommonUtils.getStringFromXML(name: "fine_title")
        case 4:
            fourView.backgroundColor = UIColor(named: "D4EEFF")
            ratingTextLabel.text = CommonUtils.getStringFromXML(name: "good_title")
        case 5:
            fiveView.backgroundColor = UIColor(named: "D4EEFF")
            ratingTextLabel.text = CommonUtils.getStringFromXML(name: "excellent_title")
        default:
            break
        }
    }
    
    @IBAction func didTap(onNotNowButton sender: Any) {
        guard let orderId = self.viewModel.orderID else {
            self.dismiss(animated: true)
            return
        }
        self.viewModel.skipFeedbackAPI(orderId: orderId, viewController: self)
    }

    @IBAction func didTap(onDoneButton sender: Any) {
        webserviceCallForFeedBack()
    }
    
    func webserviceCallForFeedBack() {
        guard let session = try? viewModel.session.value(), let chargePoint = session.chargePoint else {
            return
        }
        let rating = ratingValue
        let review: String
        if feedbackTextView.text == "" {
            if viewModel.selectedInexpath != -1, let selectedReview = viewModel.getFeedBackArray(rating: ratingValue).value(at: viewModel.selectedInexpath) {
                review = selectedReview
            } else {
                review = ""
            }
        } else {
            review = feedbackTextView.text
        }
        showHideProgress(button: doneButton, show: true)
        NetworkManager().addPowerSourceReview(orderId: session.id, rating: Float(rating), review: review) { success, message, json in
            self.showHideProgress(button: self.doneButton, show: false)
            if success == 1 {
                CommonUtils.logFacebookCustomEvents("feedback_rating", contentType: [
                    "rating": (self.ratingValue == 0 ? 1 : self.ratingValue).description
                ])
                if self.ratingValue == 5 {
                    if #available(iOS 14.0, *) {
                        if let windowScene = DELEGATE?.window?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    } else {
                        SKStoreReviewController.requestReview()
                    }
                }
            } else {
                TSMessage.showNotification(in: DELEGATE?.window?.rootViewController, title: "", subtitle: message, type: .error)
            }
            self.dismiss(animated: true)
        }
    }
}

extension UserFeedBackFormViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getFeedBackArray(rating: ratingValue).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedbackListCollectionViewCell.className, for: indexPath) as? FeedbackListCollectionViewCell else {
            return UICollectionViewCell()
        }
        let feedback = viewModel.getFeedBackArray(rating: ratingValue)[indexPath.item]
        cell.feedbackLabel?.text = feedback.capitalized
        if viewModel.selectedInexpath == indexPath.item {
            cell.feedbackView?.setBorderColor(color: UIColor(named: "008CE9"))
        } else {
            cell.feedbackView?.setBorderColor(color: UIColor(named: "D4D4D4"))
        }
        cell.feedbackView.setCornerRadius(radius: cell.feedbackView.frame.height/2)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let strFeedback = viewModel.getFeedBackArray(rating: ratingValue)[indexPath.item].lowercased()
        if strFeedback == "others" || strFeedback == "آخرين" || strFeedback == "otros" || strFeedback == "autres" {
            feedBackView.isHidden = false
            feedbackTextView.becomeFirstResponder()
        } else {
            feedBackView.isHidden = true
            feedbackTextView.resignFirstResponder()
            feedbackTextView.text = ""
        }
        self.view.layoutIfNeeded()
        viewModel.selectedInexpath = indexPath.item
        feedbackCollectionView.reloadData()
        
        self.doneButton.isHidden = false
        feedBackCollectionViewHeight.constant = getCollectionViewHeight
    }
}
