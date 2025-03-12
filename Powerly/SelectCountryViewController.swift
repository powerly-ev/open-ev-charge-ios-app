//
//  SelectCountryViewController.swift
//  PowerShare
//
//  Created by admin on 10/02/22.
//  
//

import UIKit

class SelectCountryViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var objTableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    var selectedIndex = -1
    var completionSelectedLanguage: ((Country) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.font = .robotoMedium(ofSize: 16)
        headerLabel.text = CommonUtils.getStringFromXML(name: "select_country")
        if let countrySelected = UserManager.shared.country {
            if let index = UserManager.shared.countryList.firstIndex(where: { country in
                return country.id == countrySelected.id
            }) {
                self.selectedIndex = index
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableViewHeight.constant = objTableView.contentSize.height
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
}

extension SelectCountryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserManager.shared.countryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.className, for: indexPath) as? CountryCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let country = UserManager.shared.countryList[indexPath.row]
        cell.languageLabel.font = .robotoMedium(ofSize: 16)
        cell.languageLabel.text = country.name 
        cell.countryImageView.sd_setImage(with: URL(string: country.flagUrl), placeholderImage: nil)
        if selectedIndex == indexPath.row {
            cell.rightImageView.isHidden = false
            cell.backgroundColor = UIColor(named: "F8F8F8")
        } else {
            cell.rightImageView.isHidden = true
            cell.backgroundColor = .white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = UserManager.shared.countryList[indexPath.row]
        self.completionSelectedLanguage?(country)
        self.dismiss(animated: true) {
            
        }
    }
}


class CountryCell: UITableViewCell {
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var rightImageView
    : UIImageView!
}
