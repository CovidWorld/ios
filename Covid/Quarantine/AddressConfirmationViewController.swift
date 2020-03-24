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
        
        if Defaults.phoneNumber != nil, let token = Defaults.mfaToken {
            networkService.requestQuarantine(quarantineRequestData: QuarantineRequestData(mfaToken: token)) { [weak self] (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                                LocationTracker.shared.startLocationTracking()
                                self?.navigationController?.popToRootViewController(animated: true)
                        case .failure:
                            let alertController = UIAlertController(title: "Chyba", message: "Problém pri overovaní čisla.", preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "Overiť znova", style: .cancel) { (_) in
                                self?.performSegue(withIdentifier: "quarantineVerifyNumber", sender: self)
                            }
                            alertController.addAction(cancelAction)
                            self?.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
        } else {
            performSegue(withIdentifier: "quarantineVerifyNumber", sender: self)
        }
    }
    
    @IBAction func didTapChangeButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
