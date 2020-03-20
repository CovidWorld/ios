//
//  PrivacyViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 19/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    
    @IBAction func closeDidTap(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
