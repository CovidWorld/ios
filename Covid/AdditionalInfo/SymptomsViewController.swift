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

class SymptomsViewController: UIViewController {
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
}

extension SymptomsViewController {
        
    private func updateUI() {
        let bullet = "•  "
        var strings = [String]()
        strings.append("suchým, zadúšavým, dráždivým kašľom bez hlienov")
        strings.append("bolestami hlavy, kĺbov a svalov")
        strings.append("celkovou vyčerpanosťou")
        strings.append("pocitom ťažoby a pichaním na hrudníku alebo pocitom tzv. “nedostatočného nádychu”.")
        strings.append("vysoká teplota na hranici, alebo tesne za hranicou 38 stupňov, ale rovnako aj vysoko za hranicou 38 stupňov, v kombinácii s kašľom a zvyškom uvedených príznakov sú taktiež príznakom ochorenia.")
        strings = strings.map { return bullet + $0 }
        
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = UIFont(name: "Poppins-Regular", size: 15)
        attributes[.foregroundColor] = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 1)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
        attributes[.paragraphStyle] = paragraphStyle
        
        let string = strings.joined(separator: "\n\n")
        bodyLabel.attributedText = NSAttributedString(string: string, attributes: attributes)
    }
}
