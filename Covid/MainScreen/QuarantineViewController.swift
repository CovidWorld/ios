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

//
//  QuarantineViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 16/03/2020.
//

import UIKit
import SwiftyUserDefaults

final class QuarantineViewController: ViewController {
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var quarantineUntilLabel: UILabel!

    private let networkService = CovidService()

    private var quarantineData: QuarantineStatusResponseData? {
        didSet {
            Defaults.quarantineActive = quarantineData?.isInQuarantine ?? false
            if Defaults.quarantineActive {
                Defaults.quarantineStart = quarantineData?.quarantineBeginning
                Defaults.quarantineEnd = quarantineData?.quarantineEnd
            } else {
                Defaults.quarantineStart = nil
                Defaults.quarantineEnd = nil
            }

            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard Defaults.profileId != nil else { return }

        updateView()
        updateQuarantineStatus()
    }
}

extension QuarantineViewController {
    private func updateQuarantineStatus() {
        networkService.requestQuarantineStatus(quarantineRequestData: BasicRequestData()) { [weak self] (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.quarantineData = response
                }
            case .failure: break
            }
        }
    }

    private func updateTracking() {
        // TODO: update
        if Defaults.quarantineActive {
//            LocationTracker.shared.startLocationTracking()
        } else {
//            LocationTracker.shared.stopLocationTracking()
        }
    }

    private func updateView() {
        if let endDate = Defaults.quarantineEnd {
            let days = Int(abs(((endDate.timeIntervalSince1970 - Date().timeIntervalSince1970) / 86400).rounded(.awayFromZero))) + 1
            quarantineUntilLabel.text = QuarantineViewController.daysToString(days)
        } else {
            quarantineUntilLabel.text = nil
        }

        addressLabel.text = "\(Defaults.quarantineStreet ?? "") \(Defaults.quarantineStreetNumber ?? "")\n\(Defaults.quarantineCity ?? "")"

        updateTracking()
    }

    private static func daysToString(_ numberOfDays: Int) -> String {
        let days: String

        if numberOfDays == 1 {
            days = "deň"
        } else if numberOfDays >= 2 && numberOfDays <= 4 {
            days = "dni"
        } else {
            days = "dní"
        }

        return "\(numberOfDays) \(days)"
    }
}
