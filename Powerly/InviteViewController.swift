//
//  InviteViewController.swift
//  PowerShare
//
//  Created by admin on 24/11/21.

//

import UIKit

class InviteViewController: UIViewController {
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var objActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var inviteQRDescriptionLabel: UILabel!
    
    var whatsappUrlReferral: String = shareURL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        btnCopy.setBorderWidth(width: 2)
        btnCopy.setBorderColor(color: UIColor(named: "D4D4D4"))
        CommonUtils.logFacebookCustomEvents("invite_open", contentType: [:])
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblTitle.text = CommonUtils.getStringFromXML(name: "invite")
        btnCopy.setTitle(CommonUtils.getStringFromXML(name: "copy_referral_link"), for: .normal)
        shareButton.setTitle(CommonUtils.getStringFromXML(name: "share_referral_link"), for: .normal)
        inviteQRDescriptionLabel.text = CommonUtils.getStringFromXML(name: "invite_QR_description")
    }
    
    func initFont() {
        lblTitle.font = .robotoMedium(ofSize: 16)
        inviteQRDescriptionLabel.font = .robotoRegular(ofSize: 14)
        btnCopy.titleLabel?.font = .robotoMedium(ofSize: 16)
        shareButton.titleLabel?.font = .robotoMedium(ofSize: 16)
    }
    
    func initData() {
        if whatsappUrlReferral != "" {
            let image = CommonUtils.createQR(for: whatsappUrlReferral)
            if let image = image {
                qrImageView.image = image
            }
        }
    }
    
    @IBAction func btnActionSideMenu(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
        // navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActionCopyLink(_ sender: Any) {
        let shareText = self.whatsappUrlReferral
        if shareText == "" {
            return
        }

        UIPasteboard.general.string = shareText
        btnCopy.setTitle(CommonUtils.getStringFromXML(name: "link_copied"), for: .normal)
    }
    
    @IBAction func btnActionShareCode(_ sender: Any) {
        let shareText = self.whatsappUrlReferral
        if shareText == "" {
            return
        }
        self.showActivityViewController(data: [shareText])
    }
}
