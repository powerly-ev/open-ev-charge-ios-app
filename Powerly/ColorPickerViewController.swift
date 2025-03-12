//
//  ColorPickerViewController.swift
//  PowerShare
//
//  Created by ADMIN on 09/08/23.
//  
//

import UIKit

class ColorPickerViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var hightCollectionView: NSLayoutConstraint!
    var allCarColors: [CarColor] = []
    var selectedIndex = -1
    var completionContinue: ((CarColor) -> Void)?
    
    override func viewDidLayoutSubviews() {
        hightCollectionView.constant = colorCollectionView.contentSize.height
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ColorPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCarColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell1", for: indexPath)
        if let imageView = cell.viewWithTag(2) as? UIImageView, let outView = cell.viewWithTag(1) {
            if let color = allCarColors.value(at: indexPath.item) {
                imageView.image = nil
                imageView.backgroundColor = UIColor(hex: color.hex)
                if selectedIndex == indexPath.item {
                    outView.setBorderWidth(width: 3)
                    outView.setBorderColor(color: UIColor(hex: color.hex))
                } else {
                    outView.setBorderWidth(width: 0)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let color = allCarColors.value(at: indexPath.item) {
            self.dismiss(animated: true) {
                self.completionContinue?(color)
            }
        }
    }
}
