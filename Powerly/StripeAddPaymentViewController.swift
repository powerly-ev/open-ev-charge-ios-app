//
//  StripeAddPaymentViewController.swift
//  Powerly
//
//  Created by ADMIN on 31/05/24.
//  
//
import Stripe
import StripeCardScan
import StripePaymentsUI
import UIKit

class StripeAddPaymentViewController: UIViewController {
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    var completionToken: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardTextField.postalCodeEntryEnabled = false
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapOnAddCardButton(_ sender: Any) {
        if cardTextField.isValid {
            let params = cardTextField.paymentMethodParams
            CommonUtils.showProgressHud()
            STPAPIClient.shared.createToken(withCard: STPCardParams(paymentMethodParams: params)) { [weak self] token, _ in
                CommonUtils.hideProgressHud()
                if let tokenId = token?.tokenId {
                    self?.addNewCardEndPoint(["token": tokenId])
                }
            }
        }
    }
    
    func addNewCardEndPoint(_ responseBody: [String: String]) {
        var dict = responseBody
        dict.removeValue(forKey: "card_holder_name")
        dict.removeValue(forKey: "expiry_date")
        NetworkManager().addCard(params: dict) { success, message, _ in
            if success == 1 {
                self.dismiss(animated: true) {
                    self.completionToken?()
                }
            }
            self.alertWithTitle(title: "", message: message) {}
        }
    }
    
    @IBAction func didTapOnScanCardButton(_ sender: Any) {
        let cardScanSheet = CardScanSheet()
                
        // Present it w/o any adjustments so it uses the default sheet presentation.
        cardScanSheet.present(from: self) { [weak self] result in
            switch result {
            case .completed(let scannedCard):
            let cardParams = STPCardParams()
            cardParams.number = scannedCard.pan
            cardParams.expMonth = UInt(scannedCard.expiryMonth ?? "") ?? 0
            cardParams.expYear = UInt(scannedCard.expiryYear ?? "") ?? 0

            let paymentMethodCardParams = STPPaymentMethodCardParams(cardSourceParams: cardParams)
            let paymentMethodParams = STPPaymentMethodParams(card: paymentMethodCardParams, billingDetails: nil, metadata: nil)

            self?.cardTextField.paymentMethodParams = paymentMethodParams
                
            case .canceled:
                print("scan canceled")
                
            case .failed(let error):
                 print("scan failed: \(error.localizedDescription)")
            }
        }
    }
}
