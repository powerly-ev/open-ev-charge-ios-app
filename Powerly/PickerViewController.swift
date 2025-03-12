//
//  SelectLanguageViewController.swift
//  PowerShare
//
//  Created by admin on 10/02/22.
//  
//

import UIKit

class PickerViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var objTableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    var titleString = ""
    var valueArray = [String]()
    var selectedIndex = 0
    var completionSelectedValue: ((String, Int) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.font = .robotoMedium(ofSize: 16)
        headerLabel.text = titleString
    }
    
    override func viewDidLayoutSubviews() {
        tableViewHeight.constant = objTableView.contentSize.height
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
}

extension PickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valueArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LanguageCell.className, for: indexPath) as? LanguageCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.languageLabel.text = valueArray[indexPath.row]
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
        let language = valueArray[indexPath.row]
        self.dismiss(animated: true) {
            self.completionSelectedValue?(language, indexPath.row)
        }
    }
}
