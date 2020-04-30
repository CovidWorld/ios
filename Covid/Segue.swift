//
//  Segue.swift
//  Covid
//
//  Created by Boris Bielik on 07/04/2020.
//  Copyright © 2020 Sygic. All rights reserved.
//

import Foundation
import UIKit

enum Segue: String {
    case showServicesStatusView
    case quarantineVerifyNumber
    case startQuarantineFlow = "initQuarantine"
    case foreignAlert
    case searchAddress = "search"
    case phoneNumberVerification = "verification"
}

extension UIViewController {

    func performSegue(_ segue: Segue) {
        performSegue(withIdentifier: segue.rawValue, sender: self)
    }
}
