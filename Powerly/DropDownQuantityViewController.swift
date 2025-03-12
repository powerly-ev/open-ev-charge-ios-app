//
//  DropDownQuantityViewController.swift
//  PowerShare
//
//  Created by admin on 13/10/22.
//  
//

import UIKit

class DropDownQuantityViewController: UIViewController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var list = [Int]()
    var selectedQuantity = "0"
    
    var popUpRect = CGRect.zero
    var yValue = CGFloat.zero
    var completionSelectedIndex: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.addDropshadowtoVIEW()
    }
    
    override func viewDidLayoutSubviews() {
        topConstraint.constant = yValue
        let height = tableView.contentSize.height + 16
        if (yValue + height) > screenHeight {
            heightConstraint.constant = screenHeight - yValue - 32
        } else {
            heightConstraint.constant = tableView.contentSize.height + 16
        }
    }
    
    @IBAction func didTapOnOutSideAction(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
}

extension DropDownQuantityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.className, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let value = list[indexPath.row].description
        if value == selectedQuantity {
            cell.outView.backgroundColor = .skeletonDefault
        } else {
            cell.outView.backgroundColor = .white
        }
        cell.rightImageView.isHidden = true
        cell.categoryTitleLabel.text = value
        return cell
    }
}

extension DropDownQuantityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.completionSelectedIndex?(self.list[indexPath.row])
        }
    }
}
