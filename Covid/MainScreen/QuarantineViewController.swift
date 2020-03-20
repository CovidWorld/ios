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
            let calendar = Calendar.current
            let date1 = calendar.startOfDay(for: startDate)
            let date2 = calendar.startOfDay(for: endDate)

            let components = calendar.dateComponents([.day], from: date2, to: date1)
            if let days = components.day {
                quarantineUntilLabel.text = String(abs(days))
            }
        }
        
        addressLabel.text = "\(Defaults.quarantineAddress ?? "")\n\(Defaults.quarantineCity ?? "")"

        updateTracking()
    }
}
