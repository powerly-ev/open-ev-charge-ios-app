//
//  MyVehicleViewController.swift
//  PowerShare
//
//  Created by ADMIN on 01/06/23.
//  
//
import Combine
import RxSwift
import UIKit

class MyVehicleViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var currentTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var noOrderLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    
    var fromFilter = false
    let viewModel = MyVehicleViewModel()
    let disposeBag = DisposeBag()
    var completionSelection: ((Vehicle) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        bindView()
        currentTableView.addSubview(viewModel.refreshControl)

        // Set the target and action for the refresh control
        viewModel.refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.getVehicleListAPI {}
    }
    
    func initFont() {
        lblTitle.font = .robotoMedium(ofSize: 16)
        noOrderLabel.font = .robotoRegular(ofSize: 12)
        addLabel.font = .robotoMedium(ofSize: 16)
    }
    
    func bindView() {
        viewModel.vehicles
             .asDriver(onErrorJustReturn: [])
             .drive(currentTableView.rx.items(cellIdentifier: MyVehicleTableViewCell.className,
                                              cellType: MyVehicleTableViewCell.self)) { [self] indexPath, element, cell in
                 cell.selectionStyle = .none
                 cell.setupCell(vehicle: element)
                 cell.menuButton.tag = indexPath
                 cell.menuButton.addTarget(self, action: #selector(didTapOnMenuButton(sender:)), for: .touchUpInside)
                 cell.editButton.tag = indexPath
                 cell.editButton.addTarget(self, action: #selector(didTapOnEditButton(sender:)), for: .touchUpInside)
             }.disposed(by: disposeBag)
        
        currentTableView.rx.itemSelected.asObservable().subscribe { indexPath in
            if let indexPath = indexPath.element, let vehicles = try? self.viewModel.vehicles.value(), let vehicle = vehicles.value(at: indexPath.row) {
                if self.fromFilter {
                    self.dismiss(animated: true) {
                        self.completionSelection?(vehicle)
                    }
                }
            }
        }.disposed(by: disposeBag)
        
        // Set up the observer for the error message
        viewModel.errorMessage
            .sink { error in
                DispatchQueue.main.async {
                    TSMessage.showNotification(in: self, title: "", subtitle: error, type: .error)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func reloadData() {
        viewModel.getVehicleListAPI {
            self.viewModel.refreshControl.endRefreshing()
        }
    }

    @IBAction func didTapAddButton(_ sender: Any) {
        guard let addVehicle = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: AddVehicleViewController.className) as? AddVehicleViewController else {
            return
        }
        addVehicle.viewModel = AddVehicleViewModel()
        self.navigationController?.pushViewController(addVehicle, animated: true)
    }
    
    @IBAction func didTapOnBackButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnEditButton(sender: UIButton) {
        guard var vehicle = try? self.viewModel.vehicles.value().value(at: sender.tag) else {
            return
        }
        guard let promotionCodeVC = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: UpdateTextPopup.className) as? UpdateTextPopup else {
            return
        }
        promotionCodeVC.titleStr = vehicle.title
        promotionCodeVC.providesPresentationContextTransitionStyle = true
        promotionCodeVC.definesPresentationContext = true
        promotionCodeVC.modalPresentationStyle = .overCurrentContext
        promotionCodeVC.completion = { updatedTitle in
            let viewModel = AddVehicleViewModel()
            vehicle.title = updatedTitle
            viewModel.vehicle = vehicle
            viewModel.updateDataFromVehicle(vehicle: vehicle)
            viewModel.addUpdateVehicleAPI()
            viewModel.addVehicleResponse.asObservable().subscribe { response in
                if let response = response.element {
                    if response.success == 1 {
                        self.startAnimation(isCurrentView: true)
                        self.viewModel.getVehicleListAPI {}
                    } else {
                        TSMessage.showNotification(in: self, title: "", subtitle: response.message, type: .error)
                    }
                }
            }.disposed(by: self.disposeBag)
        }
        self.present(promotionCodeVC, animated: true) {
        }
    }
    
    @IBAction func didTapOnMenuButton(sender: UIButton) {
        guard let vehicle = try? self.viewModel.vehicles.value().value(at: sender.tag) else {
            return
        }
        let list = [NSLocalizedString("edit", comment: ""), NSLocalizedString("delete", comment: "")]
        let point = sender.convert(CGPoint.zero, to: self.view)
        guard let dropVC = UIStoryboard(storyboard: .common).instantiateViewController(withIdentifier: DropDownListViewController.className) as? DropDownListViewController else {
            return
        }
        dropVC.modalPresentationStyle = .overCurrentContext
        dropVC.yValue = point.y
        dropVC.popUpRect = CGRect(x: point.x, y: point.y, width: self.view.frame.width-32, height: CGFloat(50*list.count))
        dropVC.list = list
        dropVC.completionSelectedIndex = { index in
            switch index {
            case 0:
                guard let addVehicle = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: AddVehicleViewController.className) as? AddVehicleViewController else {
                    return
                }
                let viewModel = AddVehicleViewModel()
                viewModel.vehicle = vehicle
                addVehicle.viewModel = viewModel
                self.navigationController?.pushViewController(addVehicle, animated: true)
                
            case 1:
                self.showDialogue(title: NSLocalizedString("delete_vehicle", comment: ""), description: NSLocalizedString("delete_vehicle_note", comment: "")) { success in
                    if success {
                        self.viewModel.deleteVehicle(id: vehicle.id)
                    }
                }
                
            default:
                break
            }
        }
        self.present(dropVC, animated: false)
    }
}
