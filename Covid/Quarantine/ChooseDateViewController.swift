import UIKit
import SwiftyUserDefaults

class ChooseDateViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var textFieldBackgroundView: UIView!
    @IBOutlet weak var pickerContainerView: UIView!
    
    override func loadView() {
        super.loadView()

        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        view.addGestureRecognizer(tapRecognizer)
        
        setupUI()
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        didTapView()
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        Defaults.quarantineStart = datePicker.date
    }
    
    @IBAction func didChangePickerValue() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
}

extension ChooseDateViewController {
    
    @objc
    private func didTapView() {
        dateTextField.resignFirstResponder()
        
        let topOffset = CGPoint(x: 0, y: 0)
        scrollView.setContentOffset(topOffset, animated: true)
        pickerContainerView.isHidden = true
        continueButton.isHidden = false
        continueButton.isEnabled = !(dateTextField.text?.isEmpty ?? false)
        editImageView.isHidden = dateTextField.text?.isEmpty ?? false
    }
    
    private func setupUI() {
        pickerContainerView.isHidden = true
        continueButton.isHidden = false
        continueButton.isEnabled = false
        scrollView.isScrollEnabled = false
        editImageView.isHidden = true
        textFieldBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
        
        let font: UIFont = UIFont(name: "Inter-Light", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .light)
        let attributes = [NSMutableAttributedString.Key.font: font,
                           .foregroundColor: UIColor(red: 76/255, green: 86/255, blue: 252/255, alpha: 1)]
        let attrPlaceholder = NSMutableAttributedString(string: "Kliknite pre výber dátumu", attributes: attributes)
        
        dateTextField.attributedPlaceholder = attrPlaceholder
        dateTextField.tintColor = .clear // zmazame kurzor
        
        let calendar = Calendar.current
        let currentDate = Date()
        var components = DateComponents()
        let quarantineDuration = (UIApplication.shared.delegate as? AppDelegate)?.remoteConfig?["quarantineDuration"].stringValue ?? "14"
        
        components.calendar = Calendar.current
        components.day = -(Int(quarantineDuration) ?? 14) + 1
        let minDate = calendar.date(byAdding: components, to: currentDate)

        datePicker.minimumDate = minDate
        datePicker.maximumDate = currentDate
        datePicker.date = currentDate
    }
}

extension ChooseDateViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if scrollView.contentSize.height > scrollView.bounds.height {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
        didChangePickerValue()
        pickerContainerView.isHidden = false
        continueButton.isHidden = true
        
        return false
    }
}
