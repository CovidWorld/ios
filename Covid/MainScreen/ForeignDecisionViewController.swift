import UIKit
import SwiftyUserDefaults

class ForeignDecisionViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Defaults.didShowForeignAlert = true
    }
    
    @IBAction func didTapConfirm(_ sender: Any) {
        //TODO: delegate
        presentingViewController?.dismiss(animated: true, completion: {
            if let controller = (UIApplication.shared.delegate as? AppDelegate)?.visibleViewController() {
                controller.performSegue(withIdentifier: "initQuarantine", sender: nil)
            }
        })
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
