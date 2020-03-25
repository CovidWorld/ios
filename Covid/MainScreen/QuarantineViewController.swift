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

class QuarantineViewController: UIViewController {
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var quarantineUntilLabel: UILabel!
    
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
}

extension QuarantineViewController {
    private func updateTracking() {
        if Defaults.quarantineActive {
            LocationTracker.shared.startLocationTracking()
        } else {
            LocationTracker.shared.stopLocationTracking()
        }
    }
    
    private func updateView() {
        if let startDate = Defaults.quarantineStart, let endDate = Defaults.quarantineEnd {
//            let calendar = Calendar.current
//            let date2 = calendar.startOfDay(for: endDate)
//
//            let components = calendar.dateComponents([.day], from: startDate, to: date2)
//            if let days = components.day {
//                quarantineUntilLabel.text = QuarantineViewController.daysToString(days)
//            }
            let days = Int(abs(((endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970) / 86400).rounded(.awayFromZero)))
            quarantineUntilLabel.text = QuarantineViewController.daysToString(days)
        }
        
        addressLabel.text = "\(Defaults.quarantineAddress ?? "")\n\(Defaults.quarantineCity ?? "")"

        updateTracking()
    }
    
    private static func daysToString(_ numberOfDays: Int) -> String {
        let days: String
        
        if numberOfDays == 1 {
            days = "ďeň"
        } else if numberOfDays >= 2 && numberOfDays <= 4 {
            days = "dni"
        } else {
            days = "dní"
        }
        
        return "\(numberOfDays) \(days)"
    }
}
