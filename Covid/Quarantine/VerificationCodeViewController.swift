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
import JWTDecode

final class VerificationCodeViewController: ViewController {

    @IBOutlet private weak var activationCodeTextField: UITextField!

    var phoneNumber: String? = Defaults.tempPhoneNumber

    private let ncziService = NCZIService()
    private let networkService = CovidService()
    private var indicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = phoneNumber

        showLoadingIndicator()

        requestToken()

        if #available(iOS 13.0, *) {
            activationCodeTextField.font = UIFont.monospacedSystemFont(ofSize: 40, weight: .medium)
        }
    }
}

// MARK: - Private
extension VerificationCodeViewController {
    private func showLoadingIndicator() {
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator!)
        indicator?.startAnimating()
    }

    private func cancel() {
        indicator?.stopAnimating()
        navigationItem.rightBarButtonItem = nil
        navigationController?.popToRootViewController(animated: true)
    }

    private func requestToken() {
        ncziService.requestOTPSend(data: OTPSendRequestData(vPhoneNumber: phoneNumber ?? "")) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let error = data.errors?.first {
                        let message = error.description
                        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let backAction = UIAlertAction(title: LocalizedString(forKey:
                        "button.backShort"), style: .cancel) { [weak self] (_) in
                            self?.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(backAction)

                        self?.present(alert, animated: true, completion: nil)
                    } else {
                        self?.navigationItem.rightBarButtonItem = nil
                        self?.activationCodeTextField.becomeFirstResponder()
                    }
                case .failure:
                    let message = LocalizedString(forKey: "error.phone.verification")
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let editAction = UIAlertAction(title: LocalizedString(forKey: "button.no"), style: .cancel) { [weak self] _ in
                        self?.cancel()
                    }
                    let yesAction = UIAlertAction(title: LocalizedString(forKey: "button.yes"), style: .default) { [weak self] (_) in
                        self?.requestToken()
                    }
                    alert.addAction(editAction)
                    alert.addAction(yesAction)

                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    private func didFillNumbers() {
        let tempToken = activationCodeTextField.text?.replacingOccurrences(of: " ", with: "")
        activationCodeTextField.resignFirstResponder()
        showLoadingIndicator()

        let requestData = OTPValidateRequestData(vPhoneNumber: phoneNumber ?? "", nOTP: tempToken ?? "")
        ncziService.requestOTPValidate(data: requestData) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let error = data.errors?.first {
                        self?.requestFailed(message: error.description)
                    } else {
                        do {
                            let jwtData = try decode(jwt: data.payload?.vAccessToken ?? "")

                            Defaults.covidPass = jwtData.claim(name: "vCovid19Pass").string
                            Defaults.QPass = jwtData.claim(name: "vQPass").string
                            Defaults.quarantineCity = jwtData.claim(name: "vQuarantineAddressCity").string
                            Defaults.quarantineStreet = jwtData.claim(name: "vQuarantineAddressStreetName").string
                            Defaults.quarantineStreetNumber = jwtData.claim(name: "vQuarantineAddressStreetNumber").string
                            Defaults.quarantineLatitude = jwtData.claim(name: "nQuarantineAddressLatitude").double
                            Defaults.quarantineLongitude = jwtData.claim(name: "nQuarantineAddressLongitude").double

                            self?.showAddressConfirmationScreen()
                        } catch {
                            self?.requestFailed(message: nil)
                        }
                    }
                case .failure:
                    self?.requestFailed(message: nil)
                }
            }
        }
    }

    private func requestFailed(message: String?) {
        let alertController = UIAlertController(title: LocalizedString(forKey: "error.title"), message: message ?? LocalizedString(forKey: "error.phone.wrong.input"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizedString(forKey: "button.close"), style: .cancel) { (_) in
            self.navigationItem.rightBarButtonItem = nil
            self.activationCodeTextField.becomeFirstResponder()
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension VerificationCodeViewController {

    private func showAddressConfirmationScreen() {
        guard let confirmationViewController = UIStoryboard.controller(ofType: AddressConfirmationViewController.self) else {
            return
        }

        confirmationViewController.streetText = "\(Defaults.quarantineStreet ?? "") \(Defaults.quarantineStreetNumber ?? "")"
        confirmationViewController.cityText = Defaults.quarantineCity

        navigationController?.pushViewController(confirmationViewController, animated: true)
    }
}

extension VerificationCodeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            let text = updatedText.replacingOccurrences(of: " ", with: "")
            if text.count > 6 {
                return false
            }
            textField.text = text.components(withLength: 1).joined(separator: " ")
            if text.count == 6 {
                didFillNumbers()
                return false
            }
            return false
        }
        return true
    }
}

extension String {
    func components(withLength length: Int) -> [String] {
        stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}
