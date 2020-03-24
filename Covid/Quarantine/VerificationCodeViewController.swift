import UIKit
import SwiftyUserDefaults

class VerificationCodeViewController: UIViewController {

    @IBOutlet weak var activationCodeTextField: UITextField!
    
    var phoneNumber: String? = Defaults.tempPhoneNumber

    private let networkService = CovidService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = phoneNumber
        
        showLoadingIndicator()
        
        updateUser()
        
        if #available(iOS 12.0, *) {
            activationCodeTextField.font = UIFont.monospacedSystemFont(ofSize: 40, weight: .medium)
        }
    }
}

//MARK: - Private
extension VerificationCodeViewController {
    private func showLoadingIndicator() {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        indicator.startAnimating()
    }
    
    private func updateUser() {
        networkService.registerUserProfile(profileRequestData: RegisterProfileRequestData(phoneNumber: phoneNumber)) { [weak self] (result) in
            switch result {
            case .success(let profile):
                if Defaults.profileId == nil {
                    Defaults.profileId = profile.profileId
                }
                self?.requestToken()
            case .failure:
                DispatchQueue.main.async {
                    let message = "Chyba pri overovaní čísla. Skúsiť znovu?"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let editAction = UIAlertAction(title: "Nie", style: .cancel, handler: nil)
                    let yesAction = UIAlertAction(title: "Áno", style: .default) { [weak self] (_) in
                        self?.updateUser()
                    }
                    alert.addAction(editAction)
                    alert.addAction(yesAction)
                    
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func requestToken() {
        networkService.requestMFAToken(mfaTokenRequestData: BasicRequestData()) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                        self?.navigationItem.rightBarButtonItem = nil
                        self?.activationCodeTextField.becomeFirstResponder()
                case .failure:
                        let message = "Chyba pri vyžiadaní overovacieho kódu. Skúsiť znovu?"
                        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let editAction = UIAlertAction(title: "Nie", style: .cancel, handler: nil)
                        let yesAction = UIAlertAction(title: "Áno", style: .default) { [weak self] (_) in
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
        
        if presentingViewController != nil {
            networkService.requestMFATokenPhone(mfaTokenPhoneRequestData: MFATokenPhoneRequestData(mfaToken: tempToken)) { [weak self] (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                            Defaults.phoneNumber = self?.phoneNumber
                            Defaults.mfaToken = tempToken
                            self?.presentingViewController?.dismiss(animated: true, completion: nil)
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as UIViewController
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                    case .failure:
                        self?.requestFailed()
                    }
                }
            }
            return
        }
        
        networkService.requestQuarantine(quarantineRequestData: QuarantineRequestData(mfaToken: tempToken)) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                        Defaults.phoneNumber = self?.phoneNumber
                        Defaults.mfaToken = tempToken
                        LocationTracker.shared.startLocationTracking()
                        self?.navigationController?.popToRootViewController(animated: true)
                case .failure:
                    self?.requestFailed()
                }
            }
        }
    }
    
    private func requestFailed() {
        let alertController = UIAlertController(title: "Chyba", message: "Zadané údaje sú nesprávne. Skúste znova.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Zavrieť", style: .cancel) { (_) in
            self.navigationItem.rightBarButtonItem = nil
            self.activationCodeTextField.becomeFirstResponder()
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}
