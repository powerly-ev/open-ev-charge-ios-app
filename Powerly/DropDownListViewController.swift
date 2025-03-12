//
//  DropDownListViewController.swift
//  PowerShare
//
//  Created by admin on 08/03/22.
//  
//

import UIKit

class DropDownListViewController: UIViewController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var list = [String]()
    var selectedServiceId = ""
    
    var popUpRect = CGRect.zero
    var yValue = CGFloat.zero
    var completionSelectedIndex: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.addDropshadowtoVIEW()
    }
    
    override func viewDidLayoutSubviews() {
        topConstraint.constant = yValue
        widthConstraint.constant = popUpRect.width
        heightConstraint.constant = popUpRect.height + 16
    }
    
    @IBAction func didTapOnOutSideAction(_ sender: Any) {
        self.dismiss(animated: false) {
        }
    }
}

extension DropDownListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.className, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let value = list[indexPath.row]
        cell.categoryTitleLabel.text = value
        cell.rightImageView.isHidden = true
        return cell
    }
}

extension DropDownListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: false) {
            self.completionSelectedIndex?(indexPath.row)
        }
    }
}
