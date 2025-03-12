//
//  AddOptionsPopup.swift
//  PowerShare
//
//  Created by admin on 11/05/23.
//  
//

import UIKit

struct AddEVOption {
    let menu: MenuOption
    let image: UIImage?
}

class AddOptionsPopup: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    var options = [AddEVOption]()
    var completionItem: ((AddEVOption) -> Void)?
    
    override func viewDidLayoutSubviews() {
        tableHeight.constant = tableView.contentSize.height + 80
    }
    
    @IBAction func didTapOutSide(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
}

extension AddOptionsPopup: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddEVCell", for: indexPath)
        cell.selectionStyle = .none
        if let label = cell.viewWithTag(1) as? UILabel {
            label.font = .robotoMedium(ofSize: 14)
            label.text = options[indexPath.row].menu.localizedText
            if isLanguageArabic {
                label.textAlignment = .right
            }
        }
        if let imageView = cell.viewWithTag(2) as? UIImageView {
            imageView.image = options[indexPath.row].image
        }
        if isLanguageArabic {
            if let stackView = cell.viewWithTag(3) as? UIStackView {
                stackView.semanticContentAttribute = .forceRightToLeft
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.completionItem?(self.options[indexPath.row])
        }
    }
}
