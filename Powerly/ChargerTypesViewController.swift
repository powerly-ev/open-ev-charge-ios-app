//
//  ChargerTypesViewController.swift
//  PowerShare
//
//  Created by ADMIN on 09/08/23.
//  
//
import RxSwift
import UIKit

class ChargerTypesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchPlugField: UITextField!
    @IBOutlet weak var noFoundLabel: UILabel!
    
    var completionContinue: ((Connector) -> Void)?
    let viewModel = StationViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        bindView()
        viewModel.getEvConnectors(category: PowerSourceCategory.evCharger.rawValue)
    }
    
    func initUI() {
        if isLanguageArabic {
            searchView.semanticContentAttribute = .forceRightToLeft
            searchPlugField.textAlignment = .right
            headerLabel.textAlignment = .right
        }
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 18)
        searchPlugField.font = .robotoRegular(ofSize: 16)
    }
    
    func bindView() {
        viewModel.filterConnectors.asObservable().subscribe { connectors in
            self.noFoundLabel.isHidden = (connectors.element?.count ?? 0) > 0
        }.disposed(by: disposeBag)
        
       viewModel.filterConnectors
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: AddPlugTypeTableViewCell.className,
                                      cellType: AddPlugTypeTableViewCell.self)) { _, element, cell in
                cell.selectionStyle = .none
                cell.setUpData(connector: element, selected: false)
            }.disposed(by: disposeBag)
       
        tableView
            .rx
            .itemSelected
                .subscribe(onNext: { indexPath in
                    do {
                        let connector = try self.viewModel.filterConnectors.value()[indexPath.row]
                        self.completionContinue?(connector)
                        self.dismiss(animated: true)
                    } catch {
                    }
                }).disposed(by: disposeBag)
        
        searchPlugField.rx.text.orEmpty
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [self] text in
                if text == "" {
                    self.viewModel.filterConnectors.onNext(self.viewModel.connectors)
                } else {
                    let filteredModels = self.viewModel.connectors.filter { $0.name.lowercased().contains(text.lowercased())
                    }
                    self.viewModel.filterConnectors.onNext(filteredModels)
                }
            }).disposed(by: disposeBag)
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
