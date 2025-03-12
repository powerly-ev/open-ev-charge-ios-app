//
//  ModelViewController.swift
//  PowerShare
//
//  Created by ADMIN on 22/05/23.
//  
//
import RxSwift
import UIKit

class ModelViewController: UIViewController {
    @IBOutlet weak var headerContentView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var noFoundLabel: UILabel!
    @IBOutlet weak var objTableView: UITableView!
    
    var completion: ((VehicleModel) -> Void)?
    var viewModel: AddVehicleViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        bindView()
        if let vehicles = self.viewModel.getData(), let modelId = vehicles.manufacturer?.id {
            viewModel.callModelListAPI(makeId: modelId)
        }
    }
    
    func initUI() {
        if isLanguageArabic {
            headerContentView.semanticContentAttribute = .forceRightToLeft
            searchView.semanticContentAttribute = .forceRightToLeft
            searchField.textAlignment = .right
            objTableView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 18)
        countLabel.font = .robotoMedium(ofSize: 14)
        searchField.font = .robotoRegular(ofSize: 16)
    }
    
    func bindView() {
        viewModel.filteredModelSection
             .asDriver(onErrorJustReturn: [])
             .drive(objTableView.rx.items(cellIdentifier: VehicleCell.className,
                                       cellType: VehicleCell.self)) { _, element, cell in
                 cell.selectionStyle = .none
                 cell.titleLabel.text = element.name
             }.disposed(by: disposeBag)
        
        objTableView.rx.itemSelected.asObservable().subscribe { indexPath in
            if let indexPath = indexPath.element, let modelList = try? self.viewModel.filteredModelSection.value(), let model = modelList.value(at: indexPath.item) {
                self.dismiss(animated: true) {
                    self.completion?(model)
                }
            }
        }.disposed(by: disposeBag)
        
        searchField.rx.text.orEmpty
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [self] text in
                if text == "" {
                    self.viewModel.filteredModelSection.onNext(self.viewModel.modelList)
                    self.noFoundLabel.isHidden = self.viewModel.modelList.count > 0
                } else {
                    let filteredModels = self.viewModel.modelList.filter { $0.name.lowercased().contains(text.lowercased())
                    }
                    self.noFoundLabel.isHidden = filteredModels.count > 0
                    self.viewModel.filteredModelSection.onNext(filteredModels)
                }
            }).disposed(by: disposeBag)
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
