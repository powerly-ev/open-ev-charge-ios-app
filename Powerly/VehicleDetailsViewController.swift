//
//  VehicleDetailsViewController.swift
//  PowerShare
//
//  Created by ADMIN on 24/07/23.
//  
//

import UIKit

class VehicleDetailsViewController: UIViewController {
    @IBOutlet weak var headerContentView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var colorValueLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var yearValueLabel: UILabel!
    @IBOutlet weak var fuelTypeLabel: UILabel!
    @IBOutlet weak var fuelTypeValueLabel: UILabel!
    @IBOutlet weak var chargingTypeLabel: UILabel!
    @IBOutlet weak var chargingTypeValueLabel: UILabel!
    @IBOutlet weak var saveNextLabel: UILabel!
    @IBOutlet weak var chargingTypeView: UIView!
    @IBOutlet weak var leftArrowImageView: UIImageView!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    @IBOutlet weak var colorCollectionVie: UICollectionView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var fuelTypePickerView: UIPickerView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var fuelTypeView: UIView!
    @IBOutlet weak var selectTypeView: UIView!
    @IBOutlet weak var saveNextView: UIView!
    
    var viewModel: AddVehicleViewModel!
    var addVehicle: AddVehicle?
    var completion: ((AddVehicle) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        initUI()
        viewModel.setupYears()
        viewModel.setupColor()
        colorCollectionVie.delegate = self
        colorCollectionVie.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        fuelTypePickerView.delegate = self
        fuelTypePickerView.dataSource = self
        addVehicle = self.viewModel.getData()
        loadData()
        checkRequiredFields()
    }
    
    func initFont() {
        headerLabel.font = .robotoMedium(ofSize: 18)
        countLabel.font = .robotoMedium(ofSize: 14)
        colorLabel.font = .robotoRegular(ofSize: 14)
        colorValueLabel.font = .robotoMedium(ofSize: 14)
        yearLabel.font = .robotoRegular(ofSize: 14)
        yearValueLabel.font = .robotoMedium(ofSize: 14)
        fuelTypeLabel.font = .robotoRegular(ofSize: 14)
        fuelTypeValueLabel.font = .robotoMedium(ofSize: 14)
        chargingTypeLabel.font = .robotoRegular(ofSize: 14)
        chargingTypeValueLabel.font = .robotoRegular(ofSize: 14)
        saveNextLabel.font = .robotoMedium(ofSize: 16)
    }
    
    func initUI() {
        if isLanguageArabic {
            self.chargingTypeView.semanticContentAttribute = .forceRightToLeft
            self.colorView.semanticContentAttribute = .forceRightToLeft
            self.yearView.semanticContentAttribute = .forceRightToLeft
            self.fuelTypeView.semanticContentAttribute = .forceRightToLeft
            self.selectTypeView.semanticContentAttribute = .forceRightToLeft
            self.chargingTypeValueLabel.textAlignment = .right
            self.chargingTypeLabel.textAlignment = .right
            
            self.headerContentView.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func loadData() {
        // setup years
        if let year = addVehicle?.year, let yearIndex = viewModel.years.firstIndex(of: year ) {
            pickerView.selectRow(yearIndex, inComponent: 0, animated: true)
            self.setYear(selectedYear: year)
        } else {
            addVehicle?.year = self.viewModel.years.first 
        }
        
        // setup colors
        if let color = addVehicle?.color, let actualColor = CommonUtils.allCarColors().first(where: { $0.name == color }) {
            self.setColor(color: actualColor)
            self.viewModel.updateColor(color: actualColor)
        }
        
        // setup fuelType
        if let fuelType = addVehicle?.fuelType, let fuelIndex = viewModel.fuelTypes.firstIndex(of: fuelType) {
            fuelTypePickerView.selectRow(fuelIndex, inComponent: 0, animated: true)
            self.updateFuelType(value: fuelType)
        } else {
            if let index = viewModel.fuelTypes.firstIndex(where: { $0 == "Electric" }) {
                self.updateFuelType(value: "Electric")
                fuelTypePickerView.selectRow(index, inComponent: 0, animated: true)
            }
        }
        
        // charging type
        if let chargingType = addVehicle?.connector {
            self.chargingTypeValueLabel.text = chargingType.name
        }
    }
    
    func checkRequiredFields() {
        saveNextView.backgroundColor = UIColor(named: "E5E5E5")
        saveNextLabel.textColor = UIColor(named: "222222")
        leftArrowImageView.tintColor = UIColor(named: "222222")
        rightArrowImageView.tintColor = UIColor(named: "222222")
        guard let addVehicle = addVehicle else {
            return
        }
        guard addVehicle.color != nil, addVehicle.year != nil, addVehicle.fuelType != nil else {
            return
        }
        if let fuelType = addVehicle.fuelType, fuelType == "Plug-In Hybrid" || fuelType == "Electric", addVehicle.connector == nil {
            return
        }
        saveNextView.backgroundColor = UIColor(named: "222222")
        saveNextLabel.textColor = UIColor(named: "WHITE")
        leftArrowImageView.tintColor = UIColor(named: "WHITE")
        rightArrowImageView.tintColor = UIColor(named: "WHITE")
    }
    
    @IBAction func didTapOnSaveNextButton(_ sender: Any) {
        if addVehicle?.title == nil, let name = addVehicle?.manufacturer?.name {
            addVehicle?.title = name
        }
        guard let addVehicle = addVehicle else {
            return
        }
        guard addVehicle.color != nil, addVehicle.year != nil, addVehicle.fuelType != nil else {
            return
        }
        if let fuelType = addVehicle.fuelType, fuelType == "Plug-In Hybrid" || fuelType == "Electric", addVehicle.connector == nil {
            return
        }
        
        self.dismiss(animated: true) {
            self.completion?(addVehicle)
        }
    }
    
    @IBAction func didTapOnCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func updateFuelType(value: String) {
        self.addVehicle?.fuelType = value
        if value == "Plug-In Hybrid" || value == "Electric" {
            self.chargingTypeView.isHidden = false
        } else {
            self.chargingTypeView.isHidden = true
        }
        self.fuelTypeValueLabel.text = "(" + NSLocalizedString(value, comment: "") + ")"
        checkRequiredFields()
    }
    
    @IBAction func didTapOnSelectChargingTypeButton(_ sender: Any) {
        guard let typesVC = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: ChargerTypesViewController.className) as? ChargerTypesViewController else {
            return
        }
        typesVC.completionContinue = { connector in
            self.addVehicle?.connector = connector
            self.chargingTypeValueLabel.text = connector.name
            self.checkRequiredFields()
        }
        typesVC.modalPresentationStyle = .overFullScreen
        self.present(typesVC, animated: true, completion: nil)
    }
}

extension VehicleDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == fuelTypePickerView {
            return viewModel.fuelTypes.count
        }
        return viewModel.years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == fuelTypePickerView {
            return NSLocalizedString(viewModel.fuelTypes[row], comment: "")
        }
        return String(viewModel.years[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == fuelTypePickerView {
            let fuelType = viewModel.fuelTypes[row]
            self.updateFuelType(value: fuelType)
        } else {
            let selectedYear = viewModel.years[row]
            self.setYear(selectedYear: selectedYear)
        }
        checkRequiredFields()
    }
    
    func setYear(selectedYear: Int) {
        self.addVehicle?.year = selectedYear
        self.yearValueLabel.text = "(\(selectedYear))"
    }
}

extension VehicleDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.topCarColors.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        if let imageView = cell.viewWithTag(2) as? UIImageView, let outView = cell.viewWithTag(1) {
            if let color = viewModel.topCarColors.value(at: indexPath.item) {
                imageView.image = nil
                imageView.backgroundColor = UIColor(hex: color.hex)
                if viewModel.selectedIndex == indexPath.item {
                    outView.setBorderWidth(width: 3)
                    outView.setBorderColor(color: UIColor(hex: color.hex))
                } else {
                    outView.setBorderWidth(width: 0)
                }
            } else {
                imageView.image = UIImage(named: "abstract")
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let color = viewModel.topCarColors.value(at: indexPath.item) {
            self.viewModel.selectedIndex = indexPath.item
            self.setColor(color: color)
        } else {
            guard let colorVC = UIStoryboard(storyboard: .vehicle).instantiateViewController(withIdentifier: ColorPickerViewController.className) as? ColorPickerViewController else {
                return
            }
            colorVC.allCarColors = CommonUtils.allCarColors()
            colorVC.completionContinue = { color in
                self.viewModel.selectedIndex = 0
                self.viewModel.updateColor(color: color)
                self.setColor(color: color)
                self.checkRequiredFields()
            }
            colorVC.modalPresentationStyle = .overCurrentContext
            self.present(colorVC, animated: true, completion: nil)
        }
    }
    
    func setColor(color: CarColor) {
        self.colorValueLabel.text = "(\(color.name))"
        self.colorCollectionVie.reloadData()
        self.addVehicle?.color = color.name
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
