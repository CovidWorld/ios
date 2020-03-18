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
