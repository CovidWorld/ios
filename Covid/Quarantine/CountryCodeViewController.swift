/*-
* Copyright (c) 2020 Sygic
*
 * Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
 * The above copyright notice and this permission notice shall be included in
* copies or substantial portions of the Software.
*
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
*/

import UIKit
import SwiftyUserDefaults

final class CountryCodeViewController: ViewController {

    @IBOutlet private weak var countryCodeLabel: UILabel!
    @IBOutlet private weak var numberTextField: UITextField!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var countryButton: UIButton!
    @IBOutlet private var disclaimerLabel: UILabel!
    @IBOutlet private var consentSwitch: UISwitch!

    private var countryCodes: [(String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self

        if #available(iOS 13.0, *) {
            pickerView.overrideUserInterfaceStyle = .light
        }

        loadJSONToArray()

        title = LocalizedString(forKey: "phone.verification.title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedString(forKey: "button.next"), style: .done, target: self, action: #selector(didTapDone))

        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        view.addGestureRecognizer(tapRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numberTextField.becomeFirstResponder()
    }

    @IBAction private func didTapCountryButton(_ sender: Any) {
        pickerView.isHidden = numberTextField.isFirstResponder ? false : !pickerView.isHidden
        numberTextField.resignFirstResponder()
    }
}

extension CountryCodeViewController {

    @objc
    func didTapSkip(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard.controller(ofType: MainViewController.self)
    }

    @objc
    private func didTapDone() {
        numberTextField.resignFirstResponder()
        pickerView.isHidden = true

        guard let countryCode = countryCodeLabel.text,
            let phoneNumber = numberTextField.text,
            phoneNumber.count >= 6,
            consentSwitch.isOn else {

                let message = consentSwitch.isOn ?
                                LocalizedString(forKey: "error.phone.wrongDigits") : LocalizedString(forKey: "phone.user.consent")
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                if consentSwitch.isOn {
                    alert.addAction(UIAlertAction(title: LocalizedString(forKey: "button.edit"), style: .cancel))
                } else {
                    alert.addAction(UIAlertAction(title: LocalizedString(forKey: "button.cancel"), style: .cancel))
                    let agreeAction = UIAlertAction(title: LocalizedString(forKey: "button.agree"), style: .default) { (_) in
                        self.consentSwitch.isOn = true
                    }
                    alert.addAction(agreeAction)
                    alert.preferredAction = agreeAction
                }
                present(alert, animated: true, completion: nil)
                return
        }

        let number = "\(countryCode) \(phoneNumber)"
        let message = LocalizedString(forKey: "phone.registration.input.verification") + "\n\n\(number)"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let editAction = UIAlertAction(title: "button.no", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "button.yes", style: .default) { [weak self] (_) in
            Defaults.tempPhoneNumber = number.replacingOccurrences(of: " ", with: "")
            self?.performSegue(.phoneNumberVerification)
        }
        alert.addAction(editAction)
        alert.addAction(yesAction)
        alert.preferredAction = yesAction

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
            if let jsonResult = jsonResult as? [String: Any], let dictionary = jsonResult["array"] as? [String: String] {

                countryCodes = dictionary.map { ($0.key, $0.value) }
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
        "\(countryCodes[row].0) +\(countryCodes[row].1)"
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

extension CountryCodeViewController: HasStoryBoardIdentifier {
    static let storyboardIdentifier = "CountryCodeViewController"
}
