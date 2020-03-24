import UIKit
import SwiftyUserDefaults

class CountryCodeViewController: UIViewController {

    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet var disclaimerLabel: UILabel!
    
    private var countryCodes: [(String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
        
        if #available(iOS 13.0, *) {
            pickerView.overrideUserInterfaceStyle = .light
        }
        
        loadJSONToArray()
        
        title = "Overenie čísla"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ďalej", style: .done, target: self, action: #selector(didTapDone))
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        view.addGestureRecognizer(tapRecognizer)
        
        if presentingViewController != nil {
            let leftBarItem = UIBarButtonItem(title: "Preskočiť", style: .plain, target: self, action: #selector(didTapSkip(_:)))
            navigationItem.leftBarButtonItem = leftBarItem
            disclaimerLabel.isHidden = false
        }
    }
    
    @IBAction func didTapCountryButton(_ sender: Any) {
        pickerView.isHidden = numberTextField.isFirstResponder ? false : !pickerView.isHidden
        numberTextField.resignFirstResponder()
    }
}

extension CountryCodeViewController {
    
    @objc
    func didTapSkip(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as UIViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    @objc
    private func didTapDone() {
        numberTextField.resignFirstResponder()
        pickerView.isHidden = true
        
        guard let countryCode = countryCodeLabel.text,
            let phoneNumber = numberTextField.text,
            phoneNumber.count == 9  else {
                let message = "Zadali ste nesprávne číslo. Zadajte 9 miestne číslo bez 0 na začiatku"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Upraviť", style: .cancel))

                present(alert, animated: true, completion: nil)
                return
        }

        let number = "\(countryCode) \(phoneNumber)"
        let message = "Zadali ste správne čislo?\n\n\(number)"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Nie", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Áno", style: .default) { [weak self] (_) in
            Defaults.tempPhoneNumber = number.replacingOccurrences(of: " ", with: "")
            self?.performSegue(withIdentifier: "verification", sender: nil)
        }
        alert.addAction(editAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func didTapView() {
        numberTextField.resignFirstResponder()
        pickerView.isHidden = true
    }
    
    private func loadJSONToArray() {
        guard let path = Bundle.main.path(forResource: "CountryCodes", ofType: "json") else { return }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, Any>, let dictionary = jsonResult["array"] as? Dictionary<String, String> {
                
                countryCodes = dictionary.map{ ($0.key, $0.value) }
                countryCodes.sort { $0.0 < $1.0 }
                pickerView.reloadAllComponents()
                if let slovakia = countryCodes.firstIndex(where: {$0.1 == "421"}) {
                    pickerView.selectRow(slovakia, inComponent: 0, animated: false)
                    countryButton.setTitle(countryCodes[slovakia].0, for: .normal)
                }
            }
        } catch {
            // handle error
        }
    }
}

extension CountryCodeViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(countryCodes[row].0) +\(countryCodes[row].1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryCodeLabel.text = "+\(countryCodes[row].1)"
        countryButton.setTitle(countryCodes[row].0, for: .normal)
    }
}

extension CountryCodeViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { countryCodes.count }
}
