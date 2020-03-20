import UIKit
import CoreLocation
import SwiftyUserDefaults

class AddressConfirmationViewController: UIViewController {
    
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    var streetText: String? = nil
    var cityText: String? = nil
    var location: CLLocationCoordinate2D? = nil
    
    private let networkService = CovidService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        streetLabel.text = streetText
        cityLabel.text = cityText
    }

    @IBAction func didTapConfirmButton(_ sender: Any) {
        Defaults.quarantineCity = cityText
        Defaults.quarantineAddress = streetText
        Defaults.quarantineLatitude = location?.latitude
        Defaults.quarantineLongitude = location?.longitude
    }
    
    @IBAction func didTapChangeButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
