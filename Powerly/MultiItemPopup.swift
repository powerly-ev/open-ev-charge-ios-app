//
//  MultiItemPopup.swift
//  PowerShare
//
//  Created by admin on 28/02/22.
//  
//

import UIKit

class MultiItemPopup: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    var options = [MenuOption]()
    var completionItem:((MenuOption) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        tableHeight.constant = tableView.contentSize.height + 80
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
}

extension MultiItemPopup: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MultiCell", for: indexPath)
        cell.selectionStyle = .none
        if let label = cell.viewWithTag(1) as? UILabel {
            label.font = .robotoMedium(ofSize: 14)
            label.text = options[indexPath.row].localizedText
            if isLanguageArabic {
                label.textAlignment = .right
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
