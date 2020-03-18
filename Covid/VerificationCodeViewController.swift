import UIKit
import SwiftyUserDefaults

class VerificationCodeViewController: UIViewController {

    @IBOutlet weak var activationCodeTextField: UITextField!
    
    var phoneNumber: String? = Defaults.phoneNumber

    private let networkService = CovidService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = phoneNumber
        
        showLoadingIndicator()
        updateUser()
        
        activationCodeTextField.tintColor = .clear // zmazame kurzor
        activationCodeTextField.delegate = self
        if #available(iOS 12.0, *) {
            activationCodeTextField.font = UIFont.monospacedSystemFont(ofSize: 40, weight: .medium)
        }
        activationCodeTextField.text = "_ _ _ _ _ _"
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
        networkService.registerUserProfile(profileRequestData: RegisterProfileRequestData()) { [weak self] (result) in
            switch result {
            case .success:
                self?.requestToken()
            case .failure: break
            }
        }
    }
    
    private func requestToken() {
        networkService.requestMFAToken(mfaTokenRequestData: BasicRequestData()) { [weak self] (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem = nil
                    self?.activationCodeTextField.becomeFirstResponder()
                }
            case .failure: break
            }
        }
    }
    
    private func didFillNumbers() {
        Defaults.mfaToken = activationCodeTextField.text?.replacingOccurrences(of: " ", with: "")
        activationCodeTextField.resignFirstResponder()
        
        networkService.requestQuarantine(quarantineRequestData: QuarantineRequestData()) { [weak self] (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    LocationTracker.shared.startLocationTracking()
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            case .failure:
                let alertController = UIAlertController(title: "Chyba", message: "Zadané údaje sú nesprávne. Skúste znova.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Zavrieť", style: .cancel) { (_) in
                    self?.navigationItem.rightBarButtonItem = nil
                    self?.activationCodeTextField.becomeFirstResponder()
                }
                alertController.addAction(cancelAction)
                DispatchQueue.main.async {
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension VerificationCodeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // ak pridavame
        if string.count > 0 {
            if let text = textField.text as NSString?, text.contains("_"), let customRange = (textField.text as NSString?)?.range(of: "_") {
                textField.text = text.replacingCharacters(in: customRange, with: string) as String
            }
        } else { // mazeme
            if let text = textField.text as NSString? {
                var customRange: NSRange? = nil
                for i in 1...text.length {
                    let opositeSide = text.length-i
                    let iRange = NSRange(location: opositeSide, length: 1)
                    if text.containsNumber(range: iRange) {
                        customRange = NSRange(location: opositeSide, length: 1)
                        break
                    }
                }
                if let customRange = customRange {
                    textField.text = text.replacingCharacters(in: customRange, with: "_") as String
                }
            }
        }
        
        // vsetky vyplnene
        if let text = textField.text as NSString?, text.contains("_") == false {
            didFillNumbers()
        }
        
        return false
    }
}

extension NSString {
    static let numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    func containsNumber(range: NSRange) -> Bool {
        for number in NSString.numbers {
            if self.substring(with: range) == number {
                return true
            }
        }
        
        return false
    }
}
