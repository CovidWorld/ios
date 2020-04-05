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

final class ChooseDateViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var dateTextField: UITextField!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var editImageView: UIImageView!
    @IBOutlet private weak var textFieldBackgroundView: UIView!
    @IBOutlet private weak var pickerContainerView: UIView!
    @IBOutlet private var pickerBottomConstraint: NSLayoutConstraint!

    override func loadView() {
        super.loadView()

        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        view.addGestureRecognizer(tapRecognizer)

        setupUI()
    }

    @IBAction private func didTapDone(_ sender: Any) {
        didTapView()
    }

    @IBAction private func didTapContinue(_ sender: Any) {
        Defaults.quarantineStart = datePicker.date
    }

    @IBAction private func didChangePickerValue() {
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
        pickerBottomConstraint.constant = -260
        continueButton.isHidden = false
        continueButton.isEnabled = !(dateTextField.text?.isEmpty ?? false)
        editImageView.isHidden = dateTextField.text?.isEmpty ?? false
    }

    private func setupUI() {
        pickerContainerView.isHidden = true
        pickerBottomConstraint.constant = -260
        continueButton.isHidden = false
        continueButton.isEnabled = false
        scrollView.isScrollEnabled = false
        editImageView.isHidden = true
        textFieldBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
        dateTextField.inputView = pickerContainerView

        let font: UIFont = UIFont(name: "Inter-Light", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .light)
        let attributes = [NSMutableAttributedString.Key.font: font,
                           .foregroundColor: UIColor(red: 76 / 255, green: 86 / 255, blue: 252 / 255, alpha: 1)]
        let attrPlaceholder = NSMutableAttributedString(string: "Kliknite pre výber dátumu", attributes: attributes)

        dateTextField.attributedPlaceholder = attrPlaceholder
        dateTextField.tintColor = .clear // zmazame kurzor

        let calendar = Calendar.current
        let currentDate = Date()
        var components = DateComponents()
        let quarantineDuration = Firebase.remoteConfig?["quarantineDuration"].stringValue ?? "14"

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
        pickerBottomConstraint.constant = 0
        continueButton.isHidden = true

        return false
    }
}
