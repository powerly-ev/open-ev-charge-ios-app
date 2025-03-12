//
//  CurrencyListViewController.swift
//  Powerly
//
//  Created by ADMIN on 22/07/24.
//  
//
import RxSwift
import UIKit

class CurrencyListViewController: UIViewController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var popUpRect = CGRect.zero
    var yValue = CGFloat.zero
    var completionSelectedIndex: ((Currency) -> Void)?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.addDropshadowtoVIEW()
        bindView()
        if let currencyList = try? UserManager.shared.currencyList.value(), currencyList.count > 0 {
        } else {
            UserManager.shared.fetchCurrencyList()
        }
    }
    
    override func viewDidLayoutSubviews() {
        topConstraint.constant = yValue
        heightConstraint.constant = screenHeight - yValue - 50
    }
    
    func bindView() {
        UserManager.shared.currencyList
             .asDriver(onErrorJustReturn: [])
             .drive(tableView.rx.items(cellIdentifier: CategoryTableViewCell.className,
                                       cellType: CategoryTableViewCell.self)) { _, element, cell in
                 cell.selectionStyle = .none
                 cell.categoryTitleLabel.text = element.currencyIso
                 cell.rightImageView.isHidden = UserManager.shared.user?.currency != element.currencyIso
             }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable().subscribe { indexPath in
            if let indexPath = indexPath.element, let currencyList = try? UserManager.shared.currencyList.value(), let currency = currencyList.value(at: indexPath.item) {
                self.dismiss(animated: true) {
                    self.completionSelectedIndex?(currency)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func didTapOnOutSideAction(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
}
