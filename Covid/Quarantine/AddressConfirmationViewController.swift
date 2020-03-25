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
