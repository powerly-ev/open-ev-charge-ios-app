//
//  TransferBalanceViewController.swift
//  PowerShare
//
//  Created by ADMIN on 17/05/23.
//  
//
import PassKit
import RxSwift
import SwiftyJSON
import UIKit

class TransferBalanceViewController: UIViewController {
    @IBOutlet var objTableView: UITableView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var addNewCardButton: SpinnerButton!
    @IBOutlet var headerView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var withdrawToLabel: UILabel!
    @IBOutlet weak var tableHeaderView: UIView!
    
    var getCardsArray: [Card] = [Card]()
    var isDefaultIndex: Int = -1
    var applePayButton: PKPaymentButton = PKPaymentButton()
    let viewModel = WalletViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindView()
        Task {
            await viewModel.getWallets()
        }
    }
    
    func initUI() {
        withdrawToLabel.font = .robotoRegular(ofSize: 12)
        headerLabel.font = .robotoMedium(ofSize: 16)
        addNewCardButton.titleLabel?.font = .robotoMedium(ofSize: 16)
        headerLabel.text = CommonUtils.getStringFromXML(name: "wallet_title")
        withdrawToLabel.text = NSLocalizedString("withdraw_from", comment: "")
        addNewCardButton.setTitle(NSLocalizedString("agree_withdraw", comment: ""), for: .normal)
        if isLanguageArabic {
            objTableView.semanticContentAttribute = .forceRightToLeft
            tableHeaderView.semanticContentAttribute = .forceRightToLeft
        }
        
        let attributedText = NSMutableAttributedString().normal(NSLocalizedString("withdraw_policy_desc", comment: ""))
        attributedText.colorRange(value: NSLocalizedString("withdraw_policy", comment: ""), color: UIColor(named: "008CE9") ?? .lightGray)
        attributedText.colorRange(value: NSLocalizedString("terms_of_service", comment: ""), color: UIColor(named: "008CE9") ?? .lightGray)
        agreeLabel.attributedText = attributedText
        agreeLabel.attributedText = attributedText
        agreeLabel.isUserInteractionEnabled = true
        agreeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(onLabel:))))
    }
    
    func bindView() {
        viewModel.wallets
             .asDriver(onErrorJustReturn: [])
             .drive(objTableView.rx.items(cellIdentifier: PaymentMethodTableViewCell.className,
                                       cellType: PaymentMethodTableViewCell.self)) { _, element, cell in
                 cell.selectionStyle = .none
                 cell.setupWallet(wallet: element)
             }.disposed(by: disposeBag)
        
        viewModel.wallets.subscribe(onNext: { wallets in
            if let wallet = wallets.first(where: {$0.withdrawable && Float($0.balance) ?? 0 > 0}) {
                DispatchQueue.main.async {
                    self.withdrawButton(isEnable: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.withdrawButton(isEnable: false)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func withdrawButton(isEnable: Bool) {
        if !isEnable {
            self.addNewCardButton.isUserInteractionEnabled = false
            self.addNewCardButton.backgroundColor = UIColor(named: "7A7A7A")
            return
        }
        self.addNewCardButton.isUserInteractionEnabled = true
        self.addNewCardButton.backgroundColor = UIColor(named: "222222")
    }

    @objc func handleTap(onLabel tapGesture: UITapGestureRecognizer) {
        guard let text = self.agreeLabel.attributedText?.string, let countryId = UserManager.shared.country?.id else {
            return
        }
    }
    
    func retrieveCards() {
        NetworkManager().getCards { success, message, cards in
            self.objTableView.stopSkeletonAnimation()
            self.objTableView.hideSkeleton()
            if success == 1 {
                self.getCardsArray = cards.filter({$0.paymentType != .cash && $0.paymentType != .balance && $0.paymentType != .applePay})
                if let index = self.getCardsArray.firstIndex(where: { card in
                    return card.isDefault == 1
                }) {
                    self.isDefaultIndex = index
                }
            }
            self.objTableView.reloadData()
        }
    }

    @IBAction func didTap(onAddNewCardButton sender: UIButton) {
        Task {
            if let response = await viewModel.requestPayout() {
                self.presentPaymentSuccessPopup(success: response.success, message: response.message)
            }
        }
    }

    func presentPaymentSuccessPopup(success: Int, message: String) {
        let storyboard = UIStoryboard(name: "Popup", bundle: nil)
        guard let singlePopup = storyboard.instantiateViewController(withIdentifier: SingleActionPopup.className) as? SingleActionPopup else {
            return
        }
        singlePopup.titleString = success == 1 ? "Withdraw Successful":"Withdraw Failed"
        singlePopup.descriptionString = message
        singlePopup.okButtonString = CommonUtils.getStringFromXML(name: "okay_title")
        
        singlePopup.completionOkay = { [weak self] in
            Task {
                await self?.viewModel.getWallets()
            }
        }
        
        self.present(singlePopup, animated: true)
    }

    
    @IBAction func didTap(onBackButton sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTap(onCloseButton sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
