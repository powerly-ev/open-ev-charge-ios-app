//
//  AddVehicleViewController.swift
//  PowerShare
//
//  Created by ADMIN on 17/05/23.
//  
//
import RxSwift
import UIKit

class AddVehicleViewController: UIViewController {
    @IBOutlet weak var objTableView: UITableView!
    @IBOutlet weak var addEVChargerView: UIView!
    @IBOutlet weak var addEvButtonLabel: UILabel!
    @IBOutlet weak var addEvPlusLeftImageView: UIImageView!
    var viewModel: AddVehicleViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        objTableView.delegate = self
        objTableView.dataSource = self
        bindView()
        
        if let vehicle = viewModel.vehicle {
            self.viewModel.updateDataFromVehicle(vehicle: vehicle)
            addEvButtonLabel.text = NSLocalizedString("Update", comment: "")
        } else {
            self.openType(type: .manufacturer)
        }
    }
    
    func bindView() {
        viewModel.data.subscribe(onNext: { _ in
            self.objTableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.addVehicleResponse.asObservable().subscribe { response in
            if let response = response.element {
                if response.success == 1 {
                    self.navigationController?.popViewController(animated: true)
                    self.startAnimation(isCurrentView: true)
                } else {
                    TSMessage.showNotification(in: self, title: "", subtitle: response.message, type: .error)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func didTapOnBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func didTapOnAddVehicleButton(_ sender: Any) {
        self.viewModel.addUpdateVehicleAPI()
    }
}

extension AddVehicleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getData()?.details.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddVehicleTableViewCell.className, for: indexPath) as? AddVehicleTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.model = self.viewModel.getData()
        if let stations = self.viewModel.getData()?.details, let element = stations.value(at: indexPath.row) {
            cell.setUpItem(item: element)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = self.viewModel.getData()?.details.value(at: indexPath.row) {
            self.openType(type: item.type)
        }
    }
    
    func openType(type: VehicleType) {
        switch type {
        case .manufacturer:
        guard let manufacturerVC = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: ManufacturerViewController.className) as? ManufacturerViewController else {
            return
        }
        manufacturerVC.viewModel = AddVehicleViewModel()
        manufacturerVC.modalPresentationStyle = .overFullScreen
        manufacturerVC.completion = { make in
            if var vehicle = self.viewModel.getData() {
                vehicle.manufacturer = make
                self.viewModel.updateData(model: vehicle)
            }
            self.openType(type: .model)
        }
        self.present(manufacturerVC, animated: true, completion: nil)
            
        case .model:
        guard let modelVC = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: ModelViewController.className) as? ModelViewController else {
            return
        }
        modelVC.viewModel = self.viewModel
        modelVC.completion = { model in
            if var vehicle = self.viewModel.getData() {
                vehicle.model = model
                self.viewModel.updateData(model: vehicle)
            }
            self.openType(type: .details)
        }
        modelVC.modalPresentationStyle = .overFullScreen
        self.present(modelVC, animated: true)
            
        case .details:
        guard let detailVC = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: VehicleDetailsViewController.className) as? VehicleDetailsViewController else {
            return
        }
        detailVC.modalPresentationStyle = .overFullScreen
        detailVC.viewModel = self.viewModel
        detailVC.completion = { addVehicle in
            self.viewModel.updateData(model: addVehicle)
        }
        self.present(detailVC, animated: true)
        }
    }
}
