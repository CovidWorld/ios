//
//  QuarantineViewController.swift
//  Covid
//
//  Created by Boris Kolozsi on 16/03/2020.
//  Copyright © 2020 Sygic. All rights reserved.
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
