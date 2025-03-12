//
//  QRCodeViewController.swift
//  PowerShare
//
//  Created by ADMIN on 14/07/23.
//  
//
import CoreImage
import SwiftUI
import UIKit

class QRCodeViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scanHereLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    
    var powerSource: ChargePoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initData()
    }
    
    func initFont() {
        headerLabel.font = .robotoBold(ofSize: 18)
        scanHereLabel.font = .robotoBold(ofSize: 18)
        titleLabel.font = .robotoBold(ofSize: 16)
        downloadLabel.font = .robotoMedium(ofSize: 16)
    }
    func initData() {
        let attributed = NSMutableAttributedString()
        attributed.custom(NSLocalizedString("scan_1", comment: ""), font: .robotoRegular(ofSize: 12), color: UIColor(named: "222222") ?? .black)
        attributed.custom("Powerly App ", font: .robotoBold(ofSize: 14), color: UIColor(named: "222222") ?? .black)
        attributed.custom(NSLocalizedString("scan_2", comment: ""), font: .robotoRegular(ofSize: 12), color: UIColor(named: "222222") ?? .black)
        descriptionLabel.attributedText = attributed
        
        titleLabel.text = powerSource.title
        let link = "\(universalURL)?cp_id=\(powerSource.identifier)"
        let image = CommonUtils.createQR(for: link)
        if let qrImage = image {
            qrImageView.image = qrImage
        }
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnShareButton(_ sender: Any) {
        guard let QRImage = printView.takeScreenshot() else {
            return
        }
        self.showActivityViewController(data: [QRImage])
    }
    
    @IBAction func didTapOnDownloadButton(_ sender: Any) {
        guard let QRImage = printView.takeScreenshot() else {
            return
        }
        Task {
            do {
                try await CommonUtils.saveImageToGallery(QRImage)
                self.startAnimation(isCurrentView: true)
                print("Image saved successfully.")
            } catch {
                // Handle errors
                print("Error saving image: \(error)")
            }
        }
    }
}
