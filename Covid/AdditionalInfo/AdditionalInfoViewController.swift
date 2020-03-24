//
//  AdditionalInfoViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 22/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import UIKit

class AdditionalInfoViewController: UIViewController {
    
    @IBOutlet var protectView: UIView!
    @IBOutlet var symptomsView: UIView!
    @IBOutlet var howItWorksView: UIView!
    
    override func loadView() {
        super.loadView()
        
        protectView.layer.cornerRadius = 20
        protectView.layer.masksToBounds = true
        symptomsView.layer.cornerRadius = 20
        symptomsView.layer.masksToBounds = true
        howItWorksView.layer.cornerRadius = 20
        howItWorksView.layer.masksToBounds = true
    }
}
