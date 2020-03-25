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

class SelectAddressInfoViewController: UIViewController {

    @IBOutlet weak var selectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

extension SelectAddressInfoViewController {
    
    private func setupUI() {
        let substring1 = "Vybrať adresu mojej\n"
        let substring2 = "karantény"

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let font: UIFont = UIFont(name: "Poppins-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .heavy)
        let attributes = [NSMutableAttributedString.Key.font: font,
                          .foregroundColor: UIColor.white,
                          NSAttributedString.Key.paragraphStyle: paragraph]
        let attrString1 = NSMutableAttributedString(string: substring1, attributes: attributes)
        let attrString2 = NSMutableAttributedString(string: substring2, attributes: attributes)
        attrString1.append(attrString2)
        
        selectButton?.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        selectButton?.setAttributedTitle(attrString1, for: [])
    }
}
