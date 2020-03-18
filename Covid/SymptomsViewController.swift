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
