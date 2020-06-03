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

final class SymptomsViewController: ViewController {

    @IBOutlet private weak var bodyLabel: UILabel!

    override func loadView() {
        super.loadView()

        updateUI()
    }
}

extension SymptomsViewController {

    private func updateUI() {
        guard Locale.current.identifier.contains("sk_") else { return }
        let text = "Ľudia nakazení COVID-19 udávajú široké spektrum prejavov, od miernych až po závažné.\n\nPrejavy sa zvyčajne objavujú 2-14 dní po vystavení sa nákaze a môžu zahŕňať:"
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Poppins-Light", size: 17.0)!, .foregroundColor: UIColor.darkGray]
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        let boldRange = (attributedString.string as NSString).range(of: "2-14 dní po vystavení sa nákaze")
        attributedString.setAttributes([.font: UIFont(name: "Poppins-Bold", size: 17.0)!], range: boldRange)
        bodyLabel.attributedText = attributedString
    }
}
