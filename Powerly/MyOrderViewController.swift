//
//  MyOrderViewController.swift
//  PowerShare
//
//  Created by admin on 26/10/21.

//
import Combine
import RxSwift
import UIKit

class MyOrderViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var currentTableView: UITableView!
    @IBOutlet weak var noOrderLabel: UILabel!
    @IBOutlet weak var myOrderSelectionCollectionView: UICollectionView!
    
    let viewModel = MyOrderViewModel()
    private let disposeBag = DisposeBag()
    var customFlowLayout = UICollectionViewFlowLayout()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        currentTableView.addSubview(viewModel.currentRefreshControl)
        viewModel.currentRefreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)

        CommonUtils.logFacebookCustomEvents("my_order_open", contentType: [:])
        
        currentTableView.register(UINib(nibName: CurrentTableViewCell.className, bundle: nil), forCellReuseIdentifier: CurrentTableViewCell.className)
        bindView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selected = self.viewModel.getMyOrderSelected() {
            switch selected.type {
            case .active:
                self.viewModel.callGetActiveSession()
                
            default:
                break
            }
        } else {
            self.viewModel.updateSelection(selection: .active)
        }
    }
    
    func initUI() {
        customFlowLayout.itemSize = CGSize(width: screenWidth/3, height: 56)
        customFlowLayout.minimumLineSpacing = 0
        customFlowLayout.minimumInteritemSpacing = 0
        customFlowLayout.scrollDirection = .horizontal
        myOrderSelectionCollectionView.collectionViewLayout = customFlowLayout
    }
    
    func initFont() {
        noOrderLabel.font = .robotoRegular(ofSize: 12)
    }
    
    func setupNoOrderLabel() {
        guard let selection = self.viewModel.getMyOrderSelected() else {
            return
        }
        switch selection.type {
            case .active:
                let count = self.viewModel.getActiveSessions().count
                self.noOrderLabel.isHidden = !(count == 0)
                self.noOrderLabel.text = NSLocalizedString("no_active_order", comment: "")
            
            case .past:
                let count = self.viewModel.getCompletedSessions().count
                self.noOrderLabel.isHidden = !(count == 0)
                self.noOrderLabel.text = NSLocalizedString("no_completed_order", comment: "")
            
        }
    }
    
    func bindView() {
        self.viewModel.activeSessions.asObservable().subscribe { _ in
            self.viewModel.currentRefreshControl.endRefreshing()
            self.currentTableView.reloadData()
            self.setupNoOrderLabel()
        }.disposed(by: disposeBag)
        
        self.viewModel.pastSession.asObservable()
            .subscribe { orders in
                self.viewModel.currentRefreshControl.endRefreshing()
                self.currentTableView.reloadData()
                self.setupNoOrderLabel()
            }
            .disposed(by: disposeBag)
        
        viewModel.menuOptions
            .asDriver(onErrorJustReturn: [])
            .drive(myOrderSelectionCollectionView.rx.items(cellIdentifier: MyOrderSelectionCollectionViewCell.className, cellType: MyOrderSelectionCollectionViewCell.self)) { _, element, cell in
                    cell.setUpData(selection: element)
                }
            .disposed(by: disposeBag)
        
        myOrderSelectionCollectionView
            .rx
            .itemSelected
                .subscribe(onNext:{ indexPath in
                    if let options = try? self.viewModel.menuOptions.value(), let selection = options.value(at: indexPath.item) {
                        self.viewModel.updateSelection(selection: selection.type)
                    }
                }).disposed(by: disposeBag)
        
        // Set up the observer for the error message
        viewModel.errorMessage
            .sink { error in
                DispatchQueue.main.async {
                    TSMessage.showNotification(in: self, title: "", subtitle: error, type: .error)
                }
            }
            .store(in: &cancellables)
        
        // Selection status
        self.viewModel.menuOptions.asObservable()
            .subscribe { options in
                guard let selection = options.element?.first(where: {$0.isSelected}) else {
                    return
                }
                switch selection.type {
                    case .active:
                    self.noOrderLabel.isHidden = true
                    self.viewModel.callGetActiveSession()
                        break
                    
                    case .past:
                        self.noOrderLabel.isHidden = true
                        self.viewModel.webserviceCallForPastOrder(isReload: true)
                        break
                }
                self.currentTableView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func btnActionStopCharging(sender: UIButton) {
        guard let activeSession = self.viewModel.getActiveSessions().value(at: sender.tag), let chargePoint = activeSession.chargePoint else {
            return
        }
        self.showDialogue(title: NSLocalizedString("stop_charging", comment: ""), description: NSLocalizedString("sure_stop_charging", comment: "")) { success in
            if success {
                self.viewModel.stopCharging(id: chargePoint.id, orderId: activeSession.id)
            }
        }
    }
    
    @IBAction func btnActionRecharge(sender: UIButton) {
        guard let powerSource = self.viewModel.getCompletedSessions().value(at: sender.tag), let chargePoint = powerSource.chargePoint, chargePoint.listed else {
            return
        }
        self.openCPDetail(chagePoint: chargePoint, isPointStartCharging: true)
    }
    
    func openCPDetail(chagePoint: ChargePoint, isPointStartCharging: Bool) {
        guard let storeListVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: PowerSourceDetailViewController.className) as? PowerSourceDetailViewController else {
            return
        }
        let viewModel = ChargePointDetailViewModel(chargePoint: chagePoint)
        viewModel.isOpenStartCharging = isPointStartCharging
        storeListVC.viewModel = viewModel
        storeListVC.modalPresentationStyle = .overFullScreen
        self.present(storeListVC, animated: true, completion: nil)
    }
    
    @IBAction func refreshControlAction(_ sender: Any) {
        if let selected = self.viewModel.getMyOrderSelected() {
            self.viewModel.updateSelection(selection: selected.type)
        }
    }
    
    private func showHideProgress(enable: Bool) {
        self.view.isUserInteractionEnabled = !enable
    }
}

extension MyOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selected = self.viewModel.getMyOrderSelected() {
            switch selected.type {
                case .active:
                    return self.viewModel.getActiveSessions().count
                case .past:
                    if let past = try? self.viewModel.pastSession.value().count {
                        return past
                    }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let selected = self.viewModel.getMyOrderSelected() {
            switch selected.type {
                case .active:
                let chargePoints: [ActiveSession] = self.viewModel.getActiveSessions()
                if let activeSession = chargePoints.value(at: indexPath.row) {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrentTableViewCell.className) as? CurrentTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.selectionStyle = .none
                    cell.setUpSession(session: activeSession)
                    cell.leftActionButton.tag = indexPath.row
                    cell.leftActionButton.removeTarget(self, action: nil, for: .touchUpInside)
                    cell.leftActionButton.addTarget(self, action: #selector(btnActionStopCharging(sender:)), for: .touchUpInside)
                    return cell
                }
                
                case .past:
                let pastOrder: [ActiveSession]? = try? self.viewModel.pastSession.value()
                if let pastOrders = pastOrder, let order = pastOrders.value(at: indexPath.row) {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrentTableViewCell.className) as? CurrentTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.selectionStyle = .none
                    cell.setUpSession(session: order)
                    cell.leftActionButton.tag = indexPath.row
                    cell.leftActionButton.removeTarget(self, action: nil, for: .touchUpInside)
                    cell.leftActionButton.addTarget(self, action: #selector(btnActionRecharge(sender:)), for: .touchUpInside)
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let selected = self.viewModel.getMyOrderSelected() {
            if let pastOrders = try? self.viewModel.pastSession.value(), !viewModel.isLoading && indexPath.row == pastOrders.count - 5 && selected.type == .past {
                viewModel.webserviceCallForPastOrder(isReload: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selected = self.viewModel.getMyOrderSelected() else {
            return
        }
        switch selected.type {
            case .active:
            let activeSessions = self.viewModel.getActiveSessions()
            if let aciveSession = activeSessions.value(at: indexPath.row) {
                guard let evMeterVC = UIStoryboard(storyboard: .store).instantiateViewController(withIdentifier: EVMeterViewController.className) as? EVMeterViewController else {
                    return
                }
                evMeterVC.modalPresentationStyle = .fullScreen
                evMeterVC.activeSession = aciveSession
                self.present(evMeterVC, animated: true, completion: nil)
            }
                
            case .past:
            let pastOrder: [ActiveSession]? = try? self.viewModel.pastSession.value()
            if let pastOrders = pastOrder, let past = pastOrders.value(at: indexPath.row) {
                guard let orderDetailVC = UIStoryboard(storyboard: .myOrder).instantiateViewController(withIdentifier: CurrentPastOrderDetailViewController.className) as? CurrentPastOrderDetailViewController else {
                    return
                }
                orderDetailVC.modalPresentationStyle = .overFullScreen
                orderDetailVC.session = past
                self.present(orderDetailVC, animated: true, completion: nil)
            }
        }
    }
}
