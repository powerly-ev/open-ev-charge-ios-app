//
//  ManufacturerViewController.swift
//  PowerShare
//
//  Created by ADMIN on 19/05/23.
//  
//
import Foundation
import RxSwift
import UIKit

class VehicleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .robotoMedium(ofSize: 14)
        if isLanguageArabic {
            arrowImage.image = UIImage(systemName: "chevron.left")
        }
    }
}

class ManufacturerViewController: UIViewController {
    @IBOutlet weak var objTableView: UITableView!
    @IBOutlet weak var headerContentView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var noFoundLabel: UILabel!
    
    var viewModel: AddVehicleViewModel!
    let disposeBag = DisposeBag()
    var completion: ((Make) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
        initUI()
        self.viewModel.callMakeListAPI()
    }
    
    func initUI() {
        if isLanguageArabic {
            headerContentView.semanticContentAttribute = .forceRightToLeft
            searchView.semanticContentAttribute = .forceRightToLeft
            objTableView.semanticContentAttribute = .forceRightToLeft
            searchField.textAlignment = .right
        }
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 18)
        searchField.font = .robotoRegular(ofSize: 16)
    }
    
    func bindView() {
        viewModel.makeSection.asObserver().subscribe { sections in
            self.viewModel.filteredMakeSection = sections.element ?? []
            self.noFoundLabel.isHidden = (sections.element ?? []).count > 0
            self.objTableView.reloadData()
        }.disposed(by: disposeBag)
        
        searchField.rx.text.orEmpty
                .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [self] text in
                    self.viewModel.makeSection
                    .take(1)
                    .map { sections in
                        sections.map { section in
                            MakeSection(name: section.name, makes: text == "" ? section.makes:section.makes.filter { $0.name.lowercased().contains(text.lowercased()) })
                        }
                        .filter { !$0.makes.isEmpty }
                    }
                    .subscribe(onNext: { [weak self] filteredSections in
                        self?.viewModel.filteredMakeSection = filteredSections
                        self?.noFoundLabel.isHidden = filteredSections.count > 0
                        self?.objTableView.reloadData()
                    })
                    .disposed(by: disposeBag)
                }).disposed(by: disposeBag)
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ManufacturerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.filteredMakeSection.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.filteredMakeSection[section].makes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VehicleCell.className, for: indexPath) as? VehicleCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let car = self.viewModel.filteredMakeSection[indexPath.section].makes[indexPath.row]
        cell.titleLabel.text = car.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.filteredMakeSection[section].name
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.viewModel.filteredMakeSection.map({ $0.name })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let make = self.viewModel.filteredMakeSection[indexPath.section].makes[indexPath.row]
        self.dismiss(animated: true) {
            self.completion?(make)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor(named: "008CE9")
        }
    }
}
