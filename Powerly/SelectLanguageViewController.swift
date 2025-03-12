//
//  SelectLanguageViewController.swift
//  PowerShare
//
//  Created by admin on 10/02/22.
//  
//

import UIKit

class SelectLanguageViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var objTableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    var lanArray = ["English", "العربية", "Español", "Français"]
    var selectedIndex = 0
    var completionSelectedLanguage:((String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.font = .robotoMedium(ofSize: 16)
        headerLabel.text = CommonUtils.getStringFromXML(name: "select_language")
        switch isLanguageType {
            case "en":
                self.selectedIndex = 0
                
            case "ar":
                selectedIndex = 1
                
            case "es":
                selectedIndex = 2
                
            case "fr":
                selectedIndex = 3
            
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableViewHeight.constant = objTableView.contentSize.height
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func didTapOnOutSideButton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
}

extension SelectLanguageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lanArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LanguageCell.className, for: indexPath) as? LanguageCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.languageLabel.text = lanArray[indexPath.row]
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
        let language = lanArray[indexPath.row]
        self.dismiss(animated: true) {
            self.completionSelectedLanguage?(language)
        }
    }
}

class LanguageCell: UITableViewCell {
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var rightImageView
    : UIImageView!
    
    override func awakeFromNib() {
        languageLabel.font = .robotoMedium(ofSize: 16)
    }
}
