//
//  IdentityViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 23/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class IdentityViewController: UIViewController {
    @IBOutlet var idLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let profileId = Defaults.profileId {
            let hashids = Hashids(salt: "COVID-19 super-secure and unguessable hashids salt", minHashLength: 6, alphabet: "ABCDEFGHJKLMNPQRSTUVXYZ23456789")
            idLabel.text = hashids.encode(profileId)?.uppercased()
        }
    }
}
