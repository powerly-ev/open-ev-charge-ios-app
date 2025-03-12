//
//  RatingsReviewsViewController.swift
//  PowerShare
//
//  Created by ADMIN on 27/07/23.
//  
//
import RxSwift
import UIKit

class RatingsReviewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let viewModel = ReviewsViewModel()
    var powerSource: ChargePoint!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        bindView()
        viewModel.getReviewRatingList(chargeId: powerSource.id)
    }
    
    func initFont() {
        titleLabel.font = .robotoMedium(ofSize: 18)
    }
    
    func bindView() {
        viewModel.reviewList
             .asDriver(onErrorJustReturn: [])
             .drive(tableView.rx.items(cellIdentifier: ReviewTableViewCell.className,
                                       cellType: ReviewTableViewCell.self)) { [self] _, element, cell in
                 cell.selectionStyle = .none
                 cell.setUpData(review: element)
                 cell.thumbButton.addTarget(self, action: #selector(didTapOnThumbButton(sender:)), for: .touchUpInside)
             }.disposed(by: disposeBag)
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnThumbButton(sender: UIButton) {
        self.startAnimation(isCurrentView: true)
    }
}
