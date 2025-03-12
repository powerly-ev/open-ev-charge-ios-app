//
//  SearchLocationPopup.swift
//  PowerShare
//
//  Created by admin on 14/02/22.
//  
//
import GooglePlaces
import RxSwift
import UIKit

class SearchLocationPopup: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var objTableView: UITableView!
    
    var placesClient = GMSPlacesClient.shared()
    var arrayPrediction = [GMSAutocompletePrediction]()
    var completionLocation: ((GMSPlace) -> Void)?
    
    let disponseBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        CommonUtils.logFacebookCustomEvents("search_location_popup", contentType: [:])
        initFont()
        objTableView.keyboardDismissMode = .onDrag
        searchTextField.becomeFirstResponder()
        headerLabel.text = CommonUtils.getStringFromXML(name: "search_location")
        searchTextField.placeholder = CommonUtils.getStringFromXML(name: "search_location")
        
        searchTextField.rx.text.orEmpty
                .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [self] (text) in
                    let filter = GMSAutocompleteFilter()
                    filter.types = []
                    placesClient.findAutocompletePredictions(fromQuery: text, filter: filter, sessionToken: nil) { results, error in
                        DispatchQueue.main.async {
                            if let results = results {
                                if results.count > 0 {
                                    self.arrayPrediction = results
                                } else {
                                    self.arrayPrediction = [GMSAutocompletePrediction]()
                                }
                                self.objTableView.reloadData()
                            }
                        }
                    }
                }).disposed(by: disponseBag)
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 16)
        searchTextField.font = .robotoRegular(ofSize: 14)
    }
    

    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: false)
    }
    

}

extension SearchLocationPopup: UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        //let newString = textField.text!.replacingCharacters(in:  Range(range, in: textField.text!)!, with: string)
//        
//        return true
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPrediction.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath)
        cell.selectionStyle = .none
        let firstLabel = cell.viewWithTag(2) as? UILabel
        firstLabel?.font = .robotoRegular(ofSize: 14)
        let secondLabel = cell.viewWithTag(3) as? UILabel
        secondLabel?.font = .robotoRegular(ofSize: 12)
        let pre = arrayPrediction[indexPath.row]
        firstLabel?.text = pre.attributedPrimaryText.string
        secondLabel?.text = pre.attributedSecondaryText?.string
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pre = arrayPrediction[indexPath.row]
        searchTextField.resignFirstResponder()
        placesClient.lookUpPlaceID(pre.placeID) { place, error in
            if let place = place {
                self.dismiss(animated: false)
                self.completionLocation?(place)
            }
        }

    }
}
