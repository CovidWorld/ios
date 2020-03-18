import UIKit
import SwiftyUserDefaults

class ForeignDecisionViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Defaults.didShowForeignAlert = true
    }
    
    @IBAction func didTapConfirm(_ sender: Any) {
        //TODO: delegate
        if let controller = (presentingViewController as? UINavigationController)?.topViewController as? MainViewController {
            controller.performSegue(withIdentifier: "initQuarantine", sender: nil)
        }
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
