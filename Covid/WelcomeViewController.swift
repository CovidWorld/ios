//
//  WelcomeViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 12/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class WelcomeViewController: UIViewController {
    @IBOutlet var agreeButton: UIButton!
    
    override func loadView() {
        super.loadView()
        
        agreeButton.layer.cornerRadius = 20
        agreeButton.layer.masksToBounds = true
        
        if Defaults.deviceId.isEmpty {
            Defaults.deviceId = UUID().uuidString
        }
    }
    
    @IBAction func agreeDidTap(_ sender: Any) {
        Defaults.didRunApp = true
    }
}
